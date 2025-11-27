#!/bin/bash

set -u

# source lib.sh

info "Installing dependencies"

###
# Homebrew
###

if [[ ! "$(which brew)" > /dev/null ]]; then
	info "Install Homebrew ..."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	eval "$(homebrew/bin/brew shellenv)"
fi

###
# ZSH
###

# OH My ZSH (https://ohmyz.sh/) a framework for managing your Zsh configuration
if [ ! -f "$HOME"/.oh-my-zsh/oh-my-zsh.sh ]; then
	info "Install OH My ZSH"
	sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi

# OH My ZSH Autosuggestions (https://github.com/zsh-users/zsh-autosuggestions) suggests commands based on history and completions.
if [ ! -d "$HOME"/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]; then
	info "Install OH My ZSH Autosuggetions"
	git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
fi

# OH My ZSH syntax highlighting (https://github.com/zsh-users/zsh-syntax-highlighting) Fish shell like syntax highlighting for Zsh.
if [ ! -d "$HOME"/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]; then
	info "Install OH My syntax highlighting"
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

###
# Brew install using Brewfile
###

brew bundle --file="$PWD/install/Brewfile"

###
# JVM based SDKs with SDKMan
###

if [ ! -d "${HOME}/.sdkman" ]; then
	info "Install SDKMAN"
	curl -s "https://get.sdkman.io" | bash
fi

# # echo "Install Java Stable"
## sdk current java
# sdk install java

# # echo "Install Java 8.0.222"
# # sdk install java 8.0.222.hs-adpt

# # echo "Install Maven"
# sdk install maven

# VisualVM ()
# sdk install visualvm

## TODO
# fnm install --lts

## TODO add Rust
if [[ ! "$(rustc --version)" > /dev/null ]]; then
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
else
	rustup upgrade stable
fi

## TODO add K8s Kubernetes kew
# https://krew.sigs.k8s.io/docs/user-guide/setup/install/
# kubectl krew install ctx
# kubectl krew install ns

# DEPRECATED FiraCode Nerd Font (https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/FiraCode) free monospaced font with programming ligatures
# MesloLGL Nerd Font (update VSCode settings to "terminal.integrated.fontFamily": "'MesloLGL Nerd Font'",)
if ! fc-list | grep -q MesloLGS; then
	info "Installing Nerd fonts"
	brew tap homebrew/cask-fonts
	brew install --cask font-meslo-lg-nerd-font
fi

# Visual Studio Code Extensions
vscodeToInstallExtensions=()

# Markdown Preview Mermaid Support (https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid)
vscodeToInstallExtensions+=("bierner.markdown-mermaid")

# Ruff extension for Visual Studio Code (https://marketplace.visualstudio.com/items?itemName=charliermarsh.ruff)
vscodeToInstallExtensions+=("charliermarsh.ruff")

# Markdown lint (https://marketplace.visualstudio.com/items?itemName=davidanson.vscode-markdownlint)
vscodeToInstallExtensions+=("davidanson.vscode-markdownlint")

# ESLint (https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint)
vscodeToInstallExtensions+=("dbaeumer.vscode-eslint")

# XML Tools (https://marketplace.visualstudio.com/items?itemName=dotjoshjohnson.xml)
vscodeToInstallExtensions+=("dotjoshjohnson.xml")

# Prettier code formatter (https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode)
vscodeToInstallExtensions+=("esbenp.prettier-vscode")

# GitHub Actions (https://marketplace.visualstudio.com/items?itemName=GitHub.vscode-github-actions)
vscodeToInstallExtensions+=("github.vscode-github-actions")

# GitHub Pull Requests and Issues (https://marketplace.visualstudio.com/items?itemName=github.vscode-pull-request-github)
vscodeToInstallExtensions+=("github.vscode-pull-request-github")

# Dependi (https://marketplace.visualstudio.com/items?itemName=fill-labs.dependi)
vscodeToInstallExtensions+=("fill-labs.dependi")

# CodeMetrics (https://marketplace.visualstudio.com/items?itemName=kisstkondoros.vscode-codemetrics)
vscodeToInstallExtensions+=("kisstkondoros.vscode-codemetrics")

# Docker (https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker)
vscodeToInstallExtensions+=("ms-azuretools.vscode-docker")

# Liveshare (https://marketplace.visualstudio.com/items?itemName=ms-vsliveshare.vsliveshare)
vscodeToInstallExtensions+=("ms-vsliveshare.vsliveshare")

# JSON fix (https://marketplace.visualstudio.com/items?itemName=oliversturm.fix-json)
vscodeToInstallExtensions+=("oliversturm.fix-json")

# Rust Analyzer (https://marketplace.visualstudio.com/items?itemName=rust-lang.rust-analyzer)
vscodeToInstallExtensions+=("rust-lang.rust-analyzer")

# SonarLint (https://marketplace.visualstudio.com/items?itemName=sonarsource.sonarlint-vscode)
vscodeToInstallExtensions+=("sonarsource.sonarlint-vscode")

# Svelte syntax highlighting (https://marketplace.visualstudio.com/items?itemName=svelte.svelte-vscode)
vscodeToInstallExtensions+=("svelte.svelte-vscode")

# Nushell syntax highlighting (https://marketplace.visualstudio.com/items?itemName=thenuprojectcontributors.vscode-nushell-lang)
vscodeToInstallExtensions+=("thenuprojectcontributors.vscode-nushell-lang")

# CodeLLDB (https://marketplace.visualstudio.com/items?itemName=vadimcn.vscode-lldb)
vscodeToInstallExtensions+=("vadimcn.vscode-lldb")

# Conventional Commits (https://marketplace.visualstudio.com/items?itemName=vivaxy.vscode-conventional-commits)
vscodeToInstallExtensions+=("vivaxy.vscode-conventional-commits")

# Make TypeScript errors prettier and human-readable (https://marketplace.visualstudio.com/items?itemName=yoavbls.pretty-ts-errors)
vscodeToInstallExtensions+=("yoavbls.pretty-ts-errors")

# Markdown All in One (https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one)
vscodeToInstallExtensions+=("yzhang.markdown-all-in-one")

check_install_vscode_extensions "${vscodeToInstallExtensions[@]}"

# TODO add `mise install` but reload shell

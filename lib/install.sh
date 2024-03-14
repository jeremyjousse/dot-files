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
else
    info "Upgrading Homebrew ..."
    brew upgrade
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
# GUI applications
###

# Chrome (https://www.google.com/intl/en_us/chrome/) Google's web browser
check_install_cask chrome "Google Chrome.app"

# Firefox (https://www.mozilla.org/en-US/firefox/new/) Mozilla's web browser
check_install_cask firefox "Firefox.app"

# Visual Studio Code (https://code.visualstudio.com/) a great Integrated Development Environment
check_install_cask visual-studio-code "Visual Studio Code.app"

# iTem2 (https://iterm2.com/) is a replacement for Terminal
check_install_cask iterm2 iTerm.app

# DevToys (https://devtoys.app/) Swiss army knife for developers
check_install_cask devtoys DevToys.app

# Maccy (https://maccy.app/) Clipboard manager
check_install_cask maccy Maccy.app

# KeyClu (https://sergii.tatarenkov.name/keyclu/support/) Simple and handy overview of applications shortcuts
check_install_cask keyclu KeyClu.app

# Rectangle (https://rectangleapp.com/) move and resize windows in macOS using keyboard shortcuts or snap areas
check_install_cask rectangle Rectangle.app

# VLC (https://www.videolan.org/vlc/index.html) multimedia player
check_install_cask vlc VLC.app

# Podman Desktop (https://podman-desktop.io/) a graphical interface that enables application developers to seamlessly work with containers and Kubernetes
check_install_cask podman-desktop "Podman Desktop.app"

# JetBrains Toolbox (https://www.jetbrains.com/toolbox-app/) manage your JetBrains tools easily
check_install_cask jetbrains-toolbox "JetBrains Toolbox.app"

# JDK Mission Control (https://www.oracle.com/java/technologies/jdk-mission-control.html) a profiling and event collection framework for JDK
check_install_cask jdk-mission-control "JDK Mission Control.app"

# Obsidian (https://obsidian.md/) private and flexible writing app, your seconde brain
check_install_cask obsidian Obsidian.app

# TODO this is not a standard cask install
# check_install_cask google-cloud-sdk

###
# Shell applications
###

# fish [friendly interactive shell] (https://fishshell.com/) user-friendly command-line shell for UNIX-like operating systems
check_install fish

# GitHub CLI (https://cli.github.com/) brings GitHub to your terminal
check_install gh

# direnv (https://direnv.net/) can load and unload environment variables depending on the current directory
check_install direnv

# jq (https://jqlang.github.io/jq/) is a lightweight and flexible command-line JSON processor
check_install jq

# ShellCheck (https://www.shellcheck.net/) finds bugs in your shell scripts
check_install shellcheck

# Starship (https://starship.rs/) minimal, blazing-fast, and infinitely customizable prompt for any shell
check_install starship

# HTTPie (https://httpie.io/) command line API testing client
check_install httpie

# SurrealDB (https://surrealdb.com/) ultimate multi-model database
check_install surrealdb/tap/surreal surreal

# Graphviz (https://graphviz.org/) graph visualization software
check_install graphviz dot

# wrk (https://github.com/wg/wrk) HTTP benchmarking tool
check_install wrk

# GnuPG (https://gnupg.org/) is a complete and free implementation of the OpenPGP
# Used to generate GPG key to sign git commits
check_install gnupg gpg

# shfmt (https://github.com/mvdan/sh) is a shell parser, formatter, and interpreter with bash support; includes shfmt
check_install shfmt

# The Fuck (https://github.com/nvbn/thefuck) corrects your previous console command
check_install thefuck

# - Dev languages boostrap

# mise-en-place (https://mise.jdx.dev) The front-end to your dev env
check_install mise

# - IA

# Ollama (https://ollama.com/) runs with large language models, locally.
check_install ollama

# - Javascript

#  fnm (https://github.com/Schniz/fnm) fast and simple Node.js version manager, built in Rust
check_install fnm

# Bun (https://bun.sh/) a new JavaScript runtime built from scratch to serve the modern JavaScript ecosystem
check_install bun

# - Python

# pyenv (https://github.com/pyenv/pyenv) simple Python version management
check_install pyenv

# - Container

# podman-compose (https://github.com/containers/podman-compose) a script to run docker-compose.yml using podman
check_install podman-compose

# Kubernetes command-line tool (https://kubernetes.io/docs/tasks/tools/) allows you to run commands against Kubernetes clusters
check_install kubectl

# kubectx (https://github.com/ahmetb/kubectx) Faster way to switch between clusters and namespaces in kubectl
check_install kubectx

# K9s (https://k9scli.io/) a terminal based UI to interact with your Kubernetes clusters
check_install k9s

# HELM (https://helm.sh/) Helm charts help you define, install, and upgrade even the most complex Kubernetes application
check_install helm

# Flux (https://fluxcd.io/) used to bootstrap and interact with Flux (a set of continuous and progressive delivery solutions for Kubernetes)
check_install fluxcd/tap/flux flux

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

# Cucumber (Gherkin) Full Support (https://marketplace.visualstudio.com/items?itemName=alexkrechik.cucumberautocomplete)
vscodeToInstallExtensions+=("alexkrechik.cucumberautocomplete")

# Sort imports (https://marketplace.visualstudio.com/items?itemName=amatiasq.sort-imports)
vscodeToInstallExtensions+=("amatiasq.sort-imports")

# Markdown Preview Mermaid Support (https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid)
vscodeToInstallExtensions+=("bierner.markdown-mermaid")

# Markdown lint (https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint)
vscodeToInstallExtensions+=("DavidAnson.vscode-markdownlint")

# ESLint (https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint)
vscodeToInstallExtensions+=("dbaeumer.vscode-eslint")

# XML Tools (https://marketplace.visualstudio.com/items?itemName=DotJoshJohnson.xml)
vscodeToInstallExtensions+=("DotJoshJohnson.xml")

# Prettier code formatter (https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode)
vscodeToInstallExtensions+=("esbenp.prettier-vscode")

# GitHub Actions (https://marketplace.visualstudio.com/items?itemName=GitHub.vscode-github-actions)
vscodeToInstallExtensions+=("github.vscode-github-actions")

# GitHub Pull Requests and Issues (https://marketplace.visualstudio.com/items?itemName=GitHub.vscode-pull-request-github)
vscodeToInstallExtensions+=("GitHub.vscode-pull-request-github")

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

# Rust Crates (https://marketplace.visualstudio.com/items?itemName=serayuzgur.crates)
vscodeToInstallExtensions+=("serayuzgur.crates")

# SonarLint (https://marketplace.visualstudio.com/items?itemName=SonarSource.sonarlint-vscode)
vscodeToInstallExtensions+=("SonarSource.sonarlint-vscode")

# Svelte for VS Code (https://marketplace.visualstudio.com/items?itemName=svelte.svelte-vscode)
vscodeToInstallExtensions+=("svelte.svelte-vscode")

# CodeLLDB (https://marketplace.visualstudio.com/items?itemName=vadimcn.vscode-lldb)
vscodeToInstallExtensions+=("vadimcn.vscode-lldb")

# IntelliCode (https://marketplace.visualstudio.com/items?itemName=VisualStudioExptTeam.vscodeintellicode)
vscodeToInstallExtensions+=("VisualStudioExptTeam.vscodeintellicode")

# Conventional Commits (https://marketplace.visualstudio.com/items?itemName=vivaxy.vscode-conventional-commits)
vscodeToInstallExtensions+=("vivaxy.vscode-conventional-commits")

# Markdown All in One (https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one)
vscodeToInstallExtensions+=("yzhang.markdown-all-in-one")

check_install_vscode_extensions "${vscodeToInstallExtensions[@]}"

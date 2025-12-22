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
	git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
fi

# OH My ZSH syntax highlighting (https://github.com/zsh-users/zsh-syntax-highlighting) Fish shell like syntax highlighting for Zsh.
if [ ! -d "$HOME"/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]; then
	info "Install OH My syntax highlighting"
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
fi

# zsh-defer (https://github.com/romkatv/zsh-defer) deferred execution of zsh commands
if [ ! -d "$HOME"/.zsh-defer ]; then
	info "Install zsh-defer"
	git clone https://github.com/romkatv/zsh-defer.git ~/.zsh-defer
fi


###
# Brew install using Brewfile
###

brew bundle --file="$PWD/install/Brewfile"

###
# npm global packages
###

# Gemini CLI (hhttps://github.com/google-gemini/gemini-cli) an open-source AI agent that brings the power of Gemini directly into your terminal
if ! command -v gemini &> /dev/null; then
	info "Install Gemini CLI"
	npm i -g @google/gemini-cli
fi


###
# uv tools
###

if ! command -v pynglish &> /dev/null; then
	info "Install pynglish uv tool"
	uv tool install "$DEVELOPMENT_ROOT_FOLDER/Personal/pynglish"
fi
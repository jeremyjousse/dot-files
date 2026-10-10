# Get inspiration from https://github.com/evantravers/dotfiles/blob/before-nix/Makefile



# Dotfiles directory
DOTFILES_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

# OS
ARCH          := $(shell uname -p)

# Homebrew path
BREW_PATH     ?= /opt/homebrew

# Homebrew bin path
BREW_BIN      ?= $(BREW_PATH)/bin

# Homebrew executable
BREW          := $(BREW_BIN)/brew

# Profile file
PROFILE       := $(HOME)/.profile

# update path
PATH := $(HOMEBREW_PREFIX)/bin:$(DOTFILES_DIR)/bin:$(N_PREFIX)/bin:$(PATH)

# Shell
#SHELL := env PATH=$(PATH) /bin/bash

# Homebrew prefix
#BIN := $(HOMEBREW_PREFIX)/bin

install: brew-packages
	$(MAKE) boostrap

update:
	brew update
	brew upgrade --formula
	brew cleanup

boostrap:
	./bootstrap.sh

brew:
	is-executable brew || curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh | bash

brew-packages: brew
	brew bundle --file=$(DOTFILES_DIR)/install/Brewfile || true
	brew bundle --file=$(DOTFILES_DIR)/install/VscodeBrewfile || true

brew-gui-packages: brew
	brew bundle --file=$(DOTFILES_DIR)/install/CaskBrewfile || true
	brew bundle --file=$(DOTFILES_DIR)/install/MasBrewfile || true

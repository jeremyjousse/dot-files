#!/bin/bash

# personnal utils as shell app
[ -d "${HOME}/Development/Personal/toolbox/utils" ] && export PATH="${HOME}/Development/Personal/toolbox/utils:$PATH"

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Direnv
# TODO maybe remove due to mise
command -v direnv &>/dev/null && eval "$(direnv hook zsh)"

# SDKMAN
[ -s "${HOME}/.sdkman/bin/sdkman-init.sh" ] && . "${HOME}/.sdkman/bin/sdkman-init.sh"

# Oh My ZSH Autocompletion
[ -f "${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && source "${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"

# cht (https://cht.sh/)
[ -e ${HOME}/.cht ] && export PATH="${HOME}/.cht:$PATH" && fpath=(~/.zsh.d/ $fpath)

# Google Cloud SDK
[ -d "$(brew --prefix)/share/google-cloud-sdk/" ] && source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc" && source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"

# Google cloud GKE auth plugin
export USE_GKE_GCLOUD_AUTH_PLUGIN=true

# Rust Cargo
[ -d $HOME/.cargo/env ] && source "$HOME/.cargo/env"

# code (Visual Studio Code) in terminal
[ -f "/Applications/Visual Studio Code.app/Contents/Resources/app/bin" ] && export PATH="${PATH}:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

## Kubernetes
# Krew
[ -d $HOME/.krew ] && export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

## pnpm
[ -d $HOME/Library/pnpm/ ] && export PATH="${HOME}/Library/pnpm/:$PATH"
[ -d $HOME/Library/pnpm/ ] && export PNPM_HOME="$HOME/Library/pnpm/"

## uv tools
[ -d $HOME/.local/bin/ ] && export PATH="$HOME/.local/bin/:$PATH"

# mise
command -v mise &>/dev/null && eval "$(/opt/homebrew/bin/mise activate zsh)"

# Java (via mise)
export JAVA_HOME=$(mise where java)

# Android SDK
export ANDROID_HOME=${HOME}/Library/Android/sdk

# zoxide
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"

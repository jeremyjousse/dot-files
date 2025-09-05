#!/bin/bash

# personnal utils as shell app
[ -d "${HOME}/Development/Personal/toolbox/utils" ] && export PATH="${HOME}/Development/Personal/toolbox/utils:$PATH"

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Direnv
eval "$(direnv hook zsh)"

# Starship
eval "$(starship init zsh)"

# SDKMAN
[ -s "${HOME}/.sdkman/bin/sdkman-init.sh" ] && . "${HOME}/.sdkman/bin/sdkman-init.sh"

# Oh My ZSH Autocompletion
[ -f "${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && source "${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"

# pyenv
PYENV_SHIMS="$(pyenv root)/shims"
[ -e $PYENV_SHIMS ] && eval $(pyenv init --path)

# SAML2AWS
SML2AWS="$(command -v saml2aws 2>/dev/null)"
[ ! -z "${SML2AWS}" ] && eval "$(saml2aws --completion-script-bash)"

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

# mise
eval "$(/opt/homebrew/bin/mise activate zsh)"

# zoxide
eval "$(zoxide init zsh)"

#!/bin/bash
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

check_install() {
  local installName="$1"
  if [ $# -eq 2 ]; then
    local software="$2"
  else
    local software="$1"
  fi

  if [[ ! $(which "$software") > /dev/null ]]; then
    info "Installing $installName using brew"
    brew install "$installName"
  fi
}

check_install_cask() {
  if [[ ! $# -eq 2 ]]; then
    error "check_install_cask require two arguments"
    return 1
  fi

  if [[ ! -d /Applications/"$2" ]]; then
    info "Installing $1 using brew (cask)"
    brew install --cask "$1"
  fi
}

check_install_vscode_extensions() {
  local vscodeToInstallExtensions=("$@")

  while IFS='' read -r line; do vscodeInstalledExtensions+=("$line"); done < <(code --list-extensions)

  for vscodeToInstallExtension in "${vscodeToInstallExtensions[@]}"; do
    if [[ ! ${vscodeInstalledExtensions[*]} =~ ${vscodeToInstallExtension} ]]; then
      info "installing $vscodeToInstallExtension Visual Studio Code extension"
      code --install-extension "${vscodeToInstallExtension}"
    fi
  done
}

create_folder() {
  if [[ ! -d "$1" ]]; then
    info "Creating folder $1"
    mkdir -p "$1"
  fi
}

link_config_files() {
  local source="$1"
  local destination="$2"

  # TODO check source
  # TODO check destination parent folder

  if [[ -d $source && -d $destination && ! -L $destination ]]; then
    warning "${destination} is a regular folder"
    info "Backuping destination folder to ${destination}.back!"
    mv "$destination"{,.back}
  fi

  if [[ -f $source && -f $destination && ! -L $destination ]]; then
    waring "${destination} is a regular file"
    info "Backuping destination file to ${destination}.back!"
    mv "$destination"{,.back}
  fi

  if [[ -L "$destination" && $(readlink -f "$destination") != "$source" ]]; then
    warning "Destination $(readlink -f "$destination") is not linked to ${source}"
    info "unlinking ${destination} link"
    unlink "$destination"
  fi

  if [ ! -L "$destination" ]; then
    info "Linking ${destination} to ${source}"
    ln -s "$source" "$destination"
  fi

  return 0
}

copy_config_files() {
  local source="$1"
  local destination="$2"

  if [[ -d $source && -d $destination && -L $destination ]]; then
    warning "${destination} is a symlink folder"
    info "Unlink destination folder to ${destination}!"
    unlink "$destination"
  fi

  # if [ ! -d "$destination" ]; then
  #   info "Creating destination folder ${destination}"
  #   mkdir -p "$destination"
  # fi

  cp -r "$source" "$destination"
}

green_color='\033[0;32m'  # Green
red_color='\033[0;31m'    # Yellow
yellow_color='\033[0;33m' # Yellow
rest_color='\033[0m'      # Text Reset

warning() {
  echo -e "\n\r⚠️ ${yellow_color}WARNING${rest_color} $1"
}

info() {
  echo -e "\n\rℹ️ ${green_color}INFO${rest_color} $1"
}

error() {
  echo -e "\n\r⚠️ ${red_color}ERROR${rest_color} $1"
}

abort() {
  error "Aborting script"
  exit 1
}

#!/bin/bash

source lib/lib.sh

create_folder "$HOME"/.config
create_folder "$HOME"/Development/Personal

link_config_files "$PWD"/config/zsh/.zshrc "$HOME"/.zshrc
link_config_files "$PWD"/config/zsh "$HOME"/.config/zsh

link_config_files "$PWD"/config/nushell "$HOME/Library/Application Support/nushell"

link_config_files "$PWD"/config/alacritty "$HOME"/.config/alacritty
link_config_files "$PWD"/config/git/.gitconfig "$HOME"/.gitconfig
link_config_files "$PWD"/config/nvim "$HOME"/.config/nvim
link_config_files "$PWD"/config/starship/starship.toml "$HOME"/.config/starship.toml

copy_config_files "$PWD"/config/mise "$HOME"/.config

source lib/install.sh

source lib/update.sh

mise trust -q

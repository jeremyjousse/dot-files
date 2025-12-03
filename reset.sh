#!/bin/bash

source lib/lib.sh

unlink_config_files "$HOME"/.zshrc
unlink_config_files "$HOME"/.config/zsh

unlink_config_files "$PWD"/config/nushell "$HOME/Library/Application Support/nushell"

unlink_config_files "$PWD"/config/alacritty "$HOME"/.config/alacritty
unlink_config_files "$PWD"/config/git/.gitconfig "$HOME"/.gitconfig
unlink_config_files "$PWD"/config/nvim "$HOME"/.config/nvim
unlink_config_files "$PWD"/config/starship/starship.toml "$HOME"/.config/starship.toml
unlink_config_files "$PWD"/config/zellij "$HOME"/.config/zellij

## TODO delete Brew folder
## TODO list other actions

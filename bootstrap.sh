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
link_config_files "$PWD"/config/zellij "$HOME"/.config/zellij

copy_config_files "$PWD"/config/mise "$HOME"/.config

# TODO link deno to /usr/local/bin due to Deno VSCode extension
# bad configuration https://github.com/denoland/vscode_deno/issues/234
# sudo ln -s "$HOME".local/share/mise/installs/deno/latest/bin/deno /usr/local/bin

source lib/install.sh

source lib/update.sh

mise trust -q

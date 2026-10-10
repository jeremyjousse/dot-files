#!/bin/bash

WITH_GUI=false
for argument in "$@"; do
	case "$argument" in
		--with-gui)
			WITH_GUI=true
			;;
		-h|--help)
			printf 'Usage: %s [--with-gui]\n' "$0"
			exit 0
			;;
		*)
			printf 'Unknown option: %s\n' "$argument" >&2
			exit 2
			;;
	esac
done

source lib/lib.sh

create_folder "$HOME"/.config
create_folder "$HOME"/.config/opencode
create_folder "$HOME"/Development/Personal

link_config_files "$PWD"/config/zsh/.zshrc "$HOME"/.zshrc
link_config_files "$PWD"/config/zsh "$HOME"/.config/zsh

link_config_files "$PWD"/config/opencode/opencode.jsonc "$HOME"/.config/opencode/opencode.jsonc
link_config_files "$PWD"/config/opencode/command "$HOME"/.config/opencode/command
link_config_files "$PWD"/config/opencode/agents "$HOME"/.config/opencode/agents
link_config_files "$PWD"/config/opencode/skills "$HOME"/.config/opencode/skills
link_config_files "$PWD"/config/opencode/rules "$HOME"/.config/opencode/rules

link_config_files "$PWD"/config/alacritty "$HOME"/.config/alacritty
link_config_files "$PWD"/config/gh-dash "$HOME"/.config/gh-dash
link_config_files "$PWD"/config/ghostty "$HOME"/.config/ghostty
link_config_files "$PWD"/config/git/.gitconfig "$HOME"/.gitconfig
link_config_files "$PWD"/config/hammerspoon "$HOME"/.hammerspoon
link_config_files "$PWD"/config/nushell "$HOME/Library/Application Support/nushell"
link_config_files "$PWD"/config/nvim "$HOME"/.config/nvim
link_config_files "$PWD"/config/starship/starship.toml "$HOME"/.config/starship.toml
link_config_files "$PWD"/config/vscode/settings.json "$HOME"/Library/Application\ Support/Code/User/settings.json
link_config_files "$PWD"/config/zellij "$HOME"/.config/zellij

copy_config_files "$PWD"/config/mise "$HOME"/.config

# TODO link deno to /usr/local/bin due to Deno VSCode extension
# bad configuration https://github.com/denoland/vscode_deno/issues/234
# sudo ln -s ~/.local/share/mise/installs/deno/latest/bin/deno /usr/local/bin/deno

generate_local_gitconfig "$PWD"/.env "$PWD"/config/git/.gitconfig

source lib/install.sh "$WITH_GUI"
source lib/git_repositories.sh

source lib/update.sh

mise trust -q

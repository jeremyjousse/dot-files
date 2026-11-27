#!/bin/bash

WITH_GUI=false
for argument in "$@"; do
	case "$argument" in
	--with-gui)
		WITH_GUI=true
		;;
	-h | --help)
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
create_folder "$HOME"/.pi/agent
create_folder "$HOME"/.copilot
create_folder "$HOME"/Development/Personal

link_config_files "$PWD"/config/zsh/.zshrc "$HOME"/.zshrc
link_config_files "$PWD"/config/zsh "$HOME"/.config/zsh

link_config_files "$PWD"/config/agents "$HOME"/.agents

link_config_files "$PWD"/config/opencode/opencode.jsonc "$HOME"/.config/opencode/opencode.jsonc
link_config_files "$PWD"/config/opencode/commands "$HOME"/.config/opencode/commands
link_config_files "$PWD"/config/opencode/agents "$HOME"/.config/opencode/agents

link_config_files "$PWD"/config/pi/prompts "$HOME"/.pi/agent/prompts
link_config_files "$PWD"/config/agents/instructions/sdlc-framework.instructions.md "$HOME"/.pi/agent/AGENTS.md
link_config_files "$PWD"/config/agents/instructions/minimalist-engineering.instructions.md "$HOME"/.pi/agent/APPEND_SYSTEM.md

## To Remove next release
[ -L "$HOME"/.pi/agent/minimalist-engineering.md ] && unlink "$HOME"/.pi/agent/minimalist-engineering.md
[ -L "$HOME/Library/Application Support/Code/User/prompts" ] && unlink "$HOME/Library/Application Support/Code/User/prompts"

link_config_files "$PWD"/config/copilot/agents "$HOME"/.copilot/agents
link_config_files "$PWD"/config/agents/instructions "$HOME"/.copilot/instructions

## To Remove next release
[ -L "$HOME"/.copilot/prompts ] && unlink "$HOME"/.copilot/prompts
[ -L "$HOME"/.copilot/copilot-instructions.md ] && unlink "$HOME"/.copilot/copilot-instructions.md
[ -L "$HOME"/.copilot/rules/minimalist-engineering.md ] && unlink "$HOME"/.copilot/rules/minimalist-engineering.md
rmdir "$HOME"/.copilot/rules 2>/dev/null || true

link_config_files "$PWD"/config/alacritty "$HOME"/.config/alacritty
link_config_files "$PWD"/config/gh-dash "$HOME"/.config/gh-dash
link_config_files "$PWD"/config/ghostty "$HOME"/.config/ghostty
link_config_files "$PWD"/config/git/.gitconfig "$HOME"/.gitconfig
link_config_files "$PWD"/config/hammerspoon "$HOME"/.hammerspoon
link_config_files "$PWD"/config/helix "$HOME"/.config/helix
link_config_files "$PWD"/config/nushell "$HOME/Library/Application Support/nushell"
link_config_files "$PWD"/config/nvim "$HOME"/.config/nvim
link_config_files "$PWD"/config/starship/starship.toml "$HOME"/.config/starship.toml
create_folder "$HOME/Library/Application Support/Code/User"
link_config_files "$PWD"/config/vscode/settings.json "$HOME"/Library/Application\ Support/Code/User/settings.json
link_config_files "$PWD"/config/worktrunk "$HOME"/.config/worktrunk
link_config_files "$PWD"/config/zellij "$HOME"/.config/zellij

copy_config_files "$PWD"/config/mise "$HOME"/.config

generate_local_gitconfig "$PWD"/.env "$PWD"/config/git/.gitconfig

source lib/install.sh "$WITH_GUI"
source lib/git_repositories.sh

source lib/update.sh

mise trust -q

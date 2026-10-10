#!/bin/bash

# Check dependencies across all Brewfiles
EXIT_CODE=0

brew bundle check --file="$PWD/install/Brewfile" || EXIT_CODE=1
brew bundle check --file="$PWD/install/CaskBrewfile" || EXIT_CODE=1
brew bundle check --file="$PWD/install/MasBrewfile" || EXIT_CODE=1
brew bundle check --file="$PWD/install/VscodeBrewfile" || EXIT_CODE=1
if [ -f "$PWD/install/ProfessionalBrewfile" ]; then
	brew bundle check --file="$PWD/install/ProfessionalBrewfile" || EXIT_CODE=1
fi

CLEANUP_FILES=("$PWD/install/Brewfile" "$PWD/install/CaskBrewfile" "$PWD/install/MasBrewfile" "$PWD/install/VscodeBrewfile")
if [ -f "$PWD/install/ProfessionalBrewfile" ]; then
	CLEANUP_FILES+=("$PWD/install/ProfessionalBrewfile")
fi

cat "${CLEANUP_FILES[@]}" | brew bundle cleanup --file=- # --force

exit "$EXIT_CODE"

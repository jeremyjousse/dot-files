#!/bin/bash

# Check dependencies across all Brewfiles
brew bundle check --file="$PWD/install/Brewfile"
brew bundle check --file="$PWD/install/CaskBrewfile"
brew bundle check --file="$PWD/install/MasBrewfile"
brew bundle check --file="$PWD/install/VscodeBrewfile"
[ -f "$PWD/install/ProfessionalBrewfile" ] && brew bundle check --file="$PWD/install/ProfessionalBrewfile"

cat "$PWD"/install/Brewfile "$PWD"/install/CaskBrewfile "$PWD"/install/MasBrewfile "$PWD"/install/VscodeBrewfile | brew bundle cleanup --file=- # --force

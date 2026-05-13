#!/bin/bash

###############################################################################
# Dock                                                                        #
###############################################################################

# Don't show recently used applications in the Dock
defaults write com.apple.dock show-recents -int 0

# Set the icon size of Dock items to 50 pixels
defaults write com.apple.dock tilesize -int 50

dockutil --no-restart --remove all
dockutil --no-restart --add "/Applications/Google Chrome.app"
dockutil --no-restart --add "/Applications/Ghostty.app"
dockutil --no-restart --add "/Applications/Visual Studio Code.app"
dockutil --no-restart --add "/Applications/Messages.app"

dockutil --add ~/Downloads --display folder --view grid --sort dateadded

killall Dock

###############################################################################
# Audio.                                                                      #
###############################################################################

# Play feedback when volume is changed
defaults write -g "com.apple.sound.beep.feedback" -int 1

###############################################################################
# Keyboard & Input                                                            #
###############################################################################

# Set fast keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -int 2

# Set fast initial key repeat rate
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Set fast trackpad speed
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 1.5

# Set fast mouse speed
defaults write NSGlobalDomain com.apple.mouse.scaling -float 3.0

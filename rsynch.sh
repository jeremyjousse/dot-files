#!/bin/bash

rsync -av --del "${HOME}/Music/Music/Media.localized/Music/" pi@owntone.local:/media/pi/USB/Music/
rsync -av --del "${HOME}/Pictures/Photos Library.photoslibrary/" pi@owntone.local:/media/pi/USB/Pictures/

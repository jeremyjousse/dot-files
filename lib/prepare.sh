#!/bin/bash

set -u

source lib.sh

info "Preparing your macOS computer"

info "Accept Xcode License"
sudo xcodebuild -license
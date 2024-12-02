##
# Core
##

alias c = clear
alias ll  = ls -l
alias r = nu
alias reload = nu
alias vi = nvim

##
# Network
##

alias myip = curl http://ipecho.net/plain; echo

##
# Projects
##

alias dot-files = code $"($env.HOME)/Development/Personal/dot-files"

##
# apps
##

# headless chrome
alias chrome = ^open "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

alias code = ^open "/Applications/Visual Studio Code.app"

##
# containers
##

alias k = kubectl
alias docker = podman

##
# Languages
## 
alias pip = python3 -m pip
alias python = python3

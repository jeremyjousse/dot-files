alias ll='ls -l'
alias myip='curl http://ipecho.net/plain; echo'
alias reload='source ~/.zshrc'
alias dot-files='code $HOME/Development/Personal/dot-files'
alias learnings='cd $HOME/Development/Personal/learnings && code . && npm run docusaurus start'
alias english='code $HOME/Development/Personal/learnings/docs/english/README.md'

alias vi="nvim"

# headless chrome
alias chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"

## Start a server on the local directory -> great for testing HTML emails
alias server='python -m SimpleHTTPServer 8000'

# A global alias to pipe a command’s output to grep
# exemple use: history G ssh
alias -g G='| grep'

# Kubernetes
alias k="kubectl"

## Podman
alias docker=podman

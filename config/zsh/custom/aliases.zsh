alias ll='ls -l'
alias my_ip='curl http://ipecho.net/plain; echo'
alias reload='source ~/.zshrc'
alias r='source ~/.zshrc'
alias dot-files='code $HOME/Development/Personal/dot-files'

alias vi="hx"

# headless chrome
alias chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"

## Start a server on the local directory -> great for testing HTML emails
alias server='python -m SimpleHTTPServer 8000'

# A global alias to pipe a command’s output to grep
# example use: history G ssh
alias -g G='| grep'

## Cargo for Rust
# Watch install (and build)
function cwi() {
  cargo watch -x -c -x "install --path ."
}

# Watch exemple
# cwi file_name
function cwe() {
  cargo watch -x -c -x "run -q --example '$1'"
}

# Watch tests
# cwt function_name
# cwt file_name function_name
function cwt() {
  if [[ $# -eq 1 ]]; then
    cargo watch -x -c -x "test '$1' -- --nocapture"
  elif [[ $# -eq 2 ]]; then
    cargo watch -x -c -x "test --test '$1' '$2' -- --nocapture"
  else
    cargo watch -x -c -x "test -- --nocapture"
  fi
}

# Kubernetes
alias k="kubectl"

## Podman
alias docker=podman

# Python
alias pip="python3 -m pip"
alias python=python3

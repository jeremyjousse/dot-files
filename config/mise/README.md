# mise-en-place

[mise-en-place](https://mise.jdx.dev/) is a multi language version manager.

I use it for:

- Java
- Node
- Python
- Rust

## Debug and fix

If getting
`[~/.config/mise/config.toml] python@3.13.2: git failed: Cmd(["git", "-C", "/Users/${USER}/Library/Caches/mise/python/pyenv", "-c", "safe.directory=/Users/${USER}/Library/Caches/mise/python/pyenv", "fetch", "--prune", "--update-head-ok", "origin", "master:master"]) fatal: 'origin' does not appear to be a git repository`

Simply delete the cache folder `rm -r ~/Library/Caches/mise/python/pyenv`

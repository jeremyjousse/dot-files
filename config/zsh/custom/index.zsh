CONFIG_PATH="${HOME}/.config/zsh/custom/"

load_config_file() {
  if [ -f $1 ]; then
    source $1
  fi
}

# Starship
command -v starship &> /dev/null && eval "$(starship init zsh)"

zsh-defer load_config_file "${CONFIG_PATH}lib.sh"
zsh-defer load_config_file "${CONFIG_PATH}modules.zsh"
zsh-defer load_config_file "${CONFIG_PATH}aliases.zsh"
zsh-defer load_config_file "${CONFIG_PATH}proxy.sh"
zsh-defer load_config_file "${CONFIG_PATH}env.zsh"
zsh-defer load_config_file "${CONFIG_PATH}utils.zsh"

hostname=$(hostname)
if [ ${hostname} = "FRL-Y65NQL4JTG" ]; then
  zsh-defer load_config_file "${CONFIG_PATH}professional.sh"
fi

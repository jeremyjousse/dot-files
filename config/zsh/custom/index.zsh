CONFIG_PATH="${HOME}/.config/zsh/custom/"

load_config_file() {
  if [ -f $1 ]; then
    source $1
  fi
}

load_config_file "${CONFIG_PATH}modules.zsh"
load_config_file "${CONFIG_PATH}aliases.zsh"
load_config_file "${CONFIG_PATH}proxy.sh"
load_config_file "${CONFIG_PATH}env.zsh"
load_config_file "${CONFIG_PATH}utils.zsh"

hostname=$(hostname)
if [ ${hostname} = "FRL-Y65NQL4JTG" ]; then
  echo "Loading professional config"
  load_config_file "${CONFIG_PATH}professional.zsh"
fi

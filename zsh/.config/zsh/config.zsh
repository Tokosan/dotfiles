# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="crcandy"
HYPHEN_INSENSITIVE="true"
ENABLE_CORRECTION="true"
HIST_STAMPS="yyyy-mm-dd"
zstyle ':omz:update' mode auto      # update automatically without asking

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi


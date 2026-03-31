[[ $- != *i* ]] && return

DOTFILES_DIR="${${(%):-%N}:A:h}"

# Interactive shell defaults.
setopt AUTO_CD
setopt AUTO_PUSHD
setopt COMPLETE_IN_WORD
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt INTERACTIVE_COMMENTS
setopt NO_BEEP
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt PROMPT_SUBST
setopt SHARE_HISTORY

HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
HISTSIZE=100000
SAVEHIST=100000

ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
ZSH_PLUGIN_DIR="$HOME/.local/share/zsh"
mkdir -p "${HISTFILE:h}" "$ZSH_CACHE_DIR"

# Prefer Homebrew-provided completions and cache compinit output.
fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
autoload -Uz compinit
autoload -Uz colors && colors
zmodload zsh/complist

_zcompdump="$ZSH_CACHE_DIR/.zcompdump-$ZSH_VERSION"
if [[ -s "$_zcompdump" ]]; then
  compinit -C -d "$_zcompdump"
else
  compinit -d "$_zcompdump"
fi

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR"
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

bindkey -e
stty -ixon 2>/dev/null
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward

alias ls='eza --group-directories-first --icons=auto'
alias ll='eza -lah --group-directories-first --icons=auto'
alias la='eza -la --group-directories-first --icons=auto'
alias lt='eza --tree --level=2 --icons=auto'
alias cat='bat --paging=never --style="numbers,changes,header"'
alias g='git'
alias reload='source ~/.zshrc'

# Git helpers.
alias ga='git add'
alias gb='git branch'
alias gc='git commit'
alias gd='git diff'
alias gl='git pull --ff-only'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gst='git status -sb'
alias gco='git checkout'

# pnpm helpers.
alias p='pnpm'
# alias pi='pnpm install'
alias pd='pnpm dev'
alias pb='pnpm build'

take() {
  mkdir -p "$1" && cd "$1"
}

repo-clone() {
  "${DOTFILES_DIR}/scripts/repo-clone" "$@"
}

rc() {
  local arg
  local dir

  for arg in "$@"; do
    if [[ "$arg" == "--dry-run" ]]; then
      repo-clone "$@"
      return
    fi
  done

  dir="$(repo-clone "$@")" || return
  cd "$dir" || return
}

if [[ -t 1 && -r /opt/homebrew/opt/fzf/shell/completion.zsh ]]; then
  source /opt/homebrew/opt/fzf/shell/completion.zsh
fi

if [[ -t 1 && -r /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]]; then
  source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
fi

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

if [[ -r "$ZSH_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "$ZSH_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

if [[ -r "$ZSH_PLUGIN_DIR/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh" ]]; then
  source "$ZSH_PLUGIN_DIR/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
fi

if [[ -o zle && "$TERM_PROGRAM" != "Apple_Terminal" ]] && command -v oh-my-posh >/dev/null 2>&1; then
  eval "$(oh-my-posh init zsh --config "$HOME/.config/ohmyposh/vesper.omp.json")"
fi

if command -v infisical >/dev/null 2>&1; then
  # Skip cleanly when this machine or shell has not been linked to an Infisical project.
  infisical_npm_token_export="$(
    infisical export --env=dev --path=/ --format=dotenv --silent 2>/dev/null \
      | grep '^NPM_TOKEN_GOOGLE_SIGN_IN=' \
      | sed 's/^/export /'
  )"
  if [[ -n "$infisical_npm_token_export" ]]; then
    eval "$infisical_npm_token_export"
  fi
  unset infisical_npm_token_export
fi

# pnpm
export PNPM_HOME="/Users/dillion/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

eval "$(thefuck --alias)"

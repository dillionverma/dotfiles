# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=/Users/dillionverma/.oh-my-zsh
source $ZSH/oh-my-zsh.sh

alias git=hub
alias cat=bat
alias cb="git rev-parse --abbrev-ref HEAD"
alias connect="sudo openconnect vpn.networkspike.com --no-dtls -u kamal"
alias g++14="g++ -std=c++14 -Wall -g"
alias ctags="`brew --prefix`/bin/ctags"
export EDITOR='code'
export PATH=$PATH:/Users/dillionverma/bin
export PYTHONPATH=$PYTHONPATH:/usr/local/bin/
export TERM=xterm-256color
export ANDROID_HOME="/Users/dillionverma/Library/Android/sdk/"
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export GPG_TTY=`tty`
export JAVA_HOME='/Library/Java/JavaVirtualMachines/adoptopenjdk-11.jdk/Contents/Home'
export JAVA_FX_HOME='/Users/dillionverma/lib/javafx-sdk-11.0.2'

eval $(thefuck --alias)

function commits() {
  git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
      --header "Press CTRL-S to toggle sort" \
      --preview "echo {} | grep -o '[a-f0-9]\{7\}' | head -1 |
                 xargs -I % sh -c 'git show --color=always % | head -$LINES'" \
      --bind "enter:execute:echo {} | grep -o '[a-f0-9]\{7\}' | head -1 |
              xargs -I % sh -c 'vim fugitive://\$(git rev-parse --show-toplevel)/.git//% < /dev/tty'"
}


function replace() {
  ag -0 --files-with-matches $1 | xargs -0 -I {} sed -i '' -e "s~$1~$2~g" {}
}
export PATH="/usr/local/sbin:$PATH"
export BAT_PAGER="less -RF"


# PLUGINS
source "${HOME}/.zgen/zgen.zsh"

# if the init scipt doesn't exist
if ! zgen saved; then
    echo "Creating a zgen save"

    zgen oh-my-zsh

    # plugins
    zgen oh-my-zsh plugins/git
    zgen oh-my-zsh plugins/npm 
    zgen oh-my-zsh plugins/heroku
    zgen oh-my-zsh plugins/rails
    zgen oh-my-zsh plugins/z
    zgen oh-my-zsh plugins/sudo
    zgen oh-my-zsh plugins/command-not-found

    zgen load zsh-users/zsh-syntax-highlighting
    zgen load zsh-users/zsh-autosuggestions

    # completions
    zgen load zsh-users/zsh-completions

    # theme
    zgen oh-my-zsh themes/agnoster

    # save all to init script
    zgen save
fi


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

eval "$(rbenv init -)"

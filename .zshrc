# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=/Users/dillionverma/.oh-my-zsh

ZSH_THEME="agnoster"

plugins=(git npm brew heroku rails rake z)

source $ZSH/oh-my-zsh.sh
# source ~/.oh-my-zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh  
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
. `brew --prefix`/etc/profile.d/z.sh
source ~/.bin/tmuxinator.zsh
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

bindkey '^ ' autosuggest-accept

alias git=hub
alias cb="git rev-parse --abbrev-ref HEAD"
alias connect="sudo openconnect vpn.networkspike.com --no-dtls --servercert sha256:4410a9cb49c5a6c9366a22f54267340f944b8325b20a77213cfb4a61f21444ac -u kamal"
alias g++14="g++ -std=c++14 -Wall -g"
alias lint="rubocop -a"
alias ctags="`brew --prefix`/bin/ctags"
export EDITOR='vim'
export NVM_DIR="$HOME/.nvm"
export GOPATH=~/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOPATH/bin:$GOBIN
export PATH="/usr/local/opt/opencv3/bin:$PATH"
export PYTHONPATH=$PYTHONPATH:/usr/local/bin/
export TERM=xterm-256color

[[ -s "/Users/dillionverma/.gvm/scripts/gvm" ]] && source "/Users/dillionverma/.gvm/scripts/gvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
if [ -f '/Users/dillionverma/Documents/google-cloud-sdk/path.zsh.inc' ]; then source '/Users/dillionverma/Documents/google-cloud-sdk/path.zsh.inc'; fi
if [ -f '/Users/dillionverma/Documents/google-cloud-sdk/completion.zsh.inc' ]; then source '/Users/dillionverma/Documents/google-cloud-sdk/completion.zsh.inc'; fi

#archey


export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

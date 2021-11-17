# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

alias connect="sudo openconnect vpn.networkspike.com --no-dtls -u kamal"
alias testnet="open -n /Applications/Electrum.app --args --testnet"
alias n="nigiri"
alias ns="nigiri rpc sendtoaddress"
alias ng='nigiri rpc generatetoaddress 6 $(nigiri rpc getnewaddress "" "bech32")'
alias deploy_testnet="ssh mac.atomic.finance 'cd ~/src/atomicfinance/options-app && git pull && yarn deploy:testflight:testnet'"
alias c="clear"
alias k="kubectl"
alias ip="ipconfig getifaddr en0"


alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gcm='git commit -m'
alias gc='git commit -v'
alias gcb='git checkout -b'
alias gco='git checkout'
alias gd='git diff'
alias gl='git pull'
alias gp='git push'

alias gstp='git stash pop'






#function deploy_testnet() {}


# Execute DLC tx
#   Usage:
#     Navigate to dlcd/packages/cli/bin and run command `execute <contractid> <strikeprice>`
#     Get contractId from the app somehow
#   Params: 
#     $1 = contractId
#     $2 = strikePrice
function execute() {
  contractId=$1
  strikePrice=$2
  echo "contractId" $contractId
  announcement=$(./dlccli.sh getdlcannouncement $contractId | jq -r '.announcementId')  
  echo "announcement" $announcement
  attest=$(./dlccli.sh createoracleattestment $announcement $strikePrice | jq -r '.hex')
  echo "attest" $attest
  dlcexecutetx=$(./dlccli.sh getdlcexecutetx $contractId $attest)
  echo "executetx" $dlcexecutetx
  # Copy to clipboard for osx
  if [ -x "$(command -v pbcopy)" ]; then
    echo "copying executetx to clipboard"
    echo $dlcexecutetx | pbcopy
  fi
  broadcast=$(./dlccli.sh broadcast $dlcexecutetx)
  echo "broadcast" $broadcast
}


# Usage: `sha256 <hex encoded string>`
function sha256() {
  echo "$1" | xxd -r -p | openssl dgst -sha256
}

export SOURCE_PATH=~/src

# mock dev command (inspired by shopify)
#
# usage:
#   dev clone facebook/react
#   dev cd facebook/react
function dev() {
  if [ "$1" = "clone" ]; then
    gh repo clone "$2" $SOURCE_PATH/$(basename $2)
  elif [ "$1" = "cd" ]; then
    cd $SOURCE_PATH/"$2"
  fi
}


function newtypescript() {
  npm init -y
  npm install -D typescript
  npm install -D tslint
  tsc --init
  ./node_modules/.bin/tslint --init
  echo node_modules/ >> .gitignore
}

# PLUGINS
source "${HOME}/.zgen/zgen.zsh"
source "${HOME}/.zprofile"

# if the init scipt doesn't exist
if ! zgen saved; then
    echo "Creating a zgen save"

    # zgen load zsh-users/zsh-syntax-highlighting
    zgen load zdharma/fast-syntax-highlighting
    zgen load zsh-users/zsh-autosuggestions
    zgen load rupa/z 

    # completions
    # zgen load zsh-users/zsh-completions

    # theme
    # zgen oh-my-zsh themes/agnoster
    zgen load romkatv/powerlevel10k powerlevel10k

    # save all to init script
    zgen save
fi
 
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

export PATH=$PATH:$HOME/bin

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"
source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
source ~/.rvm/scripts/rvm


[ -f .env ] && source .env

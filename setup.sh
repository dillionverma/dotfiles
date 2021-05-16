#!/bin/bash

COMPUTER_NAME='mbp'

# Set computer name (as done via System Preferences → Sharing)
sudo scutil --set ComputerName $COMPUTER_NAME
sudo scutil --set HostName $COMPUTER_NAME
sudo scutil --set LocalHostName $COMPUTER_NAME

echo "Creating an ed25519 SSH key for you..."
ssh-keygen -t ed25519 -C "dillionverma@hotmail.com"

echo "Starting ssh-agent"
eval "$(ssh-agent -s)"

echo "Creating ~/.ssh/config file"
touch ~/.ssh/config
echo "Host *" >> ~/.ssh/config
echo "	AddKeysToAgent yes" >> ~/.ssh/config
echo "	IdentityFile ~/.ssh/id_ed25519" >> ~/.ssh/config

echo "Adding key to agent"
ssh-add -K ~/.ssh/id_ed25519

#echo "Copying keys to clipboard"
#cat ~/.ssh/id_ed25519.pub | pbcopy

#echo "Please add this public key to Github \n"
#echo "https://github.com/account/ssh \n"
#open https://github.com/account/ssh
#read -p "Press [Enter] key after saving ssh keys"

echo "Installing xcode tools"
xcode-select --install
read -p "Press [Enter] key after installing xcode"

echo "Installing homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo "Installing homebrew packages"
brew install vim
brew install diff-so-fancy
brew install thefuck
brew install fzf
brew install wget
brew install ripgrep
brew install gh
brew install kubectl
brew install zsh
brew install tmux
brew install golang
brew install python
brew install cmake
brew install mono
brew install nodejs


echo "Installing Git..."
brew install git

echo "Setting git config"
git config --global user.name "Dillion Verma"
git config --global user.email dillionverma@hotmail.com
git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"

echo "Setting up github cli"
gh auth login # Also uploads keys

# Install mac quick-look extensions
brew install --cask --no-quarantine \
    qlcolorcode \
    qlstephen \
    qlmarkdown \
    quicklook-json \
    quicklook-csv \
    qlimagesize \
    qlvideo \
    quicklookapk

brew install --cask --no-quarantine \
    alfred \
    docker \
    firefox \
    iterm2 \
    transmission \
    notion \
    vlc \
    discord \
    spotify \
    bitwarden \
    visual-studio-code \
    slack \
    keybase \
    google-backup-and-sync \
    eloston-chromium \
    whatsapp \
    rectangle

# Install fonts
brew tap homebrew/cask-fonts    

brew install --cask font-fira-code      
brew install --cask font-fira-code-nerd-font    


echo "Install zsh package manager: zgen"
git clone https://github.com/tarjoilija/zgen.git "${HOME}/.zgen"

echo "Install tmux package manager: tpm"
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

echo "Install vim package manager: vundle"
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

echo "Installing tmux plugins"
~/.tmux/plugins/tpm/scripts/install_plugins.sh

echo "Installing vim plugins"
vim +PluginInstall +qall

echo "Compiling YCM (vim)"
cd ~/.vim/bundle/YouCompleteMe
python3 install.py --all


# https://www.perfectfitcomputers.ca/faster-key-repeat-macos/
# set delay until repeat settings
defaults write -g InitialKeyRepeat -int 20

# set repeat rate settings
defaults write -g KeyRepeat -int 1.15

# disable spelling autocorrection
defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false


# Menu bar: show battery percentage
defaults write com.apple.menuextra.battery ShowPercent -string "YES"

# Show path bar in finder
defaults write com.apple.finder ShowPathbar -bool true

# Show status bar in finder
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder 'NewWindowTarget' -string 'PfHm'
# Finder: allow text selection in Quick Look
defaults write com.apple.finder QLEnableTextSelection -bool true
killall Finder

# Remove automatic workspace switching 
defaults write com.apple.dock workspaces-auto-swoosh -bool NO
# Don’t show recent applications in Dock
defaults write com.apple.dock show-recents -bool false
killall Dock

# Disable "... is an application downloaded from the internet. Are you sure you want to open it?"
defaults write com.apple.LaunchServices LSQuarantine -bool NO

# Prevent Time Machine from prompting to use new hard drives as backup volume
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# Don’t display the annoying prompt when quitting iTerm
defaults write com.googlecode.iterm2 PromptOnQuit -bool false

# Visualize CPU usage in the Activity Monitor Dock icon
defaults write com.apple.ActivityMonitor IconType -int 5
killall "Activity Monitor"

# disable cmd+space shortcut for spotlight
/usr/libexec/PlistBuddy ~/Library/Preferences/com.apple.symbolichotkeys.plist -c "Set AppleSymbolicHotKeys:64:enabled false"


echo "Done!"

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

echo "Copying keys to clipboard"
cat ~/.ssh/id_ed25519.pub | pbcopy

echo "Please add this public key to Github \n"
echo "https://github.com/account/ssh \n"
open https://github.com/account/ssh
read -p "Press [Enter] key after this..."

echo "Installing xcode tools"
xcode-select --install

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

echo "Installing Git..."
brew install git

echo "Setting git config"
git config --global user.name "Dillion Verma"
git config --global user.email dillionverma@hotmail.com
git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"

echo "Setting up github cli"
gh auth login

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
    vlc \
    discord \
    spotify \
    bitwarden \
    visual-studio-code \
    slack \
    keybase \
    google-backup-and-sync \
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



# https://www.perfectfitcomputers.ca/faster-key-repeat-macos/
# set delay until repeat settings
defaults write -g InitialKeyRepeat -int 20

# set repeat rate settings
defaults write -g KeyRepeat -int 1.15



# disable spelling autocorrection
defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false

# Show path bar in finder
defaults write com.apple.finder ShowPathbar -bool true

# Show status bar in finder
defaults write com.apple.finder ShowStatusBar -bool true

# Remove automatic workspace switching 
defaults write com.apple.dock workspaces-auto-swoosh -bool NO
killall Dock


# disable cmd+space shortcut for spotlight
/usr/libexec/PlistBuddy ~/Library/Preferences/com.apple.symbolichotkeys.plist -c \
  "Set AppleSymbolicHotKeys:64:enabled false"


echo "Done!"

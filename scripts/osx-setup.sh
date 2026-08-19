#!/bin/bash

# Install XCode
  # Download from https://apps.apple.com/us/app/xcode/id497799835?mt=12
  # Install the CLI tools
  xcode-select --install
    
# Install Homebrew    
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/carlos/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
brew update
brew install --cask iterm2
brew install wget

# update iterm2 settings -> colors, keep directory open new shell, keyboard shortcuts

# Install ohmyzsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
echo $SHELL

# Some funny CLI integrations
brew install cowsay
brew install fortune
cowsay -f tux hello $USER

# Additional software
brew install fortune
brew install cowsay 
brew install git
brew install vcprompt

# Node Version Manager (NVM)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
echo "CARLOS LOG >>>> : You need to restart the CLI prompt to activate nvm"


# update bash_profile
brew install --cask spectacle
# brew install --cask alfred
brew install bind

brew install --cask firefox


# install nvm/node
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
nvm install stable
# mkdir ~/workspace
# npm install -g lite-server eslint
brew install --cask visual-studio-code

# Configure the finder settings


# Install breaktimer and flux
brew install --cask breaktimer
brew install --cask flux



# update vscode settings
# install vscode extensions 

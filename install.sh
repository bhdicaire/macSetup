#!/usr/bin/env bash


## Hombrew
echo "Install Homebrew"
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew analytics off

## Git
echo "Update Git"
brew install git

## Ansible
echo "Install Ansible and prerequisites"
brew install ansible

echo "**********************************************"
echo "Installation complete"
echo "**********************************************"

brew list
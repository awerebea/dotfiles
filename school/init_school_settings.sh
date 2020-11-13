#! /bin/bash
# dark theme
osascript -l JavaScript -e "Application('System Events').appearancePreferences.darkMode = true"
# keyboard
defaults write -g ApplePressAndHoldEnabled -bool true
defaults write -g InitialKeyRepeat -int 10 # normal minimum is 15 (225 ms)
defaults write -g KeyRepeat -int 1 # normal minimum is 2 (30 ms)
# normal mouse scroll
defaults write -g com.apple.swipescrolldirection -bool FALSE
# init minikube in goinfre
rm -rf ~/.minikube
mkdir -p /goinfre/awerebea/.minikube
ln -s /goinfre/awerebea/.minikube ~/.minikube
# init Docker
# . ~/42toolbox/init_docker.sh

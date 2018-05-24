#!/bin/bash
# Making hidden files visible
defaults write com.apple.finder AppleShowAllFiles YES;

# Setting save to Disk by Default
defaults write -g NSDocumentSaveNewDocumentsToCloud -bool false

# Setting Default Finder Location to Home Folder
defaults write com.apple.finder NewWindowTarget -string "PfLo" && \
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}"

# Make the 'Current Folder' as default search scope in Finder
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Show status and path bar in Finder
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true

# Show Full Path in Finder Title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Show process indicators on dock
defaults write com.apple.dock show-process-indicators -bool true

# Adding a context menu item for showing the Web Inspector in web views
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

# Disabling disk image verification
defaults write com.apple.frameworks.diskimages skip-verify -bool true &&
defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true &&
defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

# Disabling Creation of Metadata Files on USB and Network Volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Disabling system-wide auto-correct
defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false

killall Finder /System/Library/CoreServices/Finder.app;

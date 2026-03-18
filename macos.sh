#!/usr/bin/env bash
set -euo pipefail

# macOS system preferences

# Finder
defaults write com.apple.finder AppleShowAllFiles YES                          # Show hidden files
defaults write -g NSDocumentSaveNewDocumentsToCloud -bool false                # Save to disk, not iCloud
defaults write com.apple.finder NewWindowTarget -string "PfLo"                 # Default location: home
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}"
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"            # Search current folder
defaults write com.apple.finder ShowPathbar -bool true                         # Show path bar
defaults write com.apple.finder ShowStatusBar -bool true                       # Show status bar

# Dock
defaults write com.apple.dock show-process-indicators -bool true               # Process indicators

# System
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true   # No .DS_Store on network
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true       # No .DS_Store on USB
defaults write -g ApplePressAndHoldEnabled -bool false                         # Key repeat, not accents

killall Finder 2>/dev/null || true
killall Dock 2>/dev/null || true

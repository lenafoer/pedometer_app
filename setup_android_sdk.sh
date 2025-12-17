#!/bin/bash

# Android SDK Setup Script for Pedometer App
# This script will set up Android command line tools for building Android apps

set -e

echo "================================================"
echo "Android SDK Setup for Pedometer App"
echo "================================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo -e "${RED}This script is designed for Linux. You're running: $OSTYPE${NC}"
    exit 1
fi

echo -e "${YELLOW}This will install Android command line tools to: $HOME/Android${NC}"
echo "Disk space required: ~2-3 GB"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 1
fi

# Create Android directory
echo -e "\n${GREEN}[1/6] Creating Android directory...${NC}"
mkdir -p "$HOME/Android/cmdline-tools"
cd "$HOME/Android/cmdline-tools"

# Download command line tools
echo -e "\n${GREEN}[2/6] Downloading Android command line tools...${NC}"
if [ ! -f "commandlinetools-linux-11076708_latest.zip" ]; then
    wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
else
    echo "Command line tools already downloaded, skipping..."
fi

# Extract and organize
echo -e "\n${GREEN}[3/6] Extracting and organizing files...${NC}"
if [ ! -d "latest" ]; then
    unzip -q commandlinetools-linux-11076708_latest.zip
    mkdir -p latest
    mv cmdline-tools/* latest/ 2>/dev/null || true
    rmdir cmdline-tools 2>/dev/null || true
else
    echo "Already extracted, skipping..."
fi

# Set up environment variables
echo -e "\n${GREEN}[4/6] Setting up environment variables...${NC}"
ANDROID_HOME="$HOME/Android"
export ANDROID_HOME
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
export PATH="$PATH:$ANDROID_HOME/platform-tools"

# Add to bashrc if not already there
if ! grep -q "ANDROID_HOME" "$HOME/.bashrc"; then
    echo "" >> "$HOME/.bashrc"
    echo "# Android SDK" >> "$HOME/.bashrc"
    echo "export ANDROID_HOME=\$HOME/Android" >> "$HOME/.bashrc"
    echo "export PATH=\$PATH:\$ANDROID_HOME/cmdline-tools/latest/bin" >> "$HOME/.bashrc"
    echo "export PATH=\$PATH:\$ANDROID_HOME/platform-tools" >> "$HOME/.bashrc"
    echo -e "${GREEN}Added Android SDK to ~/.bashrc${NC}"
else
    echo -e "${YELLOW}Android SDK already in ~/.bashrc${NC}"
fi

# Install SDK components
echo -e "\n${GREEN}[5/6] Installing SDK components...${NC}"
echo "This may take a few minutes..."

# Accept licenses
yes | "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" --licenses > /dev/null 2>&1 || true

# Install required components
"$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" "platform-tools" "platforms;android-33" "build-tools;33.0.0"

# Configure Flutter
echo -e "\n${GREEN}[6/6] Configuring Flutter...${NC}"
flutter config --android-sdk "$ANDROID_HOME"
flutter doctor --android-licenses || true

# Verify setup
echo -e "\n${GREEN}================================================${NC}"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo "Running flutter doctor to verify..."
echo ""
flutter doctor -v

echo ""
echo -e "${GREEN}✓ Android SDK installed successfully!${NC}"
echo ""
echo "Next steps:"
echo "1. Reload your shell: source ~/.bashrc"
echo "2. Connect your Android phone via USB"
echo "3. Enable USB debugging on your phone"
echo "4. Run: flutter devices"
echo "5. Run: flutter run --release"
echo ""
echo "See ANDROID_INSTALLATION.md for detailed instructions."

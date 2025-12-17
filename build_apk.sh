#!/bin/bash

# Complete APK Build Script for Pedometer App
# This script will set up Android SDK and build your APK

set -e

echo "=========================================="
echo "Pedometer App - Complete APK Builder"
echo "=========================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check Java version
echo -e "${YELLOW}[1/6] Checking Java version...${NC}"
JAVA_VERSION=$(java -version 2>&1 | grep -i version | cut -d'"' -f2 | cut -d'.' -f1)
if [ "$JAVA_VERSION" -lt 17 ]; then
    echo -e "${RED}Java 17+ required. Current version: $JAVA_VERSION${NC}"
    echo "Please install Java 17:"
    echo "  sudo apt-get update"
    echo "  sudo apt-get install -y openjdk-17-jdk"
    echo ""
    echo "Then set JAVA_HOME in ~/.bashrc:"
    echo "  export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64"
    echo "  export PATH=\$JAVA_HOME/bin:\$PATH"
    exit 1
fi
echo -e "${GREEN}✓ Java version OK${NC}"

# Set environment variables
echo -e "\n${YELLOW}[2/6] Setting up environment...${NC}"
export ANDROID_HOME="$HOME/Android"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"

if [ ! -d "$ANDROID_HOME/cmdline-tools/latest" ]; then
    echo -e "${RED}Android SDK not found at $ANDROID_HOME${NC}"
    echo "Please run the setup first: ./setup_android_sdk.sh"
    exit 1
fi
echo -e "${GREEN}✓ Android SDK found${NC}"

# Accept licenses
echo -e "\n${YELLOW}[3/6] Accepting Android licenses...${NC}"
echo "Press 'y' when prompted..."
$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses || {
    echo -e "${RED}Failed to accept licenses${NC}"
    exit 1
}

# Install SDK components
echo -e "\n${YELLOW}[4/6] Installing SDK components...${NC}"
$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0" || {
    echo -e "${RED}Failed to install SDK components${NC}"
    exit 1
}
echo -e "${GREEN}✓ SDK components installed${NC}"

# Configure Flutter
echo -e "\n${YELLOW}[5/6] Configuring Flutter...${NC}"
flutter config --android-sdk "$ANDROID_HOME"
flutter doctor --android-licenses || true
echo -e "${GREEN}✓ Flutter configured${NC}"

# Build APK
echo -e "\n${YELLOW}[6/6] Building APK...${NC}"
cd /home/elena/Projects/pedometer_app
flutter build apk --release

echo ""
echo -e "${GREEN}=========================================="
echo "✓ APK Built Successfully!"
echo "==========================================${NC}"
echo ""
echo "Your APK is ready at:"
echo "  build/app/outputs/flutter-apk/app-release.apk"
echo ""
APK_SIZE=$(du -h build/app/outputs/flutter-apk/app-release.apk | cut -f1)
echo "APK Size: $APK_SIZE"
echo ""
echo "Transfer to your phone:"
echo "1. Connect phone via USB"
echo "2. Run: adb install build/app/outputs/flutter-apk/app-release.apk"
echo "   OR"
echo "   Copy to phone: adb push build/app/outputs/flutter-apk/app-release.apk /sdcard/Download/"
echo ""

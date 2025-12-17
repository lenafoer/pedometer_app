# Setting Up Android SDK for Building the Pedometer App

You need Android SDK to build apps for Android. Here are the easiest methods:

## Option 1: Install Android Command Line Tools (Recommended - Lightweight)

This is the minimal setup without needing the full Android Studio.

### Step 1: Download Command Line Tools

```bash
cd ~
mkdir -p Android/cmdline-tools
cd Android/cmdline-tools

# Download Android command line tools
wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip

# Unzip
unzip commandlinetools-linux-11076708_latest.zip

# Create proper directory structure
mkdir latest
mv cmdline-tools/* latest/
rmdir cmdline-tools
```

### Step 2: Set Environment Variables

Add these to your `~/.bashrc` or `~/.zshrc`:

```bash
# Add to ~/.bashrc
export ANDROID_HOME=$HOME/Android
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
```

Then reload:
```bash
source ~/.bashrc
```

### Step 3: Install Required SDK Components

```bash
# Accept licenses
yes | sdkmanager --licenses

# Install required components
sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0"
```

### Step 4: Configure Flutter

```bash
flutter config --android-sdk $HOME/Android
flutter doctor --android-licenses  # Accept all licenses
```

### Step 5: Verify Setup

```bash
flutter doctor -v
```

You should see Android toolchain with a checkmark ✓

---

## Option 2: Install Android Studio (Full IDE - Larger Download)

### Step 1: Download Android Studio

```bash
cd ~/Downloads
wget https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2024.1.1.12/android-studio-2024.1.1.12-linux.tar.gz
```

Or download from: https://developer.android.com/studio

### Step 2: Extract and Install

```bash
sudo tar -xzf android-studio-*-linux.tar.gz -C /opt/
cd /opt/android-studio/bin
./studio.sh
```

### Step 3: Follow Android Studio Setup Wizard

1. Choose "Standard" installation
2. It will download Android SDK components (this takes a while)
3. Accept all licenses

### Step 4: Configure Flutter

Flutter should auto-detect Android Studio. Verify with:
```bash
flutter doctor -v
```

---

## Option 3: Quick Setup Script (Automated)

I've created a script for you. Run:

```bash
cd /home/elena/Projects/pedometer_app
chmod +x setup_android_sdk.sh
./setup_android_sdk.sh
```

This will:
- Download Android command line tools
- Set up SDK
- Install required components
- Configure Flutter

---

## After SDK Setup - Build Your App

Once Android SDK is set up:

### 1. Connect Your Phone

- Enable USB debugging on your phone
- Connect via USB
- Run: `flutter devices` to verify

### 2. Build and Install

**Direct installation (easiest):**
```bash
cd /home/elena/Projects/pedometer_app
flutter run --release
```

**Or build APK file:**
```bash
flutter build apk --release
```

APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

---

## Troubleshooting

### "sdkmanager: command not found"
Make sure you added environment variables to `~/.bashrc` and ran `source ~/.bashrc`

### "Android license status unknown"
```bash
flutter doctor --android-licenses
```
Press 'y' for all prompts

### Still seeing errors?
```bash
flutter doctor -v
```
This will show exactly what's missing

---

## Disk Space Requirements

- **Command Line Tools**: ~2-3 GB
- **Android Studio**: ~4-5 GB

## Internet Required

- Initial SDK download: ~500 MB - 1 GB
- One-time setup only

## Next Steps

After setting up Android SDK:
1. See [ANDROID_INSTALLATION.md](ANDROID_INSTALLATION.md) for building the app
2. Connect your phone via USB
3. Run `flutter run --release`
4. Enjoy your pedometer app!

# Build APK - Quick Guide

I've downloaded the Android SDK tools for you, but we need Java 17 to complete the setup.

## Quick Steps to Build Your APK

### Step 1: Install Java 17

Run this command in your terminal:

```bash
sudo apt-get update
sudo apt-get install -y openjdk-17-jdk
```

### Step 2: Set Environment Variables

Add these to your `~/.bashrc`:

```bash
echo '# Android SDK' >> ~/.bashrc
echo 'export ANDROID_HOME=$HOME/Android' >> ~/.bashrc
echo 'export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin' >> ~/.bashrc
echo 'export PATH=$PATH:$ANDROID_HOME/platform-tools' >> ~/.bashrc
echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' >> ~/.bashrc
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ~/.bashrc
```

Then reload:
```bash
source ~/.bashrc
```

### Step 3: Install SDK Components

```bash
sdkmanager --licenses
```

Press 'y' to accept all licenses (about 7 times).

Then install required components:
```bash
sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0"
```

### Step 4: Configure Flutter

```bash
flutter config --android-sdk $HOME/Android
flutter doctor --android-licenses
```

### Step 5: Build the APK!

```bash
cd /home/elena/Projects/pedometer_app
flutter build apk --release
```

Your APK will be at:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## Alternative: Use Android Studio (Easier)

If the above seems too complex, install Android Studio instead:

1. Download from: https://developer.android.com/studio
2. Or run:
   ```bash
   sudo snap install android-studio --classic
   ```
3. Open Android Studio and let it download the SDK
4. Then run: `flutter build apk --release`

---

## What I've Already Done

✅ Created project folder structure
✅ Downloaded Android command line tools (146 MB)
✅ Extracted tools to `~/Android/cmdline-tools/latest/`
✅ Created all setup scripts and documentation

## What You Need to Do

☐ Install Java 17 (commands above)
☐ Set environment variables (commands above)
☐ Accept licenses and install SDK components
☐ Build the APK

---

## Quick Copy-Paste Commands

Here's everything in one go (copy and run):

```bash
# Install Java 17
sudo apt-get update && sudo apt-get install -y openjdk-17-jdk

# Add to bashrc
cat >> ~/.bashrc << 'EOF'

# Android SDK
export ANDROID_HOME=$HOME/Android
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH
EOF

# Reload bashrc
source ~/.bashrc

# Accept licenses (press 'y' multiple times)
sdkmanager --licenses

# Install SDK components
sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0"

# Configure Flutter
flutter config --android-sdk $HOME/Android
flutter doctor --android-licenses

# Build APK
cd /home/elena/Projects/pedometer_app
flutter build apk --release
```

After running all these commands, your APK will be ready at:
`build/app/outputs/flutter-apk/app-release.apk`

---

## Transfer APK to Phone

Once the APK is built:

**Option 1: USB Transfer**
```bash
# Copy to phone's Download folder
adb push build/app/outputs/flutter-apk/app-release.apk /sdcard/Download/
```

**Option 2: Email/Cloud**
- Email the APK to yourself
- Or use Google Drive, Dropbox, etc.

**Option 3: Direct Install**
```bash
# Connect phone via USB with USB debugging enabled
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## Need Help?

See the detailed guides:
- [QUICK_START_ANDROID.md](QUICK_START_ANDROID.md)
- [SETUP_ANDROID_SDK.md](SETUP_ANDROID_SDK.md)
- [ANDROID_INSTALLATION.md](ANDROID_INSTALLATION.md)

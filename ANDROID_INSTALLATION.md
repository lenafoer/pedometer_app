# Installing Pedometer App on Your Android Phone

This guide will help you build and install the pedometer app on your Android device.

## Prerequisites

1. **Flutter SDK** installed on your Linux machine (already done ✓)
2. **Android phone** with USB debugging enabled
3. **USB cable** to connect phone to computer

## Step 1: Enable Developer Options on Your Phone

1. Open **Settings** on your Android phone
2. Scroll down to **About phone** (or **About device**)
3. Find **Build number** (might be under Software information)
4. Tap **Build number** 7 times rapidly
5. You'll see a message "You are now a developer!"

## Step 2: Enable USB Debugging

1. Go back to **Settings**
2. Find **Developer options** (usually under System or Additional settings)
3. Enable **USB debugging**
4. If available, also enable **Install via USB**

## Step 3: Connect Your Phone to Computer

1. Connect your Android phone to your Linux computer via USB cable
2. On your phone, you'll see a prompt "Allow USB debugging?"
3. Check "Always allow from this computer"
4. Tap **OK**

## Step 4: Verify Connection

Open terminal and run:

```bash
flutter devices
```

You should see your Android device listed. It will look something like:
```
Found 2 connected devices:
  SM G980F (mobile) • RFCT12345AB • android-arm64 • Android 13 (API 33)
  Linux (desktop)   • linux       • linux-x64     • Linux
```

## Step 5: Build and Install the App

### Option A: Install in Debug Mode (Faster, for testing)

Navigate to your project directory and run:

```bash
cd /home/elena/Projects/pedometer_app
flutter run --release
```

This will:
- Build the app in release mode (better performance)
- Install it directly on your phone
- Launch the app automatically

### Option B: Build APK File (Can share/install later)

Build a release APK:

```bash
cd /home/elena/Projects/pedometer_app
flutter build apk --release
```

The APK will be created at:
```
build/app/outputs/flutter-apk/app-release.apk
```

**Transfer APK to phone:**

**Method 1: USB Transfer**
```bash
# Copy APK to your phone's Downloads folder
adb push build/app/outputs/flutter-apk/app-release.apk /sdcard/Download/
```

Then on your phone:
1. Open **Files** or **Downloads** app
2. Find `app-release.apk`
3. Tap to install (you may need to allow installation from unknown sources)

**Method 2: Email/Cloud**
- Email the APK to yourself
- Or upload to Google Drive/Dropbox
- Download on your phone and install

## Step 6: Grant Permissions

When you first open the app on Android:

1. The app will request **Physical Activity** permission
2. Tap **Allow** or **While using the app**
3. You may also see a notification permission request (optional)

## Troubleshooting

### "flutter: command not found"
Make sure Flutter is in your PATH:
```bash
export PATH="$PATH:$HOME/flutter/bin"
```

### "No devices found"
1. Check USB cable is connected properly
2. Make sure USB debugging is enabled
3. Try revoking USB debugging authorizations and reconnecting
4. Run: `adb devices` to check if device is detected

### "Install via USB is disabled"
On your phone:
- Go to Settings → Developer options
- Enable "Install via USB"

### App installation blocked
On your phone:
- Go to Settings → Security
- Enable "Install unknown apps" for your file manager

### Permission issues during build
```bash
flutter clean
flutter pub get
flutter build apk --release
```

## Quick Commands Reference

```bash
# Navigate to project
cd /home/elena/Projects/pedometer_app

# Check connected devices
flutter devices

# Install and run directly (recommended)
flutter run --release

# Build APK only
flutter build apk --release

# Install APK via ADB
adb install build/app/outputs/flutter-apk/app-release.apk

# Check ADB devices
adb devices

# Copy APK to phone
adb push build/app/outputs/flutter-apk/app-release.apk /sdcard/Download/
```

## Expected File Size

The release APK will be approximately 15-25 MB.

## After Installation

1. Open the **Pedometer App** on your phone
2. Grant the **Physical Activity** permission when prompted
3. Start walking - the app will automatically count your steps!
4. View statistics by tapping the chart icon or "View Statistics" button

## Uninstalling

To uninstall:
- Long press the app icon → App info → Uninstall

Or via ADB:
```bash
adb uninstall com.example.pedometer_app
```

## Notes

- The app will continue counting steps even when closed (background service)
- All data is stored locally on your phone
- No internet connection required
- Battery usage is minimal (uses hardware sensors efficiently)

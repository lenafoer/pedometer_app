# 📋 Installation Checklist - Pedometer App on Android

Follow this checklist to install your pedometer app on your Android phone.

## ✅ Pre-Installation Checklist

### On Your Computer (Linux)
- [ ] Flutter is installed (check with: `flutter --version`)
- [ ] Project folder is at `/home/elena/Projects/pedometer_app`
- [ ] USB port available for phone connection

### On Your Android Phone
- [ ] USB cable available
- [ ] Phone has at least 50 MB free space
- [ ] Phone is charged (at least 20% battery)

---

## 📦 Step 1: Setup Android SDK (One-Time Setup)

**Estimated time: 5-10 minutes**

### Commands to run:

```bash
cd /home/elena/Projects/pedometer_app
./setup_android_sdk.sh
```

### Checklist:
- [ ] Script downloaded Android SDK successfully (~2-3 GB)
- [ ] No errors displayed
- [ ] Environment variables added to `~/.bashrc`
- [ ] Run: `source ~/.bashrc`
- [ ] Verify with: `flutter doctor -v` shows Android toolchain ✓

**⚠️ If setup fails:** See [SETUP_ANDROID_SDK.md](SETUP_ANDROID_SDK.md)

---

## 📱 Step 2: Prepare Your Phone

### Enable Developer Options:

- [ ] Open **Settings** on your phone
- [ ] Go to **About phone** (or **About device**)
- [ ] Find **Build number**
- [ ] Tap **Build number** 7 times rapidly
- [ ] See message "You are now a developer!"

### Enable USB Debugging:

- [ ] Go back to **Settings**
- [ ] Find **Developer options** (usually under System)
- [ ] Toggle **USB debugging** ON
- [ ] (Optional) Toggle **Install via USB** ON

---

## 🔌 Step 3: Connect Your Phone

### Physical Connection:

- [ ] Plug USB cable into your phone
- [ ] Plug USB cable into your computer
- [ ] Phone shows "Charging" or "USB connected" notification

### Allow USB Debugging:

- [ ] Popup appears on phone: "Allow USB debugging?"
- [ ] Check "Always allow from this computer"
- [ ] Tap **OK**

### Verify Connection:

```bash
flutter devices
```

- [ ] Your Android phone is listed
- [ ] Shows device name and model
- [ ] Status shows as available

**Example output:**
```
SM G980F (mobile) • RF8M12345 • android-arm64 • Android 13 (API 33)
```

**⚠️ If phone not detected:**
- [ ] Try unplugging and replugging USB
- [ ] Check phone shows "File transfer" mode (swipe down notifications)
- [ ] Try a different USB port
- [ ] Check USB cable is data-capable (not charge-only)

---

## 🚀 Step 4: Build and Install the App

### Choose your installation method:

### Option A: Direct Install (Recommended)

**Estimated time: 2-5 minutes (first build)**

```bash
cd /home/elena/Projects/pedometer_app
flutter run --release
```

#### Checklist:
- [ ] Build starts (shows "Building...")
- [ ] No errors during compilation
- [ ] App installs automatically on phone
- [ ] App launches on phone
- [ ] Home screen appears

### Option B: Build APK File

**For sharing or installing later**

```bash
flutter build apk --release
```

#### Checklist:
- [ ] Build completes successfully
- [ ] APK created at: `build/app/outputs/flutter-apk/app-release.apk`
- [ ] APK size is ~15-25 MB

#### Transfer to Phone:

**Method 1: USB Transfer**
```bash
adb push build/app/outputs/flutter-apk/app-release.apk /sdcard/Download/
```

**Method 2: Manual Transfer**
- [ ] Copy APK to phone via USB file browser
- [ ] Or email APK to yourself
- [ ] Or upload to Google Drive/Dropbox

#### Install on Phone:
- [ ] Open **Files** or **Downloads** app on phone
- [ ] Find `app-release.apk`
- [ ] Tap to install
- [ ] Allow installation (if prompted)
- [ ] Tap **Install**
- [ ] Tap **Open**

---

## 🎯 Step 5: First Launch

### Grant Permissions:

When you open the app for the first time:

- [ ] Popup: "Allow Pedometer App to access physical activity?"
- [ ] Tap **Allow** or **While using the app**
- [ ] (Optional) Notification permission → Allow or Deny

### Verify App Works:

- [ ] App home screen shows step counter at 0
- [ ] Status shows "Unknown" or current state
- [ ] Distance and calories cards visible
- [ ] "View Statistics" button visible
- [ ] No error messages displayed

### Test Step Counting:

- [ ] Walk around with your phone
- [ ] Step counter increases
- [ ] Distance and calories update
- [ ] Status changes to "WALKING"

---

## ✨ Step 6: Explore Features

### Main Screen:
- [ ] View current step count
- [ ] See distance traveled
- [ ] Check calories burned
- [ ] Monitor walking status

### Statistics Screen:
- [ ] Tap chart icon or "View Statistics"
- [ ] View overall statistics
- [ ] See weekly progress chart
- [ ] Browse daily history
- [ ] Test clear data (optional)

---

## 🎉 Success Criteria

You're done when:

✅ App is installed on your Android phone
✅ Permissions are granted
✅ Step counter increases when walking
✅ Statistics screen shows data
✅ No error messages appear

---

## 🔧 Troubleshooting

### Build Errors

If you see compilation errors:

```bash
flutter clean
flutter pub get
flutter build apk --release
```

- [ ] Try clean build
- [ ] Check internet connection
- [ ] Verify all dependencies installed

### Phone Not Detected

- [ ] USB debugging enabled?
- [ ] USB cable connected properly?
- [ ] Allowed USB debugging on phone?
- [ ] Try different USB port
- [ ] Restart ADB: `adb kill-server && adb start-server`

### App Won't Install

- [ ] Enable "Install unknown apps" in Settings → Security
- [ ] Check phone has enough storage space
- [ ] Uninstall old version if upgrading

### Permissions Not Working

- [ ] Go to phone Settings → Apps → Pedometer App → Permissions
- [ ] Manually enable "Physical activity" permission
- [ ] Restart the app

---

## 📞 Need Help?

Refer to detailed guides:

1. **[QUICK_START_ANDROID.md](QUICK_START_ANDROID.md)** - Quick 3-step guide
2. **[ANDROID_INSTALLATION.md](ANDROID_INSTALLATION.md)** - Comprehensive installation
3. **[SETUP_ANDROID_SDK.md](SETUP_ANDROID_SDK.md)** - SDK setup details
4. **[README.md](README.md)** - App features and documentation

---

## 🎯 Quick Reference Commands

```bash
# Check Flutter setup
flutter doctor -v

# List connected devices
flutter devices

# Install directly on phone
flutter run --release

# Build APK file
flutter build apk --release

# Clean build (if errors)
flutter clean && flutter pub get

# Copy APK to phone
adb push build/app/outputs/flutter-apk/app-release.apk /sdcard/Download/

# Check ADB connection
adb devices
```

---

**Enjoy your pedometer app! 🚶‍♀️📱**

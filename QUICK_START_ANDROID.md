# Quick Start: Install Pedometer App on Android Phone

## 🚀 Super Quick Method (3 Steps)

### Step 1: Setup Android SDK (One-time only)

Run the automated setup script:

```bash
cd /home/elena/Projects/pedometer_app
./setup_android_sdk.sh
```

This will download and configure Android SDK (~2-3 GB, takes 5-10 minutes).

After completion, reload your shell:
```bash
source ~/.bashrc
```

### Step 2: Connect Your Phone

1. **On your phone:**
   - Go to Settings → About phone
   - Tap "Build number" 7 times (enables Developer options)
   - Go to Settings → Developer options
   - Enable "USB debugging"

2. **Connect phone to computer via USB cable**

3. **Verify connection:**
   ```bash
   flutter devices
   ```

   You should see your phone listed!

### Step 3: Install the App

**Method A: Direct install (recommended)**
```bash
flutter run --release
```

The app will build and install automatically on your phone!

**Method B: Build APK file**
```bash
flutter build apk --release
```

Then transfer `build/app/outputs/flutter-apk/app-release.apk` to your phone.

---

## ✅ That's it!

Open the Pedometer app on your phone, grant permissions, and start walking!

---

## 📱 Using the App

1. **First launch**: Grant "Physical Activity" permission
2. **Automatic counting**: Just carry your phone - it counts steps automatically
3. **View stats**: Tap the chart icon to see:
   - Daily step history
   - Weekly progress chart
   - Distance traveled
   - Calories burned
4. **Clear data**: Tap delete icon in stats screen

---

## 🔧 Troubleshooting

### "flutter devices" shows no devices
- Check USB cable is properly connected
- Make sure USB debugging is enabled
- Try unplugging and replugging the USB cable
- On your phone, tap "Allow USB debugging" when prompted

### Setup script fails
See detailed instructions in [SETUP_ANDROID_SDK.md](SETUP_ANDROID_SDK.md)

### Can't install APK on phone
- Enable "Install from unknown sources" in phone settings
- Settings → Security → Install unknown apps → Files → Allow

---

## 📚 More Information

- **Detailed Android installation**: [ANDROID_INSTALLATION.md](ANDROID_INSTALLATION.md)
- **Android SDK setup**: [SETUP_ANDROID_SDK.md](SETUP_ANDROID_SDK.md)
- **App features**: [README.md](README.md)
- **Linux demo mode**: [LINUX_DEMO_MODE.md](LINUX_DEMO_MODE.md)

---

## 💡 Quick Commands

```bash
# Check what devices are connected
flutter devices

# Build and install on phone
flutter run --release

# Build APK file only
flutter build apk --release

# Check Flutter setup
flutter doctor -v

# Copy APK to phone (if connected via USB)
adb push build/app/outputs/flutter-apk/app-release.apk /sdcard/Download/
```

# Creating the Walking Duck Icon

## Option 1: Use Online Icon Generator (Easiest)

1. Go to https://www.appicon.co/ or https://icon.kitchen/
2. Upload a duck image (512x512 px recommended) or use an emoji 🦆
3. Set background color to pink (#FF6B6B) or transparent
4. Generate all sizes for Android
5. Download and replace files in `android/app/src/main/res/mipmap-*` folders

## Option 2: Use flutter_launcher_icons Package

Add to `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/duck_icon.png"
  adaptive_icon_background: "#FF6B6B"
  adaptive_icon_foreground: "assets/icon/duck_foreground.png"
```

Then run:
```bash
flutter pub get
dart run flutter_launcher_icons
```

## Option 3: Manual Creation

Create a 512x512 PNG with:
- A cute duck silhouette
- Duck in walking pose (one leg forward)
- Pink-orange gradient (#FF6B6B to #FFB347)
- White or transparent background

Then use Android Studio:
1. Right-click `android/app/src/main/res`
2. New → Image Asset
3. Choose Icon Type: Launcher Icons
4. Upload your duck image
5. Generate all sizes

## Quick Emoji Solution

For now, you can use a duck emoji as the icon:

1. Go to https://favicon.io/emoji-favicons/duck/
2. Download the duck emoji icon pack
3. Extract and copy PNG files to Android mipmap folders
4. Rename to `ic_launcher.png`

## Icon Requirements

- **Sizes needed**:
  - mipmap-mdpi: 48x48
  - mipmap-hdpi: 72x72
  - mipmap-xhdpi: 96x96
  - mipmap-xxhdpi: 144x144
  - mipmap-xxxhdpi: 192x192

## Current Icon Location

The app icon files should be placed in:
```
android/app/src/main/res/
  ├── mipmap-mdpi/ic_launcher.png
  ├── mipmap-hdpi/ic_launcher.png
  ├── mipmap-xhdpi/ic_launcher.png
  ├── mipmap-xxhdpi/ic_launcher.png
  └── mipmap-xxxhdpi/ic_launcher.png
```

After adding the icon, rebuild the APK:
```bash
flutter clean
flutter build apk --release
```

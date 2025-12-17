# Pedometer App

A feature-rich pedometer application built with Flutter that tracks your daily steps, distance, and calories burned with comprehensive statistics and history tracking.

## Features

- **Real-time Step Tracking**: Counts your steps in real-time using device sensors
- **Daily Statistics**: Tracks steps, distance (km), and calories burned
- **Historical Data**: Maintains a complete history of your daily activity
- **Visual Analytics**:
  - Weekly progress bar chart
  - Overall statistics summary
  - Daily history list
- **Data Persistence**: All your data is saved locally using SharedPreferences
- **Clean UI**: Modern Material Design 3 interface with gradient backgrounds

## Screenshots

The app includes:
- Home screen with real-time step counter and daily stats
- Statistics screen with charts and historical data
- Activity status indicator (walking/stopped)

## How to Use

### On Android/iOS
1. **Grant Permissions**: On first launch, allow the app to access motion and fitness data
2. **Start Walking**: The app automatically starts counting your steps
3. **View Stats**: Tap the chart icon or "View Statistics" button to see:
   - Total steps across all days
   - Average daily steps
   - Total distance traveled
   - Total calories burned
   - Weekly progress chart
   - Complete daily history
4. **Clear Data**: Use the delete icon in the stats screen to clear all history

### On Linux/Desktop (Demo Mode)
Since step counting requires device sensors (accelerometer/gyroscope), the app runs in **demo mode** on Linux and desktop platforms:
- Manual step entry buttons (+100, +500, +1000) appear on the home screen
- Use these buttons to simulate step counting and test the statistics features
- All data storage and visualization features work normally

## Installation

### For Android Phone

**Quick Start** - See [QUICK_START_ANDROID.md](QUICK_START_ANDROID.md) for step-by-step instructions.

1. **Setup Android SDK** (one-time):
   ```bash
   ./setup_android_sdk.sh
   ```

2. **Connect your phone** via USB with USB debugging enabled

3. **Install the app**:
   ```bash
   flutter run --release
   ```

📖 Detailed guides:
- [QUICK_START_ANDROID.md](QUICK_START_ANDROID.md) - Simple 3-step guide
- [ANDROID_INSTALLATION.md](ANDROID_INSTALLATION.md) - Comprehensive installation guide
- [SETUP_ANDROID_SDK.md](SETUP_ANDROID_SDK.md) - Android SDK setup details

### For Linux/Desktop (Demo Mode)

1. Dependencies already installed ✓
2. Run the app:
   ```bash
   flutter run -d linux
   ```

See [LINUX_DEMO_MODE.md](LINUX_DEMO_MODE.md) for details about demo mode features.

## Dependencies

- `pedometer: ^4.0.2` - Step counting functionality
- `shared_preferences: ^2.3.3` - Local data storage
- `permission_handler: ^11.3.1` - Permission management
- `fl_chart: ^0.69.2` - Data visualization
- `intl: ^0.19.0` - Date formatting

## Platform Support

- **Android**: Full support with automatic step counting via device sensors
- **iOS**: Full support with automatic step counting via device sensors
- **Linux/Desktop/Web**: Demo mode with manual step entry (sensors not available)

## Permissions

### Android
- ACTIVITY_RECOGNITION - Required for step counting
- POST_NOTIFICATIONS - For potential future notification features

### iOS
- NSMotionUsageDescription - Access to motion and fitness data
- NSHealthShareUsageDescription - Read health data
- NSHealthUpdateUsageDescription - Update health data

### Linux/Desktop
- No special permissions required (runs in demo mode)

## Technical Details

- **Architecture**: Service-based architecture with separate concerns
  - Models: Data structures
  - Services: Business logic (PedometerService, StorageService)
  - Screens: UI components
- **State Management**: StatefulWidget with setState
- **Data Storage**: JSON serialization with SharedPreferences
- **Calculations**:
  - Distance: Average step length of 0.762 meters
  - Calories: Approximately 0.04 calories per step

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── models/
│   └── step_data.dart                # Step data model
├── services/
│   ├── pedometer_service.dart        # Step counting logic
│   └── storage_service.dart          # Data persistence
└── screens/
    ├── home_screen.dart              # Main pedometer screen
    └── stats_screen.dart             # Statistics and history
```

## Future Enhancements

- Daily step goals
- Achievement badges
- Export data to CSV
- Widget for home screen
- Dark mode support
- Social sharing

# Linux Demo Mode

The pedometer app successfully runs on Linux in **demo mode**.

## What Works on Linux

✅ **All UI features** - Complete user interface with beautiful design
✅ **Manual step entry** - Add steps using +100, +500, +1000 buttons
✅ **Data persistence** - All stats are saved using SharedPreferences
✅ **Statistics screen** - Full charts and history visualization
✅ **History tracking** - Daily step records with dates
✅ **Calculations** - Distance and calories computed correctly

## What Doesn't Work on Linux

❌ **Automatic step counting** - Requires device accelerometer/gyroscope sensors
❌ **Permission requests** - Activity recognition is mobile-only

## Why?

Step counting requires hardware sensors (accelerometer, gyroscope) that are only available on mobile devices. Desktop/laptop computers don't have the motion sensors needed for step detection.

## How to Use Demo Mode

1. Run the app: `flutter run -d linux`
2. You'll see an informational message about platform support
3. Use the manual step entry buttons at the bottom of the home screen:
   - **+100** - Add 100 steps
   - **+500** - Add 500 steps
   - **+1000** - Add 1000 steps
4. View statistics just like on mobile
5. All data persists between sessions

## Demo Mode Screenshot Features

- Warning banner explaining platform limitations
- Manual step entry controls
- Full statistics and charts
- History tracking

This makes the app perfect for:
- Testing the UI/UX design
- Demonstrating the statistics features
- Development and debugging
- Showcasing the app without a physical mobile device

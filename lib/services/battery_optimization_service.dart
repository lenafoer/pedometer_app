import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

/// BatteryOptimizationService helps users disable battery optimization
/// for the app, which is critical for reliable step counting.
///
/// Why this matters:
/// Phone manufacturers (especially Realme, Xiaomi, Huawei, Samsung, OnePlus)
/// add aggressive battery optimization that kills background apps even when
/// they're foreground services. This is the #1 cause of step counter failures.
///
/// Users must manually disable battery optimization in system settings.
class BatteryOptimizationService {
  static const platform = MethodChannel('com.example.pedometer_app/battery');

  /// Check if battery optimization is enabled for this app
  static Future<bool> isBatteryOptimizationEnabled() async {
    if (!Platform.isAndroid) return false;

    try {
      // Use permission_handler to check ignore battery optimization status
      final status = await Permission.ignoreBatteryOptimizations.status;
      return !status.isGranted;
    } catch (e) {
      debugPrint('Error checking battery optimization: $e');
      return true; // Assume it's enabled if we can't check
    }
  }

  /// Open system settings where user can disable battery optimization
  static Future<void> openBatteryOptimizationSettings() async {
    if (!Platform.isAndroid) return;

    try {
      await Permission.ignoreBatteryOptimizations.request();
    } catch (e) {
      debugPrint('Error opening battery optimization settings: $e');
    }
  }

  /// Get device-specific instructions for disabling battery optimization
  static String getDeviceSpecificInstructions() {
    // Try to detect manufacturer from device info
    // For now, provide generic + manufacturer-specific instructions
    return '''
For reliable step counting, please disable battery optimization:

1. Tap "Open Settings" below
2. Find "Simple Pedometer" in the list
3. Select "Don't optimize" or "Unrestricted"

DEVICE-SPECIFIC STEPS:

Realme/OnePlus:
• Settings > Battery > Battery Optimization > Simple Pedometer > Don't optimize
• Settings > App Management > Simple Pedometer > Battery Saver > No restrictions
• Settings > App Management > Auto Launch > Enable for Simple Pedometer

Xiaomi/MIUI:
• Settings > Apps > Manage apps > Simple Pedometer
• Battery saver > No restrictions
• Autostart > Enable
• Battery optimization > Don't optimize

Samsung:
• Settings > Apps > Simple Pedometer > Battery
• Allow background activity > Enable
• Optimize battery usage > All apps > Simple Pedometer > Don't optimize
• Settings > Device care > Battery > Background usage limits > Never sleeping apps > Add Simple Pedometer

Huawei:
• Settings > Battery > App launch > Simple Pedometer > Manage manually
• Enable all three options (Auto-launch, Secondary launch, Run in background)
• Settings > Battery > Simple Pedometer > Don't allow

Stock Android:
• Settings > Apps > Simple Pedometer > Battery
• Battery optimization > All apps > Simple Pedometer > Don't optimize
''';
  }
}

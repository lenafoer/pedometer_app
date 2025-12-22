import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/step_data.dart';
import 'database_service.dart';

class PedometerService {
  static const platform = MethodChannel('com.example.pedometer_app/step_service');
  static const eventChannel = EventChannel('com.example.pedometer_app/step_events');

  final DatabaseService _databaseService = DatabaseService();

  StreamSubscription<dynamic>? _eventSubscription;

  int _baselineSteps = 0;
  int _todaySteps = 0;
  int _lastCumulativeSteps = 0;
  int _lastValidSteps = 0;
  DateTime? _lastUpdateTime;

  bool _isInitialized = false;
  Function(int)? _onStepUpdateCallback;
  Function(String)? _onStatusUpdateCallback;

  String _status = 'Unknown';
  String get status => _status;
  int get todaySteps => _todaySteps;

  bool get isPlatformSupported {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  Future<bool> requestPermissions() async {
    if (!isPlatformSupported) {
      return false;
    }

    try {
      // Request activity recognition permission
      var status = await Permission.activityRecognition.status;

      if (status.isDenied) {
        status = await Permission.activityRecognition.request();
      }

      if (!status.isGranted) {
        return false;
      }

      // For Android 13+, also need notification permission for foreground service
      if (Platform.isAndroid) {
        var notificationStatus = await Permission.notification.status;
        if (notificationStatus.isDenied) {
          await Permission.notification.request();
        }
      }

      return status.isGranted;
    } catch (e) {
      debugPrint('Permission request error: $e');
      return false;
    }
  }

  Future<bool> isSensorAvailable() async {
    if (!isPlatformSupported) {
      return false;
    }

    try {
      if (Platform.isAndroid) {
        final bool available = await platform.invokeMethod('isSensorAvailable');
        return available;
      }
      return true; // iOS CoreMotion is generally available
    } catch (e) {
      debugPrint('Sensor availability check error: $e');
      return false;
    }
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    if (!isPlatformSupported) {
      _isInitialized = true;
      return;
    }

    // Check sensor availability first
    final sensorAvailable = await isSensorAvailable();
    if (!sensorAvailable) {
      throw Exception('Step counter sensor not available on this device');
    }

    // Request permissions
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      throw Exception('Activity recognition permission not granted');
    }

    // Load baseline from database
    await _loadBaselineFromDatabase();

    _isInitialized = true;
  }

  Future<void> _loadBaselineFromDatabase() async {
    final dateKey = _databaseService.getDateKey(DateTime.now());

    // Get first snapshot of today to establish baseline
    final firstSnapshot = await _databaseService.getFirstSnapshotOfDay(dateKey);

    if (firstSnapshot != null) {
      _baselineSteps = firstSnapshot['cumulative_steps'] as int;
      debugPrint('Loaded baseline from database: $_baselineSteps');
    }

    // Get latest snapshot to restore current state
    final latestSnapshot = await _databaseService.getLatestSnapshotOfDay(dateKey);

    if (latestSnapshot != null) {
      _todaySteps = latestSnapshot['daily_steps'] as int;
      _lastCumulativeSteps = latestSnapshot['cumulative_steps'] as int;
      debugPrint('Restored state - Today: $_todaySteps, Last cumulative: $_lastCumulativeSteps');
    }
  }

  Future<void> startListening(
    Function(int) onStepUpdate,
    Function(String) onError,
    Function(String)? onStatusUpdate,
  ) async {
    _onStepUpdateCallback = onStepUpdate;
    _onStatusUpdateCallback = onStatusUpdate;

    if (!isPlatformSupported) {
      _status = 'Unsupported Platform';
      onError('Step counting is only supported on Android and iOS devices.');
      return;
    }

    try {
      // Start foreground service on Android
      if (Platform.isAndroid) {
        await platform.invokeMethod('startService');
        _updateStatus('Service Started');
      }

      // Listen to step events from native side
      _eventSubscription = eventChannel.receiveBroadcastStream().listen(
        (dynamic event) async {
          if (event is Map) {
            final steps = (event['steps'] as num).toInt();
            await _processStepCount(steps, onStepUpdate);
          }
        },
        onError: (error) {
          debugPrint('Step event error: $error');
          onError('Step Count Error: $error');
        },
      );

      debugPrint('Started listening for step events');
    } catch (e) {
      debugPrint('Failed to start listening: $e');
      onError('Failed to start step counting: $e');
    }
  }

  Future<void> _processStepCount(int currentCumulativeSteps, Function(int) onStepUpdate) async {
    debugPrint('Processing step count: $currentCumulativeSteps');

    // Check if it's a new day
    final dateKey = _databaseService.getDateKey(DateTime.now());
    final firstSnapshot = await _databaseService.getFirstSnapshotOfDay(dateKey);

    if (firstSnapshot == null) {
      // First reading of the day - set baseline
      _baselineSteps = currentCumulativeSteps;
      _todaySteps = 0;
      _lastCumulativeSteps = currentCumulativeSteps;
      debugPrint('First reading of day - baseline set to: $_baselineSteps');

      await _saveSnapshot(currentCumulativeSteps, 0);
      onStepUpdate(0);
      return;
    }

    // Handle device reboot (cumulative steps decreased)
    if (currentCumulativeSteps < _lastCumulativeSteps) {
      debugPrint('Device reboot detected - resetting baseline');
      // Keep today's steps, just adjust baseline
      _baselineSteps = currentCumulativeSteps - _todaySteps;
      if (_baselineSteps < 0) {
        _baselineSteps = 0;
        _todaySteps = currentCumulativeSteps;
      }
    } else {
      // Normal update - calculate today's steps
      _todaySteps = currentCumulativeSteps - _baselineSteps;
    }

    // Validate step increase is reasonable
    if (_lastUpdateTime != null && _lastValidSteps > 0) {
      final timeDiff = DateTime.now().difference(_lastUpdateTime!).inSeconds;
      final stepDiff = _todaySteps - _lastValidSteps;

      if (timeDiff > 0 && stepDiff > 0) {
        final stepsPerMinute = (stepDiff / timeDiff) * 60;

        // Maximum realistic walking speed is ~200 steps/minute
        if (stepsPerMinute > 250) {
          debugPrint('Suspicious step increase detected: $stepsPerMinute steps/min - ignoring');
          return;
        }
      }
    }

    _lastCumulativeSteps = currentCumulativeSteps;
    _lastValidSteps = _todaySteps;
    _lastUpdateTime = DateTime.now();

    await _saveSnapshot(currentCumulativeSteps, _todaySteps);
    onStepUpdate(_todaySteps);

    _updateStatus('Walking');
  }

  Future<void> _saveSnapshot(int cumulativeSteps, int dailySteps) async {
    final distance = _calculateDistance(dailySteps);
    final calories = _calculateCalories(dailySteps);
    final dateKey = _databaseService.getDateKey(DateTime.now());

    await _databaseService.insertSnapshot(
      cumulativeSteps: cumulativeSteps,
      dailySteps: dailySteps,
      distance: distance,
      calories: calories,
      dateKey: dateKey,
    );
  }

  void _updateStatus(String newStatus) {
    _status = newStatus;
    _onStatusUpdateCallback?.call(newStatus);
  }

  double _calculateDistance(int steps) {
    const double averageStepLengthMeters = 0.762;
    return (steps * averageStepLengthMeters) / 1000;
  }

  int _calculateCalories(int steps) {
    const double caloriesPerStep = 0.04;
    return (steps * caloriesPerStep).round();
  }

  Future<void> addManualSteps(int steps) async {
    _todaySteps += steps;
    await _saveSnapshot(_lastCumulativeSteps, _todaySteps);
    _onStepUpdateCallback?.call(_todaySteps);
  }

  Future<List<StepData>> getHistory() async {
    return await _databaseService.getDailyHistory();
  }

  Future<void> cleanupOldData() async {
    await _databaseService.clearOldSnapshots(daysToKeep: 30);
  }

  void dispose() {
    _eventSubscription?.cancel();

    // Stop foreground service
    if (Platform.isAndroid) {
      try {
        platform.invokeMethod('stopService');
      } catch (e) {
        debugPrint('Error stopping service: $e');
      }
    }
  }
}

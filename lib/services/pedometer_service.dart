import 'dart:async';
import 'dart:io';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import '../models/step_data.dart';
import 'storage_service.dart';

class PedometerService {
  final StorageService _storageService = StorageService();

  Stream<StepCount>? _stepCountStream;
  Stream<PedestrianStatus>? _pedestrianStatusStream;
  StreamSubscription<StepCount>? _stepCountSubscription;
  Timer? _refreshTimer;

  int _initialSteps = 0;
  int _todaySteps = 0;
  int _lastDeviceSteps = 0;
  bool _isInitialized = false;
  Function(int)? _onStepUpdateCallback;

  String _status = 'Unknown';
  String get status => _status;
  int get todaySteps => _todaySteps;

  bool get isPlatformSupported {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  Future<bool> requestPermission() async {
    if (!isPlatformSupported) {
      return true;
    }

    try {
      final status = await Permission.activityRecognition.request();
      return status.isGranted;
    } catch (e) {
      return true;
    }
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    if (!isPlatformSupported) {
      _isInitialized = true;
      return;
    }

    final hasPermission = await requestPermission();
    if (!hasPermission) {
      throw Exception('Activity recognition permission not granted');
    }

    // Load saved baseline from when app was last used
    final savedBaseline = await _storageService.getTotalSteps();
    if (savedBaseline > 0) {
      _initialSteps = savedBaseline;
    }

    _stepCountStream = Pedometer.stepCountStream;
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;

    _isInitialized = true;
  }

  void startListening(Function(int) onStepUpdate, Function(String) onError) {
    _onStepUpdateCallback = onStepUpdate;

    if (!isPlatformSupported) {
      _status = 'Unsupported Platform';
      onError('Step counting is only supported on Android and iOS devices. You can still manually add steps for testing.');
      return;
    }

    // Start periodic refresh every 1 second to actively poll for step updates
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_lastDeviceSteps > 0) {
        await _processStepCount(_lastDeviceSteps, onStepUpdate);
      }
    });

    _pedestrianStatusStream?.listen(
      (PedestrianStatus event) {
        _status = event.status;
      },
      onError: (error) {
        _status = 'Stopped';
        onError('Pedestrian Status Error: $error');
      },
    );

    _stepCountSubscription = _stepCountStream?.listen(
      (StepCount event) async {
        _lastDeviceSteps = event.steps;
        await _processStepCount(event.steps, onStepUpdate);
      },
      onError: (error) {
        onError('Step Count Error: $error');
      },
    );
  }

  Future<void> _processStepCount(int currentDeviceSteps, Function(int) onStepUpdate) async {
    // Check if it's a new day - reset baseline if needed
    final isNewDay = await _storageService.isNewDay();
    if (isNewDay && _initialSteps != 0) {
      // New day detected - reset baseline to current device steps
      _initialSteps = currentDeviceSteps;
      _todaySteps = 0;
      await _storageService.saveTotalSteps(_initialSteps);
      await _updateTodayData(0);
      onStepUpdate(0);
      return;
    }

    // First time setup - save the device's current step count as baseline
    if (_initialSteps == 0) {
      final todayData = await _storageService.getTodayStepData();
      if (todayData != null && todayData.steps > 0 && !isNewDay) {
        // App was opened before today, calculate baseline from saved data
        _initialSteps = currentDeviceSteps - todayData.steps;
      } else {
        // First time today, use current device steps as baseline
        _initialSteps = currentDeviceSteps;
      }
      await _storageService.saveTotalSteps(_initialSteps);
    }

    // Calculate today's steps
    _todaySteps = currentDeviceSteps - _initialSteps;

    // Handle device reboot (step count resets to 0)
    if (_todaySteps < 0 || currentDeviceSteps < _initialSteps) {
      // Get today's saved total and add to it
      final todayData = await _storageService.getTodayStepData();
      if (todayData != null && todayData.steps > 0) {
        _initialSteps = currentDeviceSteps - todayData.steps;
      } else {
        _initialSteps = currentDeviceSteps;
      }
      _todaySteps = currentDeviceSteps - _initialSteps;
      if (_todaySteps < 0) _todaySteps = 0;
      await _storageService.saveTotalSteps(_initialSteps);
    }

    await _updateTodayData(_todaySteps);
    onStepUpdate(_todaySteps);
  }

  Future<void> refreshSteps() async {
    if (_onStepUpdateCallback != null && _lastDeviceSteps > 0) {
      await _processStepCount(_lastDeviceSteps, _onStepUpdateCallback!);
    }
  }

  Future<void> addManualSteps(int steps) async {
    _todaySteps += steps;
    await _updateTodayData(_todaySteps);
  }

  Future<void> _updateTodayData(int steps) async {
    final distance = _calculateDistance(steps);
    final calories = _calculateCalories(steps);

    final stepData = StepData(
      date: DateTime.now(),
      steps: steps,
      distance: distance,
      calories: calories,
    );

    await _storageService.saveStepData(stepData);
  }

  double _calculateDistance(int steps) {
    const double averageStepLengthMeters = 0.762;
    return (steps * averageStepLengthMeters) / 1000;
  }

  int _calculateCalories(int steps) {
    const double caloriesPerStep = 0.04;
    return (steps * caloriesPerStep).round();
  }

  Future<void> resetDailySteps() async {
    final currentTotal = await _storageService.getTotalSteps();
    _initialSteps = currentTotal + _todaySteps;
    await _storageService.saveTotalSteps(_initialSteps);
    _todaySteps = 0;
  }

  void dispose() {
    _stepCountSubscription?.cancel();
    _refreshTimer?.cancel();
  }
}

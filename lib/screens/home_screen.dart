import 'package:flutter/material.dart';
import '../services/pedometer_service.dart';
import '../services/storage_service.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final PedometerService _pedometerService = PedometerService();
  final StorageService _storageService = StorageService();

  int _steps = 0;
  double _distance = 0.0;
  int _calories = 0;
  int _walkingMinutes = 0;
  String _errorMessage = '';
  DateTime? _firstStepTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializePedometer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // App came to foreground, refresh steps immediately
      _refreshSteps();
    }
  }

  Future<void> _initializePedometer() async {
    try {
      await _pedometerService.initialize();
      _pedometerService.startListening(
        (steps) {
          setState(() {
            if (_steps == 0 && steps > 0 && _firstStepTime == null) {
              _firstStepTime = DateTime.now();
            }
            _steps = steps;
            _distance = _calculateDistance(steps);
            _calories = _calculateCalories(steps);
            _walkingMinutes = _calculateWalkingTime(steps);
          });
        },
        (error) {
          setState(() {
            _errorMessage = error;
          });
        },
      );

      final todayData = await _storageService.getTodayStepData();
      if (todayData != null) {
        setState(() {
          _steps = todayData.steps;
          _distance = todayData.distance;
          _calories = todayData.calories;
          _walkingMinutes = _calculateWalkingTime(todayData.steps);
          if (todayData.steps > 0) {
            _firstStepTime = todayData.date;
          }
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize: $e';
      });
    }
  }

  double _calculateDistance(int steps) {
    const double averageStepLengthMeters = 0.762;
    return (steps * averageStepLengthMeters) / 1000;
  }

  int _calculateCalories(int steps) {
    const double caloriesPerStep = 0.04;
    return (steps * caloriesPerStep).round();
  }

  int _calculateWalkingTime(int steps) {
    // Average walking speed: 100 steps per minute
    return (steps / 100).round();
  }

  Future<void> _refreshSteps() async {
    await _pedometerService.refreshSteps();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pedometerService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Pedometer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_errorMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.red.shade100,
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.directions_walk,
                    label: 'Steps',
                    value: _steps.toString(),
                    color: const Color(0xFFFF6B6B), // Pink
                    backgroundColor: const Color(0xFFFFF5F5), // Pale rose
                  ),
                ),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.straighten,
                    label: 'Distance',
                    value: '${_distance.toStringAsFixed(2)} km',
                    color: const Color(0xFF6B4C9A), // Dark violet
                    backgroundColor: const Color(0xFFE6E6FA), // Pale lilac
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.local_fire_department,
                    label: 'Calories',
                    value: '$_calories kcal',
                    color: const Color(0xFF00897B), // Dark turquoise
                    backgroundColor: const Color(0xFFE0F2F1), // Pale turquoise
                  ),
                ),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.timer,
                    label: 'Walking Time',
                    value: _formatWalkingTime(_walkingMinutes),
                    color: const Color(0xFF1976D2), // Blue
                    backgroundColor: const Color(0xFFE3F2FD), // Pale blue
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatWalkingTime(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return '${hours}h ${mins}m';
    }
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      color: backgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: color),
            const SizedBox(height: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

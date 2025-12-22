import '../models/step_data.dart';
import 'database_service.dart';

class StorageService {
  final DatabaseService _databaseService = DatabaseService();

  Future<void> saveStepData(StepData stepData) async {
    // This is now handled by database_service.dart
    // Kept for backward compatibility
  }

  Future<List<StepData>> getStepHistory() async {
    return await _databaseService.getDailyHistory();
  }

  Future<StepData?> getTodayStepData() async {
    final dateKey = _databaseService.getDateKey(DateTime.now());
    final snapshot = await _databaseService.getLatestSnapshotOfDay(dateKey);

    if (snapshot == null) return null;

    return StepData(
      date: DateTime.fromMillisecondsSinceEpoch(snapshot['timestamp'] as int),
      steps: snapshot['daily_steps'] as int,
      distance: snapshot['distance'] as double,
      calories: snapshot['calories'] as int,
    );
  }

  Future<Map<String, dynamic>> getStatistics() async {
    final history = await getStepHistory();

    if (history.isEmpty) {
      return {
        'totalSteps': 0,
        'averageSteps': 0,
        'totalDistance': 0.0,
        'totalCalories': 0,
        'daysTracked': 0,
      };
    }

    int totalSteps = 0;
    double totalDistance = 0.0;
    int totalCalories = 0;

    for (var data in history) {
      totalSteps += data.steps;
      totalDistance += data.distance;
      totalCalories += data.calories;
    }

    return {
      'totalSteps': totalSteps,
      'averageSteps': (totalSteps / history.length).round(),
      'totalDistance': totalDistance,
      'totalCalories': totalCalories,
      'daysTracked': history.length,
    };
  }

  Future<void> clearHistory() async {
    // Clear all data from database
    final db = await _databaseService.database;
    await db.delete('step_snapshots');
  }
}

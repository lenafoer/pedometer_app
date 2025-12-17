import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/step_data.dart';

class StorageService {
  static const String _stepHistoryKey = 'step_history';
  static const String _totalStepsKey = 'total_steps';

  Future<void> saveStepData(StepData stepData) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getStepHistory();

    final dateKey = _getDateKey(stepData.date);
    final existingIndex = history.indexWhere(
      (data) => _getDateKey(data.date) == dateKey,
    );

    if (existingIndex != -1) {
      history[existingIndex] = stepData;
    } else {
      history.add(stepData);
    }

    history.sort((a, b) => b.date.compareTo(a.date));

    final jsonList = history.map((data) => data.toJson()).toList();
    await prefs.setString(_stepHistoryKey, jsonEncode(jsonList));
  }

  Future<List<StepData>> getStepHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_stepHistoryKey);

    if (jsonString == null) {
      return [];
    }

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => StepData.fromJson(json)).toList();
  }

  Future<StepData?> getTodayStepData() async {
    final history = await getStepHistory();
    final today = DateTime.now();
    final todayKey = _getDateKey(today);

    return history.firstWhere(
      (data) => _getDateKey(data.date) == todayKey,
      orElse: () => StepData(date: today, steps: 0),
    );
  }

  Future<void> saveTotalSteps(int steps) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_totalStepsKey, steps);
    // Save the date when we saved this baseline
    await prefs.setString('last_baseline_date', _getDateKey(DateTime.now()));
  }

  Future<int> getTotalSteps() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_totalStepsKey) ?? 0;
  }

  Future<bool> isNewDay() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString('last_baseline_date');
    final todayKey = _getDateKey(DateTime.now());
    return lastDate != todayKey;
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_stepHistoryKey);
    await prefs.remove(_totalStepsKey);
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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
}

class StepData {
  final DateTime date;
  final int steps;
  final double distance;
  final int calories;

  StepData({
    required this.date,
    required this.steps,
    this.distance = 0.0,
    this.calories = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'steps': steps,
      'distance': distance,
      'calories': calories,
    };
  }

  factory StepData.fromJson(Map<String, dynamic> json) {
    return StepData(
      date: DateTime.parse(json['date']),
      steps: json['steps'],
      distance: json['distance'] ?? 0.0,
      calories: json['calories'] ?? 0,
    );
  }

  StepData copyWith({
    DateTime? date,
    int? steps,
    double? distance,
    int? calories,
  }) {
    return StepData(
      date: date ?? this.date,
      steps: steps ?? this.steps,
      distance: distance ?? this.distance,
      calories: calories ?? this.calories,
    );
  }
}

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/step_data.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'pedometer.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE step_snapshots (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp INTEGER NOT NULL,
            cumulative_steps INTEGER NOT NULL,
            daily_steps INTEGER NOT NULL,
            distance REAL NOT NULL,
            calories INTEGER NOT NULL,
            date_key TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE INDEX idx_date_key ON step_snapshots(date_key)
        ''');

        await db.execute('''
          CREATE INDEX idx_timestamp ON step_snapshots(timestamp)
        ''');
      },
    );
  }

  Future<void> insertSnapshot({
    required int cumulativeSteps,
    required int dailySteps,
    required double distance,
    required int calories,
    required String dateKey,
  }) async {
    final db = await database;
    await db.insert(
      'step_snapshots',
      {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'cumulative_steps': cumulativeSteps,
        'daily_steps': dailySteps,
        'distance': distance,
        'calories': calories,
        'date_key': dateKey,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getLatestSnapshot() async {
    final db = await database;
    final results = await db.query(
      'step_snapshots',
      orderBy: 'timestamp DESC',
      limit: 1,
    );

    if (results.isEmpty) return null;
    return results.first;
  }

  Future<Map<String, dynamic>?> getFirstSnapshotOfDay(String dateKey) async {
    final db = await database;
    final results = await db.query(
      'step_snapshots',
      where: 'date_key = ?',
      whereArgs: [dateKey],
      orderBy: 'timestamp ASC',
      limit: 1,
    );

    if (results.isEmpty) return null;
    return results.first;
  }

  Future<Map<String, dynamic>?> getLatestSnapshotOfDay(String dateKey) async {
    final db = await database;
    final results = await db.query(
      'step_snapshots',
      where: 'date_key = ?',
      whereArgs: [dateKey],
      orderBy: 'timestamp DESC',
      limit: 1,
    );

    if (results.isEmpty) return null;
    return results.first;
  }

  Future<List<StepData>> getDailyHistory() async {
    final db = await database;

    // Get the latest snapshot for each day
    final results = await db.rawQuery('''
      SELECT
        date_key,
        MAX(daily_steps) as steps,
        MAX(distance) as distance,
        MAX(calories) as calories,
        MAX(timestamp) as timestamp
      FROM step_snapshots
      GROUP BY date_key
      ORDER BY date_key DESC
      LIMIT 30
    ''');

    return results.map((row) {
      return StepData(
        date: DateTime.fromMillisecondsSinceEpoch(row['timestamp'] as int),
        steps: row['steps'] as int,
        distance: row['distance'] as double,
        calories: row['calories'] as int,
      );
    }).toList();
  }

  Future<void> clearOldSnapshots({int daysToKeep = 30}) async {
    final db = await database;
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
    final cutoffTimestamp = cutoffDate.millisecondsSinceEpoch;

    await db.delete(
      'step_snapshots',
      where: 'timestamp < ?',
      whereArgs: [cutoffTimestamp],
    );
  }

  String getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

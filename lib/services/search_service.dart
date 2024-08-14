import 'package:coaching_admin/models/student_search.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class StudentSearchService {
  static final StudentSearchService _instance =
      StudentSearchService._internal();
  factory StudentSearchService() => _instance;
  StudentSearchService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'student_search.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE students(id TEXT PRIMARY KEY, name TEXT, email TEXT, profileUrl TEXT)",
        );
      },
      version: 1,
    );
  }

  Future<void> insertStudent(StudentSearchModel student) async {
    final db = await database;
    await db.insert(
      'students',
      student.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<StudentSearchModel>> getStudents() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('students');

    return List.generate(maps.length, (i) {
      return StudentSearchModel.fromJson(maps[i]);
    });
  }

  Future<void> updateStudent(StudentSearchModel student) async {
    final db = await database;
    await db.update(
      'students',
      student.toJson(),
      where: "id = ?",
      whereArgs: [student.id],
    );
  }

  Future<void> deleteStudent(String id) async {
    final db = await database;
    await db.delete(
      'students',
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<void> clearStudents() async {
    final db = await database;
    await db.delete('students');
  }

  Future<void> clearStudentsWeekly() async {
    final prefs = await SharedPreferences.getInstance();
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    final String? lastClearDateStr = prefs.getString('lastClearDate');

    DateTime? lastClearDate;
    if (lastClearDateStr != null) {
      lastClearDate = dateFormat.parse(lastClearDateStr);
    }

    DateTime today = DateTime.now();
    // If the last clear date is not set or a week has passed
    if (lastClearDate == null || today.difference(lastClearDate).inDays >= 7) {
      // Clear the local database
      await clearStudents();
      // Update the last clear date
      await prefs.setString('lastClearDate', dateFormat.format(today));
    }
  }
}

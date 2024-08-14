import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coaching_admin/models/student_search.dart';
import 'package:coaching_admin/services/search_service.dart';
import 'package:flutter/foundation.dart';

class StudentSearchProvider with ChangeNotifier {
  final StudentSearchService _studentSearchService = StudentSearchService();

  bool _isLoading = true;
  List<StudentSearchModel> _students = [];
  List<StudentSearchModel> _filteredStudents = [];

  bool get isLoading => _isLoading;
  List<StudentSearchModel> get students => _students;
  List<StudentSearchModel> get filteredStudents => _filteredStudents;

  StudentSearchProvider() {
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    DateTime today = DateTime.now();
    List<StudentSearchModel> localStudents =
        await _studentSearchService.getStudents();

    if (localStudents.isEmpty) {
      List<StudentSearchModel> firestoreStudents =
          await fetchStudentsFromFirestore(null);
      _students = firestoreStudents;
      for (var student in firestoreStudents) {
        await _studentSearchService.insertStudent(student);
      }
    } else {
      List<StudentSearchModel> firestoreStudents =
          await fetchStudentsFromFirestore(today);
      _students = localStudents;
      for (var student in firestoreStudents) {
        await _studentSearchService.insertStudent(student);
        _students.add(student);
      }
    }

    _filteredStudents = _students;
    _isLoading = false; // Initially, filtered list is the same as the full list
    notifyListeners();
  }

  Future<void> insertStudent(StudentSearchModel student) async {
    await _studentSearchService.insertStudent(student);
    _students.add(student);
    _filteredStudents = _students; // Update filtered list
    notifyListeners();
  }

  Future<void> deleteStudent(String id) async {
    await _studentSearchService.deleteStudent(id);
    _students.removeWhere((student) => student.id == id);
    _filteredStudents = _students; // Update filtered list
    notifyListeners();
  }

  // Fetching data from Firestore
  Future<List<StudentSearchModel>> fetchStudentsFromFirestore(
      DateTime? today) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    QuerySnapshot snapshot;
    if (today != null) {
      snapshot = await db
          .collection('students')
          .where('timestamp', isGreaterThan: today)
          .get();
    } else {
      snapshot = await db.collection('students').get();
    }
    return snapshot.docs
        .map((doc) => StudentSearchModel.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // Search students by name
  void searchStudents(String query) {
    if (query.isNotEmpty) {
      _filteredStudents = _students
          .where((student) =>
              student.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } else {
      _filteredStudents = _students;
    }
    notifyListeners(); // Notify listeners about the change in filtered list
  }
}

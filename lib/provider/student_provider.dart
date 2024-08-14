import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coaching_admin/models/student.dart';
import 'package:coaching_admin/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Student> _students = [];
  List<Student> get students => _students;

  List<Student> _users = [];
  List<Student> get users => _users;

  List<Student> _alumni = [];
  List<Student> get alumni => _alumni;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  StudentProvider() {
    initialize();
  }

  Future<void> initialize() async {
    try {
      await fetchStudents();
      await fetchUsers();
      await fetchAlumni();
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> fetchStudents() async {
    try {
      final snapshot = await _firestoreService.readDocuments('students');
      _students = snapshot.docs
          .map((doc) =>
              Student.fromJson(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching students: $e');
    }
  }

  Future<void> fetchUsers() async {
    try {
      final snapshot = await _firestoreService.readDocuments('users');

      _users = snapshot.docs
          .map((doc) =>
              Student.fromJson(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  Future<void> fetchAlumni() async {
    try {
      final snapshot = await _firestoreService.readDocuments('alumni');
      _alumni = snapshot.docs
          .map((doc) =>
              Student.fromJson(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching alumni: $e');
    }
  }

  Future<void> addStudent(Student student) async {
    try {
      // Delete the document from the users collection if exists
      if (student.id != null) {
        await _firestoreService.deleteDocument('users', student.id!);
      }

      _users.removeWhere((user) => user.id == student.id);

      // Check if the email exists in the alumni collection
      QuerySnapshot studentsSnapshot = await _firestoreService
          .getDocumentsByField('students', 'email', student.email);

      if (studentsSnapshot.docs.isEmpty) {
        String? userId;
        // Check if the email exists in the alumni collection
        QuerySnapshot alumniSnapshot = await _firestoreService
            .getDocumentsByField('alumni', 'email', student.email);
        if (alumniSnapshot.docs.isNotEmpty) {
          userId = alumniSnapshot.docs.first.id;
        } else {
          // Create a new user with email and password
          UserCredential userCredential =
              await _auth.createUserWithEmailAndPassword(
            email: student.email,
            password: '12345678',
          );
          userId = userCredential.user!.uid;
        }

        // Add the student to the students collection
        await _firestoreService.createDocument(
            'students', userId, student.toJson());

        student.id = userId;

        // Update local list
        _students.add(student);
      }

      notifyListeners();
    } catch (e) {
      print('Error adding student: $e');
    }
  }

  Future<void> addAlumni(Student student) async {
    try {
      // Delete the document from the users collection if exists
      final String? id = student.id;
      if (id != null) {
        await deleteStudent(id);
      }

      _students.removeWhere((s) => s.id == id);

      String userId = id!;

      // Add the student to the alumni collection
      await _firestoreService.createDocument(
          'alumni', userId, student.toJson());

      // Update local list
      _alumni.add(student);
      notifyListeners();
    } catch (e) {
      print('Error adding alumni: $e');
    }
  }

  Future<void> updateStudent(String id, Student student) async {
    try {
      await _firestoreService.updateDocument('students', id, student.toJson());

      // Update local list
      int index = _students.indexWhere((s) => s.id == id);
      if (index != -1) {
        _students[index] = student;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating student: $e');
    }
  }

  Future<void> updateStudentField(
      String id, Map<String, dynamic> fieldData) async {
    try {
      await _firestoreService.updateDocument('students', id, fieldData);

      // Update the local list by modifying only the specified field
      int index = _students.indexWhere((s) => s.id == id);
      if (index != -1) {
        fieldData.forEach((key, value) {
          _students[index].updateField(key, value);
        });
        notifyListeners();
      }
    } catch (e) {
      print('Error updating student field: $e');
    }
  }

  Future<void> deleteStudent(String id) async {
    try {
      await _firestoreService.deleteStudentWithSubcollections(id);
      // Update local list
      _students.removeWhere((student) => student.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting student: $e');
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _firestoreService.deleteDocument('users', id);
      // Update local list
      _users.removeWhere((user) => user.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting student: $e');
    }
  }

  Future<void> deleteAlumnus(String id) async {
    try {
      await _firestoreService.deleteDocument('alumni', id);
      // Update local list
      _alumni.removeWhere((alumnus) => alumnus.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting student: $e');
    }
  }

  Student? getStudentById(String id) {
    return _students.firstWhere((student) => student.id == id);
  }

  Future<void> addSubcollectionDocument(String studentId,
      String subCollectionPath, Map<String, dynamic> data) async {
    try {
      await _firestoreService.createDocument('students', studentId, data,
          subCollectionPath: subCollectionPath);
      notifyListeners();
    } catch (e) {
      print('Error adding subcollection document: $e');
    }
  }

  Future<void> updateSubcollectionDocument(
      String studentId,
      String subCollectionPath,
      String subDocId,
      Map<String, dynamic> data) async {
    try {
      await _firestoreService.updateDocument('students', studentId, data,
          subCollectionPath: subCollectionPath, subDocId: subDocId);
      notifyListeners();
    } catch (e) {
      print('Error updating subcollection document: $e');
    }
  }
}

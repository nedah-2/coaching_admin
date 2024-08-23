import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coaching_admin/models/student.dart';
import 'package:coaching_admin/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Student> _students = [];
  List<Student> get students => _students;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  DocumentSnapshot? _lastDocument;

  bool _hasMoreStudents = true;
  bool get hasMoreStudents => _hasMoreStudents;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final int _limit = 8; // Number of documents to fetch per page

  StudentProvider() {
    initialize();
  }

  Future<void> initialize() async {
    try {
      await fetchStudents();
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> fetchStudents({bool loadMore = false}) async {
    if (_isLoading || !_hasMoreStudents) return;

    _isLoading = true;
    notifyListeners();

    try {
      if (loadMore) {
        await Future.delayed(const Duration(seconds: 1));
      }
      Query query =
          _firestore.collection('students').orderBy('name').limit(_limit);

      if (loadMore && _lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;

        final fetchedStudents = snapshot.docs
            .map((doc) =>
                Student.fromJson(doc.data() as Map<String, dynamic>, doc.id))
            .toList();

        if (loadMore) {
          _students.addAll(fetchedStudents);
        } else {
          _students = fetchedStudents;
        }

        if (fetchedStudents.length < _limit) {
          _hasMoreStudents = false; // No more documents to load
        }
      } else {
        _hasMoreStudents = false; // No more documents to load
      }

      notifyListeners();
    } catch (e) {
      print('Error fetching students: $e');
    } finally {
      _isLoading = false;
    }
  }

  Future<void> addStudent(Student student) async {
    try {
      // Delete the document from the users collection if exists
      if (student.id != null) {
        await _firestoreService.deleteDocument('users', student.id!);
      }

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
        _students.insert(0, student);
      }

      notifyListeners();
    } catch (e) {
      print('Error adding student: $e');
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

  Student? getStudentById(String id) {
    return _students.firstWhere((student) => student.id == id);
  }

  void resetPagination() {
    _lastDocument = null;
    _hasMoreStudents = true;
    _students.clear();
    fetchStudents();
  }
}

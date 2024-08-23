import 'package:flutter/material.dart';
import 'package:coaching_admin/models/student.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContactProvider with ChangeNotifier {
  final FirebaseFirestore _firestoreService = FirebaseFirestore.instance;

  List<Student> _contacts = [];
  List<Student> get contacts => _contacts;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  DocumentSnapshot? _lastDocument;

  bool _hasMoreContacts = true;
  bool get hasMoreContacts => _hasMoreContacts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final int _limit = 8; // Number of documents to fetch per page

  ContactProvider() {
    initialize();
  }

  Future<void> initialize() async {
    try {
      await fetchContacts();
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> fetchContacts({bool loadMore = false}) async {
    if (_isLoading || !_hasMoreContacts) return;

    _isLoading = true;
    notifyListeners();
    try {
      if (loadMore) {
        await Future.delayed(const Duration(seconds: 1));
      }
      Query query = _firestoreService
          .collection('users')
          .orderBy('startDate', descending: true)
          .limit(_limit);

      if (loadMore && _lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;

        final fetchedContacts = snapshot.docs
            .map((doc) =>
                Student.fromJson(doc.data() as Map<String, dynamic>, doc.id))
            .toList();

        if (loadMore) {
          _contacts.addAll(fetchedContacts);
        } else {
          _contacts = fetchedContacts;
        }

        if (fetchedContacts.length < _limit) {
          _hasMoreContacts = false; // No more documents to load
        }
      } else {
        _hasMoreContacts = false; // No more documents to load
      }

      notifyListeners();
    } catch (e) {
      print('Error fetching contacts: $e');
    } finally {
      _isLoading = false;
    }
  }

  Future<void> deleteContact(String id) async {
    try {
      await _firestoreService.collection("users").doc(id).delete();
      _contacts.removeWhere((contact) => contact.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting contact: $e');
    }
  }

  Future<void> deleteMemoryContact(String id) async {
    try {
      _contacts.removeWhere((contact) => contact.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting contact: $e');
    }
  }

  void resetPagination() {
    _lastDocument = null;
    _hasMoreContacts = true;
    _contacts.clear();
    fetchContacts();
  }
}

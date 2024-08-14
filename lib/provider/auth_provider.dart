import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // Import Firestore

class AuthManager extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Firestore instance
  User? _user;
  bool _isLoading = false;
  bool? _isAdmin; // New local variable for role

  AuthManager() {
    _initAuth();
  }

  void _initAuth() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        // Fetch role if user is logged in
        _fetchUserRole(user.email!);
      }
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool? get isAdmin => _isAdmin; // Getter for role

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _fetchUserRole(email);

      if (!_isAdmin!) {
        // Sign out the user if not an admin
        await signOut();
        throw Exception('You are not authorized to sign in.');
      }

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
    } catch (e) {
      // Handle sign-in errors
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _user = null;
      _isAdmin = null; // Clear role on sign out
    } catch (e) {
      // Handle sign-out errors
      debugPrint('Error signing out: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchUserRole(String email) async {
    try {
      // Fetch user document from Firestore
      DocumentSnapshot userSnapshot =
          await _firestore.collection('admins').doc(email).get();
      if (userSnapshot.exists) {
        // If user document exists, get role field
        _isAdmin = true;

        notifyListeners(); // Notify listeners after role is fetched
      }
    } catch (e) {
      // Handle error
      debugPrint('Error fetching user role: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _auth.sendPasswordResetEmail(email: email);
    } catch (error) {
      // Handle error
      debugPrint('Password Reset failed');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

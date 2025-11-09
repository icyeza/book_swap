import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _currentUser;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  String? get currentUserId => _currentUser?.uid;

  AuthProvider() {
    // Listen to auth state changes
    _authService.authStateChanges.listen((User? user) {
      _currentUser = user;
      if (user != null) {
        _loadUserData(user.uid);
      } else {
        _userModel = null;
      }
      notifyListeners();
    });
  }

  // Load user data from Firestore
  Future<void> _loadUserData(String userId) async {
    int attempts = 0;
    while (attempts < 3 && _userModel == null) {
      try {
        _userModel = await _authService.getUserData(userId);
        if (_userModel != null) break;
      } catch (e) {
        _error = e.toString();
      }
      attempts++;
      await Future.delayed(const Duration(milliseconds: 200));
    }
    notifyListeners();
  }

  // Sign up
  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign in
  Future<bool> signIn({required String email, required String password}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _currentUser = null;
      _userModel = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.sendPasswordResetEmail(email);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Resend email verification
  Future<bool> resendEmailVerification() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.resendEmailVerification();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Reload user
  Future<void> reloadUser() async {
    try {
      await _authService.reloadUser();
      _currentUser = _authService.currentUser;
      if (_currentUser != null) {
        await _loadUserData(_currentUser!.uid);
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Update notification settings
  Future<bool> updateNotificationSettings(Map<String, bool> settings) async {
    try {
      if (_currentUser == null) return false;

      await _authService.updateNotificationSettings(
        _currentUser!.uid,
        settings,
      );
      await _loadUserData(_currentUser!.uid);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

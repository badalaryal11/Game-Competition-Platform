import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../models/user.dart';
import '../repositories/user_repository.dart';

import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthProvider with ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  Future<AuthorizationCredentialAppleID?> signInWithApple() async {
    _isLoading = true;
    notifyListeners();

    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      _isLoading = false;
      notifyListeners();
      return credential;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signIn(String identifier, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _userRepository.validateUser(identifier, password);
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(User user) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _userRepository.saveUser(user);
      _currentUser = user;
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkUserExists(String email) async {
    final user = await _userRepository.getUserByEmail(email);
    return user != null;
  }

  Future<void> googleSignInSuccess(String email) async {
    final user = await _userRepository.getUserByEmail(email);
    if (user != null) {
      _currentUser = user;
      notifyListeners();
    }
  }

  void signOut() {
    _currentUser = null;
    notifyListeners();
  }

  Future<void> clearData() async {
    await _userRepository.deleteAllUsers();
    _currentUser = null;
    notifyListeners();
  }

  Future<String> sendVerificationCode(String contact) async {
    _isLoading = true;
    notifyListeners();

    final Completer<String> completer = Completer<String>();

    await fb.FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: contact,
      verificationCompleted: (fb.PhoneAuthCredential credential) async {
        await fb.FirebaseAuth.instance.signInWithCredential(credential);
        _isLoading = false;
        notifyListeners();
      },
      verificationFailed: (fb.FirebaseAuthException e) {
        _isLoading = false;
        notifyListeners();
        completer.completeError(e.message ?? 'Verification failed');
      },
      codeSent: (String verificationId, int? resendToken) {
        _isLoading = false;
        notifyListeners();
        completer.complete(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        if (!completer.isCompleted) {
          _isLoading = false;
          notifyListeners();
          completer.complete(verificationId);
        }
      },
    );

    return completer.future;
  }

  Future<bool> verifyCode(String verificationId, String smsCode) async {
    try {
      _isLoading = true;
      notifyListeners();

      fb.PhoneAuthCredential credential = fb.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await fb.FirebaseAuth.instance
          .signInWithCredential(credential);

      _isLoading = false;
      notifyListeners();
      return userCredential.user != null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> devLogin() async {
    _currentUser = User(
      email: 'dev@example.com',
      fullName: 'Developer',
      username: 'dev_user',
      phone: '+1234567890',
      password: 'password',
    );
    notifyListeners();
  }
}

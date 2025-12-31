import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../repositories/user_repository.dart';

class AuthProvider with ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

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
}

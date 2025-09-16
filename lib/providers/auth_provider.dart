import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../repositories/user_repository.dart';

class AuthProvider with ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _userRepository.validateUser(email, password);
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

  void signOut() {
    _currentUser = null;
    notifyListeners();
  }
}

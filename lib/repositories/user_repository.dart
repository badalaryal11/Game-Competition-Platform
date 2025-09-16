import '../helpers/database_helper.dart';
import '../models/user.dart';

class UserRepository {
  final _dbHelper = DatabaseHelper();

  Future<void> saveUser(User user) async {
    if (await _dbHelper.emailExists(user.email)) {
      throw Exception('Email already exists');
    }
    await _dbHelper.insertUser(user);
  }

  Future<User?> validateUser(String email, String password) async {
    final user = await _dbHelper.getUser(email, password);
    if (user == null) {
      throw Exception('Invalid email or password');
    }
    return user;
  }
}

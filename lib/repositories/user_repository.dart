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

  Future<User?> validateUser(String identifier, String password) async {
    final user = await _dbHelper.getUser(identifier, password);
    if (user == null) {
      throw Exception('Invalid email/phone or password');
    }
    return user;
  }

  Future<User?> getUserByEmail(String email) async {
    return await _dbHelper.getUserByEmail(email);
  }

  Future<void> deleteAllUsers() async {
    await _dbHelper.deleteAllUsers();
  }
}

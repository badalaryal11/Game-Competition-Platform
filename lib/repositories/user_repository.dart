import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // Fixed import
import '../models/user.dart';

class UserRepository {
  static const String _key = 'users';

  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await getUsers();

    if (users.any((u) => u.email == user.email)) {
      throw Exception('Email already exists');
    }

    users.add(user);
    await prefs.setString(
      _key,
      jsonEncode(users.map((u) => u.toJson()).toList()),
    );
  }

  Future<List<User>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return [];

    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((json) => User.fromJson(json)).toList();
  }

  Future<User?> validateUser(String email, String password) async {
    final users = await getUsers();
    return users.firstWhere(
      (user) => user.email == email && user.password == password,
      orElse: () => throw Exception('Invalid email or password'),
    );
  }
}

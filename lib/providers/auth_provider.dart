import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../dtos/user_dto.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  final _storage = const FlutterSecureStorage();

  User? get user => _user;
  bool get isAuthenticated => _user != null;

  Future<void> loadUser() async {
    final userData = await _storage.read(key: 'user_data');
    if (userData != null) {
      _user = User.fromJson(json.decode(userData));
      notifyListeners();
    }
  }

  Future<void> mockLogin() async {
    _user = const User(id: 1, name: 'Allan Xavier');
    await _storage.write(key: 'jwt_token', value: 'token_falso_seguro_123');
    await _storage.write(key: 'user_data', value: json.encode(_user!.toJson()));
    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    await _storage.deleteAll();
    notifyListeners();
  }
}

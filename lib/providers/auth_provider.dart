import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meu_projeto_faculdade/core/api_client.dart';
import 'package:meu_projeto_faculdade/core/api_config.dart';
import 'package:meu_projeto_faculdade/dtos/user_dto.dart';


class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient(baseUrl: ApiConfig.baseUrlReunioes);

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  String? get errorMessage => _errorMessage;

  
  Future<bool> mockLogin(String name, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Simula latência de rede
    await Future.delayed(const Duration(milliseconds: 1200));

    // Validação básica
    if (name.trim().isEmpty || password.trim().isEmpty) {
      _errorMessage = 'Preencha todos os campos.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

  
    if (password != '1234') {
      _errorMessage = 'Credenciais inválidas. Use a senha: 1234';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    
    _user = User(
      id: 1,
      name: name.trim(),
      token: 'mock_jwt_${DateTime.now().millisecondsSinceEpoch}',
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', json.encode({
      'id': _user!.id,
      'name': _user!.name,
      'token': _user!.token,
    }));

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> login(String name, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _apiClient.post(
      '/auth/login',
      body: {'name': name, 'password': password},
      withAuth: false,
    );

    return result.when(
      success: (data) async {
        if (data['status'] == 'ok' && data['data'] != null) {
          _user = User.fromJson(data['data']);

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user', json.encode(data['data']));

          _isLoading = false;
          notifyListeners();
          return true;
        }

        _errorMessage = data['message'] ?? 'Erro no login';
        _isLoading = false;
        notifyListeners();
        return false;
      },
      failure: (message, _) {
        _errorMessage = message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
    );
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      _user = User.fromJson(json.decode(userJson));
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    notifyListeners();
  }
}

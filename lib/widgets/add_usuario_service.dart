// lib/services/add_usuario_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../dtos/user_dto.dart';
import '../core/api_config.dart';

class AddUsuarioService {
  Future<bool> addUser(
    User user,
    String nome,
    String email,
    String senha,
  ) async {
    try {
      // Usaremos o baseUrl antigo mapeado no ApiConfig temporariamente
      final url = Uri.parse('${ApiConfig.baseUrlNode}/usuarios');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer ${user.token}',
        },
        body: json.encode({'nome': nome, 'email': email, 'senha': senha}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print('Erro ao adicionar usuário: $e');
      return false;
    }
  }
}

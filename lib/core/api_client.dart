import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meu_projeto_faculdade/core/result.dart';

/// Cliente HTTP centralizado com injeção automática do token JWT.
///
/// Toda a chamada HTTP da app deve passar por esta classe para garantir:
/// - Headers padronizados (Content-Type, Authorization)
/// - Tratamento de erros consistente via [Result]
/// - Log e interceção centralizados
class ApiClient {
  /// A URL base agora é dinâmica, permitindo ligar a diferentes microserviços.
  final String baseUrl;

  final http.Client _client;

  /// Construtor que exige a passagem da [baseUrl] de acordo com o serviço pretendido.
  ApiClient({required this.baseUrl, http.Client? client}) 
      : _client = client ?? http.Client();

  /// Recupera o token JWT armazenado no SharedPreferences.
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson == null) return null;
    final decoded = json.decode(userJson);
    return decoded['token'] as String?;
  }

  /// Monta os headers padrão, incluindo o Bearer token quando disponível.
  Future<Map<String, String>> _buildHeaders({bool withAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (withAuth) {
      final token = await _getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// Requisição GET.
  Future<Result<Map<String, dynamic>>> get(
    String path, {
    bool withAuth = true,
  }) async {
    try {
      final headers = await _buildHeaders(withAuth: withAuth);
      final response = await _client.get(
        Uri.parse('$baseUrl$path'),
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return Result.failure('Erro de conexão: ${e.toString()}');
    }
  }

  /// Requisição POST com body JSON.
  Future<Result<Map<String, dynamic>>> post(
    String path, {
    Map<String, dynamic>? body,
    bool withAuth = true,
  }) async {
    try {
      final headers = await _buildHeaders(withAuth: withAuth);
      final response = await _client.post(
        Uri.parse('$baseUrl$path'),
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      return Result.failure('Erro de conexão: ${e.toString()}');
    }
  }

  /// Requisição PUT com body JSON.
  Future<Result<Map<String, dynamic>>> put(
    String path, {
    Map<String, dynamic>? body,
    bool withAuth = true,
  }) async {
    try {
      final headers = await _buildHeaders(withAuth: withAuth);
      final response = await _client.put(
        Uri.parse('$baseUrl$path'),
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      return Result.failure('Erro de conexão: ${e.toString()}');
    }
  }

  /// Requisição PATCH com body JSON.
  Future<Result<Map<String, dynamic>>> patch(
    String path, {
    Map<String, dynamic>? body,
    bool withAuth = true,
  }) async {
    try {
      final headers = await _buildHeaders(withAuth: withAuth);
      final response = await _client.patch(
        Uri.parse('$baseUrl$path'),
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      return Result.failure('Erro de conexão: ${e.toString()}');
    }
  }

  /// Requisição DELETE.
  Future<Result<Map<String, dynamic>>> delete(
    String path, {
    bool withAuth = true,
  }) async {
    try {
      final headers = await _buildHeaders(withAuth: withAuth);
      final response = await _client.delete(
        Uri.parse('$baseUrl$path'),
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return Result.failure('Erro de conexão: ${e.toString()}');
    }
  }

  /// Interpreta a resposta HTTP e retorna um [Result].
  Result<Map<String, dynamic>> _handleResponse(http.Response response) {
    try {
      final decoded = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Result.success(decoded);
      }

      final message = decoded['message'] as String? ?? 'Erro desconhecido';
      return Result.failure(message, statusCode: response.statusCode);
    } catch (_) {
      return Result.failure(
        'Erro ao processar resposta (status: ${response.statusCode})',
        statusCode: response.statusCode,
      );
    }
  }

  /// Liberta os recursos do client HTTP.
  void dispose() {
    _client.close();
  }
}
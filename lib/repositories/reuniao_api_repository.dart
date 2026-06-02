import 'package:flutter/foundation.dart';
import 'package:meu_projeto_faculdade/core/api_client.dart';
import 'package:meu_projeto_faculdade/core/api_config.dart';
import 'package:flutter/foundation.dart';

/// Repositório de Reuniões conectado à API do Node.js.
/// Usa o [ApiClient] configurado com a URL das Reuniões.
class ReuniaoApiRepository {
  final ApiClient _apiClient;

  // Usa a URL centralizada do ApiConfig para o microserviço de Reuniões
  ReuniaoApiRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(baseUrl: ApiConfig.baseUrlReunioes);

    /// Cria uma nova reunião no backend Node.js
  Future<Map<String, dynamic>?> criarReuniao({
    required String assunto,
    required String local,
    required String data,
    required String horaInicio,
    required String horaFim,
  }) async {
    final result = await _apiClient.post(
      '/reunioes',
      body: {
        'assunto': assunto,
        'local': local,
        'data': data,
        'horaInicio': horaInicio,
        'horaFim': horaFim,
      },
    );

    return result.when(
      success: (data) => data,
      failure: (message, statusCode) {
        debugPrint('Erro ao criar reunião: $message');
        return null;
      },
    );
  }


  /// Busca todas as reuniões agendadas
  Future<List<dynamic>> getReunioes() async {
    final result = await _apiClient.get('/reunioes');

    return result.when(
      success: (data) {
        // Ajusta esta verificação consoante o formato de resposta do teu Node.js
        if (data['data'] != null) {
          return data['data'] as List;
        }
        return [];
      },
      failure: (_, __) => [],
    );
  }
}
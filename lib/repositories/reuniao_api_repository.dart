import 'package:meu_projeto_faculdade/core/api_client.dart';
import 'package:meu_projeto_faculdade/core/api_config.dart';

/// Repositório de Reuniões conectado à API do Node.js.
/// Usa o [ApiClient] configurado com a URL das Reuniões.
class ReuniaoApiRepository {
  final ApiClient _apiClient;

  // Usa a URL centralizada do ApiConfig para o microserviço de Reuniões
  ReuniaoApiRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(baseUrl: ApiConfig.baseUrlReunioes);

  /// Cria uma nova reunião no backend Node.js
  Future<Map<String, dynamic>?> criarReuniao({
    required String titulo,
    required String descricao,
    required String dataHora,
  }) async {
    // Ajusta o caminho '/reunioes' se a tua rota no Node.js for diferente
    final result = await _apiClient.post(
      '/reunioes', 
      body: {
        'titulo': titulo,
        'descricao': descricao,
        'dataHora': dataHora,
      },
    );

    return result.when(
      success: (data) {
        // Retorna os dados da reunião criada
        // Se tiveres um Modelo de Reunião, podes fazer o .fromJson(data) aqui
        return data; 
      },
      failure: (message, statusCode) {
        print('Erro ao criar reunião: $message');
        return null; // ou lançar uma exceção, dependendo de como geres erros na UI
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
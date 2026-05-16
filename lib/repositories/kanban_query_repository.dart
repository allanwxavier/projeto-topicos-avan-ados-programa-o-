import 'package:meu_projeto_faculdade/core/api_client.dart';
import 'package:meu_projeto_faculdade/core/api_config.dart';
import 'package:meu_projeto_faculdade/models/kanban_card_model.dart';

/// Repositório de QUERIES (leitura) do Kanban.
///
/// Responsabilidade única (SRP): buscar dados da read model mantida
/// pelo microserviço Laravel (porta 8000), que é alimentada via
/// eventos do RabbitMQ projetados em tabelas desnormalizadas.
///
/// Princípio CQRS: este repositório NUNCA faz POST/PUT/DELETE.
class KanbanQueryRepository {
  final ApiClient _apiClient;

  KanbanQueryRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient(baseUrl: ApiConfig.baseUrlPhp);

  /// Lista todos os cards da read model.
  ///
  /// O Laravel pode retornar a lista em dois formatos:
  /// 1. Lista direta:    { "data": [...] }
  /// 2. Lista paginada:  { "data": { "data": [...], "current_page": 1, ... } }
  ///
  /// Esse adapter cobre os dois casos sem quebrar quando o Dev 2 ajustar.
  Future<List<KanbanCardModel>> getCards() async {
    final result = await _apiClient.get('/cards');

    return result.when(
      success: (response) {
        final raw = response['data'];

        // Caso 1: { "data": [...] }
        if (raw is List) {
          return raw
              .map((e) => KanbanCardModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }

        // Caso 2: { "data": { "data": [...] } } (paginado)
        if (raw is Map<String, dynamic> && raw['data'] is List) {
          return (raw['data'] as List)
              .map((e) => KanbanCardModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }

        return <KanbanCardModel>[];
      },
      failure: (_, __) => <KanbanCardModel>[],
    );
  }

  /// Busca um card específico pelo ID.
  ///
  /// Útil para confirmar se um card recém-criado já foi projetado
  /// pelo Laravel (consistência eventual).
  Future<KanbanCardModel?> getCardById(String cardId) async {
    final result = await _apiClient.get('/cards/$cardId');
    return result.when(
      success: (response) {
        final data = response['data'];
        if (data == null) return null;
        return KanbanCardModel.fromJson(data as Map<String, dynamic>);
      },
      failure: (_, __) => null,
    );
  }
}

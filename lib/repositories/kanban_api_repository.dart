import 'package:meu_projeto_faculdade/core/api_client.dart';
import 'package:meu_projeto_faculdade/models/kanban_card_model.dart';

/// Repositório do Kanban conectado à API real do backend.
///
/// Substitui o [KanbanMockRepository] quando o app está em modo de
/// integração real (Fase 8). Usa [ApiClient] para chamadas HTTP
/// com JWT automático.
class KanbanApiRepository {
  final ApiClient _apiClient;

  KanbanApiRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Busca todos os cards do Kanban.
  Future<List<KanbanCardModel>> getCards() async {
    final result = await _apiClient.get('/kanban/cards');

    return result.when(
      success: (data) {
        if (data['status'] == 'ok' && data['data'] != null) {
          final list = data['data'] as List;
          return list.map((e) => KanbanCardModel.fromJson(e)).toList();
        }
        return <KanbanCardModel>[];
      },
      failure: (_, __) => <KanbanCardModel>[],
    );
  }

  /// Cria um novo card.
  Future<KanbanCardModel> createCard({
    required String title,
    String description = '',
    required String columnId,
    int priority = 0,
    String? assignee,
    List<String>? tags,
  }) async {
    final result = await _apiClient.post(
      '/kanban/cards',
      body: {
        'title': title,
        'description': description,
        'columnId': columnId,
        'priority': priority,
        'assignee': assignee,
        'tags': tags ?? [],
      },
    );

    return result.when(
      success: (data) {
        if (data['data'] != null) {
          return KanbanCardModel.fromJson(data['data']);
        }
        // Retorna um card local se o servidor não devolver dados completos
        return KanbanCardModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          description: description,
          columnId: columnId,
          priority: priority,
          assignee: assignee,
          tags: tags,
        );
      },
      failure: (_, __) {
        // Fallback: cria localmente
        return KanbanCardModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          description: description,
          columnId: columnId,
          priority: priority,
          assignee: assignee,
          tags: tags,
        );
      },
    );
  }

  /// Move um card para outra coluna.
  Future<KanbanCardModel?> moveCard(
      String cardId, String newColumnId) async {
    final result = await _apiClient.put(
      '/kanban/cards/$cardId/move',
      body: {'columnId': newColumnId},
    );

    return result.when(
      success: (data) {
        if (data['data'] != null) {
          return KanbanCardModel.fromJson(data['data']);
        }
        return null;
      },
      failure: (_, __) => null,
    );
  }

  /// Atualiza um card existente.
  Future<KanbanCardModel?> updateCard(
    String cardId, {
    String? title,
    String? description,
    int? priority,
    String? assignee,
    List<String>? tags,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (priority != null) body['priority'] = priority;
    if (assignee != null) body['assignee'] = assignee;
    if (tags != null) body['tags'] = tags;

    final result = await _apiClient.put(
      '/kanban/cards/$cardId',
      body: body,
    );

    return result.when(
      success: (data) {
        if (data['data'] != null) {
          return KanbanCardModel.fromJson(data['data']);
        }
        return null;
      },
      failure: (_, __) => null,
    );
  }

  /// Remove um card.
  Future<bool> deleteCard(String cardId) async {
    final result = await _apiClient.delete('/kanban/cards/$cardId');
    return result.isSuccess;
  }
}

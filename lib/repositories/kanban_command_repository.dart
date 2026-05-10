import 'package:meu_projeto_faculdade/core/api_client.dart';
import 'package:meu_projeto_faculdade/core/api_config.dart';
import 'package:meu_projeto_faculdade/models/kanban_card_model.dart';

/// Repositório de COMMANDS (escrita) do Kanban.
///
/// Responsabilidade única (SRP): enviar comandos de mutação para o
/// microserviço de escrita (Node.js — porta 8081). Nunca faz leitura.
///
/// Cada operação aqui dispara um evento no RabbitMQ no backend,
/// que é consumido pelo projetor do Laravel para alimentar a read model.
///
/// Princípio CQRS: este repositório NUNCA implementa GET.
class KanbanCommandRepository {
  final ApiClient _apiClient;

  KanbanCommandRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(baseUrl: ApiConfig.baseUrlNode);

  /// Cria um novo card no Write Model.
  /// 
  /// Lança [Exception] em caso de falha — o Provider trata e faz rollback
  /// do Optimistic UI.
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
        throw Exception('Resposta do Node sem payload "data".');
      },
      failure: (msg, statusCode) =>
          throw Exception('Falha ao criar card [$statusCode]: $msg'),
    );
  }

  /// Move um card para outra coluna.
  Future<KanbanCardModel> moveCard(String cardId, String newColumnId) async {
    final result = await _apiClient.put(
      '/kanban/cards/$cardId/move',
      body: {'columnId': newColumnId},
    );

    return result.when(
      success: (data) {
        if (data['data'] != null) {
          return KanbanCardModel.fromJson(data['data']);
        }
        throw Exception('Resposta do Node sem payload "data".');
      },
      failure: (msg, statusCode) =>
          throw Exception('Falha ao mover card [$statusCode]: $msg'),
    );
  }

  /// Atualiza campos de um card existente.
  Future<KanbanCardModel> updateCard(
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

    final result = await _apiClient.put('/kanban/cards/$cardId', body: body);

    return result.when(
      success: (data) {
        if (data['data'] != null) {
          return KanbanCardModel.fromJson(data['data']);
        }
        throw Exception('Resposta do Node sem payload "data".');
      },
      failure: (msg, statusCode) =>
          throw Exception('Falha ao atualizar card [$statusCode]: $msg'),
    );
  }

  /// Deleta um card.
  Future<void> deleteCard(String cardId) async {
    final result = await _apiClient.delete('/kanban/cards/$cardId');
    if (!result.isSuccess) {
      throw Exception('Falha ao deletar card.');
    }
  }
}
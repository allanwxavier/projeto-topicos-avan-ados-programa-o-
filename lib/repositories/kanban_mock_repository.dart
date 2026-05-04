import 'package:meu_projeto_faculdade/models/kanban_card_model.dart';

/// Repositório mock do Kanban.
/// Simula um banco de dados em memória com latência artificial
/// para garantir que a UI funcione independente do backend.
class KanbanMockRepository {
  // Colunas fixas do board
  static const List<KanbanColumnModel> columns = [
    KanbanColumnModel(id: 'backlog', title: 'Backlog'),
    KanbanColumnModel(id: 'todo', title: 'A Fazer'),
    KanbanColumnModel(id: 'doing', title: 'Em Progresso'),
    KanbanColumnModel(id: 'review', title: 'Revisão'),
    KanbanColumnModel(id: 'done', title: 'Concluído'),
  ];

  // "Banco de dados" em memória
  final List<KanbanCardModel> _cards = [
    KanbanCardModel(
      id: '1',
      title: 'Configurar ambiente Flutter',
      description: 'Instalar SDK, configurar emulador e rodar o hello world.',
      columnId: 'done',
      priority: 0,
      assignee: 'Allan',
      tags: ['setup', 'flutter'],
    ),
    KanbanCardModel(
      id: '2',
      title: 'Criar modelos de dados',
      description: 'Definir DTOs e models usados no Kanban e Reuniões.',
      columnId: 'done',
      priority: 1,
      assignee: 'Murilo',
      tags: ['backend', 'models'],
    ),
    KanbanCardModel(
      id: '3',
      title: 'Implementar tela de login',
      description: 'Login futurista com GlassCard e NeonButton.',
      columnId: 'doing',
      priority: 2,
      assignee: 'Allan',
      tags: ['ui', 'auth'],
    ),
    KanbanCardModel(
      id: '4',
      title: 'Integrar API de reuniões',
      description: 'Conectar CRUD de reuniões ao backend Express.',
      columnId: 'todo',
      priority: 1,
      assignee: 'Murilo',
      tags: ['api', 'backend'],
    ),
    KanbanCardModel(
      id: '5',
      title: 'WebSockets em tempo real',
      description: 'Configurar socket.io para atualização live do Kanban.',
      columnId: 'backlog',
      priority: 2,
      tags: ['websocket', 'realtime'],
    ),
    KanbanCardModel(
      id: '6',
      title: 'Testes unitários do backend',
      description: 'Cobrir auth e reunião service com Jest.',
      columnId: 'todo',
      priority: 0,
      assignee: 'Murilo',
      tags: ['test', 'backend'],
    ),
    KanbanCardModel(
      id: '7',
      title: 'Design do Kanban Board',
      description: 'Implementar drag & drop com visual cyberpunk.',
      columnId: 'review',
      priority: 1,
      assignee: 'Allan',
      tags: ['ui', 'kanban'],
    ),
    KanbanCardModel(
      id: '8',
      title: 'Deploy no Docker',
      description: 'Configurar docker-compose para ambiente de produção.',
      columnId: 'backlog',
      priority: 0,
      tags: ['devops'],
    ),
  ];

  int _nextId = 9;

  /// Simula latência de rede.
  Future<void> _simulateLatency() async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  /// Retorna todas as colunas do board.
  List<KanbanColumnModel> getColumns() => columns;

  /// Retorna todos os cards.
  Future<List<KanbanCardModel>> getCards() async {
    await _simulateLatency();
    return List.unmodifiable(_cards);
  }

  /// Retorna cards filtrados por coluna.
  Future<List<KanbanCardModel>> getCardsByColumn(String columnId) async {
    await _simulateLatency();
    return _cards.where((c) => c.columnId == columnId).toList();
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
    await _simulateLatency();
    final card = KanbanCardModel(
      id: (_nextId++).toString(),
      title: title,
      description: description,
      columnId: columnId,
      priority: priority,
      assignee: assignee,
      tags: tags,
    );
    _cards.add(card);
    return card;
  }

  /// Move um card para outra coluna.
  Future<KanbanCardModel?> moveCard(String cardId, String newColumnId) async {
    await _simulateLatency();
    final idx = _cards.indexWhere((c) => c.id == cardId);
    if (idx == -1) return null;

    _cards[idx].columnId = newColumnId;
    _cards[idx].updatedAt = DateTime.now();
    return _cards[idx];
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
    await _simulateLatency();
    final idx = _cards.indexWhere((c) => c.id == cardId);
    if (idx == -1) return null;

    if (title != null) _cards[idx].title = title;
    if (description != null) _cards[idx].description = description;
    if (priority != null) _cards[idx].priority = priority;
    if (assignee != null) _cards[idx].assignee = assignee;
    if (tags != null) _cards[idx].tags = tags;
    _cards[idx].updatedAt = DateTime.now();

    return _cards[idx];
  }

  /// Remove um card.
  Future<bool> deleteCard(String cardId) async {
    await _simulateLatency();
    _cards.removeWhere((c) => c.id == cardId);
    return true;
  }
}

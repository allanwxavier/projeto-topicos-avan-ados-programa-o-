import 'package:appflowy_board/appflowy_board.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:meu_projeto_faculdade/models/kanban_card_model.dart';
import 'package:meu_projeto_faculdade/repositories/kanban_mock_repository.dart';
import 'package:meu_projeto_faculdade/repositories/kanban_command_repository.dart';
import 'package:meu_projeto_faculdade/repositories/kanban_query_repository.dart';
import 'package:meu_projeto_faculdade/core/socket_service.dart';
import 'package:meu_projeto_faculdade/presentation/screens/kanban_board_screen.dart';

class KanbanProvider extends ChangeNotifier {
  final KanbanMockRepository _mockRepo = KanbanMockRepository();
  final KanbanCommandRepository _commandRepo = KanbanCommandRepository();
  final KanbanQueryRepository _queryRepo = KanbanQueryRepository();
  final SocketService _socketService = SocketService();
  final Uuid _uuid = const Uuid();

  late AppFlowyBoardController boardController;

  bool _isLoading = false;
  bool _useRealApi = false;
  bool _isRealtime = false;

  List<KanbanCardModel> _cards = [];

  bool get isLoading => _isLoading;
  bool get isRealtime => _isRealtime;
  bool get useRealApi => _useRealApi;
  List<KanbanCardModel> get cards => _cards;

  KanbanProvider() {
    boardController = AppFlowyBoardController(
      onMoveGroupItem: _onCardMoved,
      onMoveGroupItemToGroup: _onCardMovedToGroup,
    );
  }

  Future<void> loadCards() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_useRealApi) {
        _cards = await _queryRepo.getCards();
      } else {
        _cards = await _mockRepo.getCards();
      }
      _buildBoard();
    } catch (e) {
      debugPrint('Erro ao carregar cards: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void _buildBoard() {
    final columns = KanbanMockRepository.columns;
    boardController.clear();

    for (final col in columns) {
      final colCards = _cards
          .where((c) => c.columnId == col.id)
          .map((c) => KanbanCardItem(c))
          .toList();

      final group = AppFlowyGroupData(
        id: col.id,
        name: col.title,
        items: colCards,
      );

      boardController.addGroup(group);
    }
  }

  Future<void> addCard({
    required String title,
    String description = '',
    required String columnId,
    int priority = 0,
    String? assignee,
    List<String>? tags,
  }) async {
    if (!_useRealApi) {
      final newCard = await _mockRepo.createCard(
        title: title,
        description: description,
        columnId: columnId,
        priority: priority,
        assignee: assignee,
        tags: tags,
      );
      _cards.add(newCard);
      _buildBoard();
      notifyListeners();
      return;
    }

    final tempId = 'temp_${_uuid.v4()}';
    final optimisticCard = KanbanCardModel(
      id: tempId,
      title: title,
      description: description,
      columnId: columnId,
      priority: priority,
      assignee: assignee,
      tags: tags,
      syncStatus: SyncStatus.pending,
    );

    _cards.add(optimisticCard);
    _buildBoard();
    notifyListeners();

    try {
      final realCard = await _commandRepo.createCard(
        title: title,
        description: description,
        columnId: columnId,
        priority: priority,
        assignee: assignee,
        tags: tags,
      );

      final idx = _cards.indexWhere((c) => c.id == tempId);
      if (idx != -1) {
        _cards[idx] = realCard.copyWith(syncStatus: SyncStatus.syncing);

        _cards[idx] = realCard;
        _cards[idx].syncStatus = SyncStatus.syncing;
        _buildBoard();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erro ao criar card: $e');
      final idx = _cards.indexWhere((c) => c.id == tempId);
      if (idx != -1) {
        _cards[idx].syncStatus = SyncStatus.failed;
        _buildBoard();
        notifyListeners();

        await Future.delayed(const Duration(seconds: 3));
        _cards.removeWhere((c) => c.id == tempId);
        _buildBoard();
        notifyListeners();
      }
    }
  }

  void _onCardMoved(String groupId, int fromIndex, int toIndex) {
    // Reordenação dentro da mesma coluna — só notifica.
    notifyListeners();
  }

  void _onCardMovedToGroup(
    String fromGroupId,
    int fromIndex,
    String toGroupId,
    int toIndex,
  ) {
    final group = boardController.getGroupController(toGroupId);
    if (group == null) return;

    final item = group.items[toIndex] as KanbanCardItem;
    final cardId = item.card.id;

    _moveCard(cardId, fromGroupId, toGroupId);
  }

  Future<void> _moveCard(
    String cardId,
    String fromColumnId,
    String toColumnId,
  ) async {
    if (!_useRealApi) {
      await _mockRepo.moveCard(cardId, toColumnId);
      final idx = _cards.indexWhere((c) => c.id == cardId);
      if (idx != -1) _cards[idx].columnId = toColumnId;
      return;
    }

    final idx = _cards.indexWhere((c) => c.id == cardId);
    if (idx != -1) {
      _cards[idx].columnId = toColumnId;
      _cards[idx].syncStatus = SyncStatus.syncing;
      notifyListeners();
    }

    try {
      await _commandRepo.moveCard(cardId, toColumnId);
    } catch (e) {
      debugPrint('Erro ao mover card: $e');
      // Rollback: volta para a coluna original.
      if (idx != -1) {
        _cards[idx].columnId = fromColumnId;
        _cards[idx].syncStatus = SyncStatus.failed;
        _buildBoard();
        notifyListeners();
      }
    }
  }

  Future<void> switchToRealApi() async {
    _useRealApi = true;
    await _connectWebSocket();
    await loadCards();
  }

  Future<void> switchToMock() async {
    _useRealApi = false;
    _isRealtime = false;
    _socketService.disconnect();
    await loadCards();
  }

  Future<void> _connectWebSocket() async {
    _socketService.connect();

    _socketService.on('card:created', (data) {
      final card = KanbanCardModel.fromJson(data);
      final idx = _cards.indexWhere((c) => c.id == card.id);

      if (idx != -1) {
        _cards[idx].syncStatus = SyncStatus.confirmed;
      } else {
        // Veio de outro usuário.
        _cards.add(card);
      }
      _buildBoard();
      notifyListeners();
    });

    _socketService.on('card:moved', (data) {
      final cardId = data['cardId'].toString();
      final newColumn = data['columnId'].toString();
      final idx = _cards.indexWhere((c) => c.id == cardId);
      if (idx != -1) {
        _cards[idx].columnId = newColumn;
        _cards[idx].syncStatus = SyncStatus.confirmed;
        _buildBoard();
        notifyListeners();
      }
    });

    _socketService.on('card:updated', (data) {
      final card = KanbanCardModel.fromJson(data);
      final idx = _cards.indexWhere((c) => c.id == card.id);
      if (idx != -1) {
        _cards[idx] = card;
        _buildBoard();
        notifyListeners();
      }
    });

    _socketService.on('card:deleted', (data) {
      final cardId = data['cardId'].toString();
      _cards.removeWhere((c) => c.id == cardId);
      _buildBoard();
      notifyListeners();
    });

    _isRealtime = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _socketService.disconnect();
    boardController.dispose();
    super.dispose();
  }
}

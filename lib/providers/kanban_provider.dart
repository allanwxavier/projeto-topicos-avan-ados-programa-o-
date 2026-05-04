import 'package:appflowy_board/appflowy_board.dart';
import 'package:flutter/material.dart';
import 'package:meu_projeto_faculdade/models/kanban_card_model.dart';
import 'package:meu_projeto_faculdade/repositories/kanban_mock_repository.dart';
import 'package:meu_projeto_faculdade/repositories/kanban_api_repository.dart';
import 'package:meu_projeto_faculdade/core/socket_service.dart';
import 'package:meu_projeto_faculdade/presentation/screens/kanban_board_screen.dart';


class KanbanProvider extends ChangeNotifier {
  final KanbanMockRepository _mockRepo = KanbanMockRepository();
  final KanbanApiRepository _apiRepo = KanbanApiRepository();
  final SocketService _socketService = SocketService();

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

  // ─── Carregar cards ────────────────────────────────────────────

  Future<void> loadCards() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_useRealApi) {
        _cards = await _apiRepo.getCards();
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

  // ─── Construir o board AppFlowy ────────────────────────────────

  void _buildBoard() {
    // Limpa groups anteriores
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


  void _onCardMoved(String groupId, int fromIndex, int toIndex) {
    
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

    
    _moveCard(cardId, toGroupId);
  }

  Future<void> _moveCard(String cardId, String toColumnId) async {
    try {
      if (_useRealApi) {
        await _apiRepo.moveCard(cardId, toColumnId);
        // WebSocket broadcast é tratado pelo server
      } else {
        await _mockRepo.moveCard(cardId, toColumnId);
      }

      // Atualiza localmente
      final idx = _cards.indexWhere((c) => c.id == cardId);
      if (idx != -1) {
        _cards[idx].columnId = toColumnId;
      }
    } catch (e) {
      debugPrint('Erro ao mover card: $e');
    }
  }

  // ─── Adicionar card ────────────────────────────────────────────

  Future<void> addCard({
    required String title,
    String description = '',
    required String columnId,
    int priority = 0,
    String? assignee,
    List<String>? tags,
  }) async {
    try {
      KanbanCardModel newCard;
      if (_useRealApi) {
        newCard = await _apiRepo.createCard(
          title: title,
          description: description,
          columnId: columnId,
          priority: priority,
          assignee: assignee,
          tags: tags,
        );
      } else {
        newCard = await _mockRepo.createCard(
          title: title,
          description: description,
          columnId: columnId,
          priority: priority,
          assignee: assignee,
          tags: tags,
        );
      }

      _cards.add(newCard);

      final group = boardController.getGroupController(columnId);
      group?.add(KanbanCardItem(newCard));

      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao criar card: $e');
    }
  }


  /// Alterna para a API real e ativa WebSockets.
  Future<void> switchToRealApi() async {
    _useRealApi = true;
    await _connectWebSocket();
    await loadCards();
  }

  /// Volta para o mock (desconecta WebSocket).
  Future<void> switchToMock() async {
    _useRealApi = false;
    _isRealtime = false;
    _socketService.disconnect();
    await loadCards();
  }

  

  Future<void> _connectWebSocket() async {
    _socketService.connect();

    _socketService.on('card:moved', (data) {
      final cardId = data['cardId'].toString();
      final newColumn = data['columnId'].toString();
      final idx = _cards.indexWhere((c) => c.id == cardId);
      if (idx != -1) {
        _cards[idx].columnId = newColumn;
        _buildBoard();
        notifyListeners();
      }
    });

    _socketService.on('card:created', (data) {
      final card = KanbanCardModel.fromJson(data);
      if (!_cards.any((c) => c.id == card.id)) {
        _cards.add(card);
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

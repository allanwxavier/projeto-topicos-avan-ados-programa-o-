import 'package:flutter/foundation.dart';
import 'package:meu_projeto_faculdade/core/socket_service.dart';


class ReuniaoResumo {
  final int id;
  String status;
  DateTime atualizadoEm;

  ReuniaoResumo({
    required this.id,
    required this.status,
    DateTime? atualizadoEm,
  }) : atualizadoEm = atualizadoEm ?? DateTime.now();
}


class ReuniaoProvider extends ChangeNotifier {
  final SocketService _socket = SocketService.instance;

 
  int? _reuniaoAtualId;
  int? get reuniaoAtualId => _reuniaoAtualId;

  final Map<int, ReuniaoResumo> _reunioes = <int, ReuniaoResumo>{};
  Map<int, ReuniaoResumo> get reunioes => Map.unmodifiable(_reunioes);


  String? get statusAtual =>
      _reuniaoAtualId == null ? null : _reunioes[_reuniaoAtualId]?.status;


  final List<String> _historico = <String>[];
  List<String> get historico => List.unmodifiable(_historico);

  bool _ouvintesRegistrados = false;


  void _garantirConexao(String? token) {
    _socket.connect(token: token);

    if (_ouvintesRegistrados) return;
    _ouvintesRegistrados = true;

    _socket.on('reuniao:status_atualizado', _aoReceberStatus);
  }

  
  void entrarNaReuniao(int reuniaoId, {String? token}) {
    _garantirConexao(token);
    _reuniaoAtualId = reuniaoId;
    _reunioes.putIfAbsent(
      reuniaoId,
      () => ReuniaoResumo(id: reuniaoId, status: 'Aguardando…'),
    );
    _socket.entrarSalaReuniao(reuniaoId.toString());
    notifyListeners();
  }

  /// Chamado ao SAIR da tela (Tarefa 2: cancelar a assinatura).
  void sairDaReuniao() {
    final id = _reuniaoAtualId;
    if (id != null) {
      _socket.sairSalaReuniao(id.toString());
    }
    _reuniaoAtualId = null;
    notifyListeners();
  }


  void _aoReceberStatus(dynamic data) {
    try {
      final Map<String, dynamic> payload = Map<String, dynamic>.from(data);
      final int id = int.parse(payload['id'].toString());
      final String novoStatus =
          (payload['status'] ?? payload['novoStatus'] ?? '—').toString();

      final resumo = _reunioes[id];
      if (resumo != null) {
        resumo.status = novoStatus;
        resumo.atualizadoEm = DateTime.now();
      } else {
        _reunioes[id] = ReuniaoResumo(id: id, status: novoStatus);
      }

      _historico.insert(
        0,
        '[${DateTime.now().toIso8601String()}] reunião $id -> "$novoStatus"',
      );

      debugPrint('[ReuniaoProvider] status_atualizado: $id -> $novoStatus');


      notifyListeners();
    } catch (e) {
      debugPrint('[ReuniaoProvider] payload inválido: $e | data=$data');
    }
  }

  @override
  void dispose() {
    _socket.off('reuniao:status_atualizado');
    _ouvintesRegistrados = false;
    super.dispose();
  }

 
  @visibleForTesting
  void debugSimularStatusRecebido(dynamic data) => _aoReceberStatus(data);
}
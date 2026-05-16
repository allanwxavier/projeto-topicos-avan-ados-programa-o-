import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:meu_projeto_faculdade/core/api_config.dart';


/// Usado pelo indicador visual (Tarefa 1 do Ghabriel: "mostrar um indicador
/// visual se o socket cair"). A UI escuta [SocketService.statusListenable].
enum ConnectionStatus {
  
  disconnected,

  
  connecting,


  connected,

  
  reconnecting,
}


class SocketService {
  // ─── Singleton ────────────────────────────────────────────────
  SocketService._internal();
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  static SocketService get instance => _instance;

  io.Socket? _socket;

 
  final Set<String> _salasAtivas = <String>{};

  String? _token;

  
  final ValueNotifier<ConnectionStatus> _status =
      ValueNotifier<ConnectionStatus>(ConnectionStatus.disconnected);

  ValueListenable<ConnectionStatus> get statusListenable => _status;
  ConnectionStatus get status => _status.value;
  bool get isConnected => _socket?.connected ?? false;

 
  void connect({String? token}) {
    if (_socket != null && _token == token) return;

    _token = token;
    _status.value = ConnectionStatus.connecting;

    
    _socket?.dispose();

    _socket = io.io(
      ApiConfig.socketUrlNode,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
        
          .setAuth(token != null ? {'token': 'Bearer $token'} : {})
          
          .enableReconnection()
          .setReconnectionAttempts(9999)
          .setReconnectionDelay(2000) 
          .setReconnectionDelayMax(10000) 
          .build(),
    );

    _registrarListenersDeCicloDeVida();
    _socket!.connect();
  }

  void _registrarListenersDeCicloDeVida() {
    final socket = _socket;
    if (socket == null) return;

    socket.onConnect((_) {
      debugPrint('[SocketService] Conectado (${socket.id})');
      _status.value = ConnectionStatus.connected;
      
      for (final sala in _salasAtivas) {
        socket.emit('${_prefixoEvento(sala)}:join', _idDaSala(sala));
      }
    });

    socket.onDisconnect((motivo) {
      debugPrint('[SocketService] Desconectado: $motivo');
      _status.value = ConnectionStatus.disconnected;
    });

    socket.onConnectError((erro) {
      debugPrint('[SocketService] Erro de conexão: $erro');
      _status.value = ConnectionStatus.reconnecting;
    });

    socket.onError((erro) {
      debugPrint('[SocketService] Erro: $erro');
    });

   
    socket.onReconnectAttempt((tentativa) {
      debugPrint('[SocketService] Reconectando… (tentativa $tentativa)');
      _status.value = ConnectionStatus.reconnecting;
    });

    socket.onReconnect((_) {
      debugPrint('[SocketService] Reconectado com sucesso');
      _status.value = ConnectionStatus.connected;
    });

    socket.onReconnectFailed((_) {
      debugPrint('[SocketService] Falha definitiva ao reconectar');
      _status.value = ConnectionStatus.disconnected;
    });
  }

 
  void entrarSalaKanban(String kanbanId) =>
      _entrarSala('kanban', kanbanId);

  void sairSalaKanban(String kanbanId) => _sairSala('kanban', kanbanId);

  /// Entra na sala de uma Reunião (`reuniao_<id>` no backend).
  void entrarSalaReuniao(String reuniaoId) =>
      _entrarSala('reuniao', reuniaoId);

  void sairSalaReuniao(String reuniaoId) =>
      _sairSala('reuniao', reuniaoId);

  void _entrarSala(String prefixo, String id) {
    final chave = '${prefixo}_$id';
    _salasAtivas.add(chave);
    _socket?.emit('$prefixo:join', id);
    debugPrint('[SocketService] -> $prefixo:join $id');
  }

  void _sairSala(String prefixo, String id) {
    final chave = '${prefixo}_$id';
    _salasAtivas.remove(chave);
    _socket?.emit('$prefixo:leave', id);
    debugPrint('[SocketService] -> $prefixo:leave $id');
  }

  String _prefixoEvento(String chaveSala) => chaveSala.split('_').first;
  String _idDaSala(String chaveSala) =>
      chaveSala.substring(chaveSala.indexOf('_') + 1);

  

  void on(String event, void Function(dynamic) callback) =>
      _socket?.on(event, callback);

  void off(String event) => _socket?.off(event);

  void emit(String event, [dynamic data]) => _socket?.emit(event, data);


  void disconnect() {
    _salasAtivas.clear();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _token = null;
    _status.value = ConnectionStatus.disconnected;
  }
}
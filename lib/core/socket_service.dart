import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter/foundation.dart';

/// Serviço centralizado de WebSocket usando socket_io_client.
///
/// Conecta ao backend Node.js e permite escutar eventos em tempo real,
/// possibilitando que movimentações de cards sejam refletidas
/// instantaneamente entre dispositivos.
class SocketService {
  static const String _serverUrl = 'http://10.0.2.2:8080';

  io.Socket? _socket;

  bool get isConnected => _socket?.connected ?? false;

  /// Conecta ao servidor WebSocket.
  void connect({String? token}) {
    _socket = io.io(
      _serverUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setExtraHeaders(
              token != null ? {'Authorization': 'Bearer $token'} : {})
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('[SocketService] Conectado ao servidor');
    });

    _socket!.onDisconnect((_) {
      debugPrint('[SocketService] Desconectado do servidor');
    });

    _socket!.onConnectError((error) {
      debugPrint('[SocketService] Erro de conexão: $error');
    });

    _socket!.onError((error) {
      debugPrint('[SocketService] Erro: $error');
    });

    _socket!.connect();
  }

  /// Escuta um evento específico do servidor.
  void on(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
  }

  /// Remove listener de um evento.
  void off(String event) {
    _socket?.off(event);
  }

  /// Emite um evento para o servidor.
  void emit(String event, [dynamic data]) {
    _socket?.emit(event, data);
  }

  /// Desconecta do servidor.
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}

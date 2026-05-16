import 'package:flutter/material.dart';
import 'package:meu_projeto_faculdade/core/socket_service.dart';

class ConnectionStatusBanner extends StatelessWidget {
  const ConnectionStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ConnectionStatus>(
      valueListenable: SocketService.instance.statusListenable,
      builder: (context, status, _) {
    
        if (status == ConnectionStatus.connected) {
          return const SizedBox.shrink();
        }

        final (Color cor, IconData icone, String texto) = switch (status) {
          ConnectionStatus.connecting => (
              const Color(0xFFFBBF24),
              Icons.wifi_tethering_rounded,
              'Conectando ao servidor…',
            ),
          ConnectionStatus.reconnecting => (
              const Color(0xFFFBBF24),
              Icons.sync_rounded,
              'Conexão perdida — reconectando…',
            ),
          ConnectionStatus.disconnected => (
              const Color(0xFFEF4444),
              Icons.wifi_off_rounded,
              'Offline — sem tempo real',
            ),
          ConnectionStatus.connected => (
              Colors.green,
              Icons.check,
              '',
            ),
        };

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: cor.withValues(alpha: 0.15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icone, size: 16, color: cor),
              const SizedBox(width: 8),
              Text(
                texto,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: cor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
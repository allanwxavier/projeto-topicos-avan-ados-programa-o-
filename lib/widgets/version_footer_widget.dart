import 'package:flutter/material.dart';
import 'package:meu_projeto_faculdade/dtos/version_info.dart';
import 'package:meu_projeto_faculdade/repositories/version_api_repository.dart';
import 'package:meu_projeto_faculdade/theme/app_theme.dart';

/// Rodapé que consome /api/v1/version e exibe versão + tag de ambiente.
class VersionFooterWidget extends StatefulWidget {
  const VersionFooterWidget({super.key});

  @override
  State<VersionFooterWidget> createState() => _VersionFooterWidgetState();
}

class _VersionFooterWidgetState extends State<VersionFooterWidget> {
  final VersionApiRepository _repository = VersionApiRepository();
  late final Future<VersionInfo> _versionFuture;

  @override
  void initState() {
    super.initState();
    _versionFuture = _repository.getVersion();
  }

  /// Cor da tag conforme o ambiente retornado pela API.
  Color _environmentColor(String env) {
    switch (env.toLowerCase()) {
      case 'production':
      case 'prod':
        return AppTheme.neonGreen;
      case 'staging':
      case 'homolog':
        return const Color(0xFFFBBF24); // amber
      case 'development':
      case 'dev':
      case 'local':
        return AppTheme.neonCyan;
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: FutureBuilder<VersionInfo>(
        future: _versionFuture,
        builder: (context, snapshot) {
          // Estado 1: carregando
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _FooterText('Carregando versão...');
          }
          // Estado 2: erro / sem dados
          if (snapshot.hasError || !snapshot.hasData) {
            return const _FooterText('Versão indisponível');
          }
          // Estado 3: sucesso
          final info = snapshot.data!;
          final color = _environmentColor(info.environment);

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'v${info.version}',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              // Tag de ambiente: cor muda conforme o status vindo da API.
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: color.withValues(alpha: 0.5)),
                ),
                child: Text(
                  info.environment.toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Texto auxiliar dos estados de loading/erro.
class _FooterText extends StatelessWidget {
  final String text;
  const _FooterText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
    );
  }
}
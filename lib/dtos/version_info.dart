/// Metadados de versão retornados por GET /api/v1/version (backend Node).
/// Contrato: { version, environment, buildDate }
class VersionInfo {
  final String version;
  final String environment;
  final DateTime buildDate;

  const VersionInfo({
    required this.version,
    required this.environment,
    required this.buildDate,
  });

  /// Fallbacks seguros: se alguma chave vier nula/inválida, não derruba a UI.
  factory VersionInfo.fromJson(Map<String, dynamic> json) {
    return VersionInfo(
      version: (json['version'] as String?) ?? 'desconhecida',
      environment: (json['environment'] as String?) ?? 'unknown',
      buildDate:
          DateTime.tryParse(json['buildDate'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
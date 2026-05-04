import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Configurações centralizadas das URLs base dos microserviços.
///
/// Ao adicionar um novo microserviço, basta criar uma nova constante aqui.
/// Todos os repositórios e services consomem estas constantes, garantindo
/// que a troca de ambiente (dev/staging/prod) seja feita num único lugar.
class ApiConfig {
  ApiConfig._(); // impede instanciação

  /// Microserviço de Reuniões (Node.js / Prisma) — porta 8081
  static String get baseUrlReunioes => kIsWeb
      ? 'http://localhost:8081/api/v1'
      : Platform.isAndroid
      ? 'http://10.0.2.2:8081/api/v1'
      : 'http://127.0.0.1:8081/api/v1';

  /// Alias para manter compatibilidade com código que usa baseUrlNode
  static String get baseUrlNode => baseUrlReunioes;

  /// Microserviço do Kanban (PHP / Laravel) — porta 8000
  static String get baseUrlKanban => kIsWeb
      ? 'http://localhost:8000/api'
      : Platform.isAndroid
      ? 'http://10.0.2.2:8000/api'
      : 'http://127.0.0.1:8000/api';

  /// Alias para manter compatibilidade com código que usa baseUrlPhp
  static String get baseUrlPhp => baseUrlKanban;
}

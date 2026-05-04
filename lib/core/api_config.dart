/// Configurações centralizadas das URLs base dos microserviços.
///
/// Ao adicionar um novo microserviço, basta criar uma nova constante aqui.
/// Todos os repositórios e services consomem estas constantes, garantindo
/// que a troca de ambiente (dev/staging/prod) seja feita num único lugar.
class ApiConfig {
  ApiConfig._(); // impede instanciação

  /// Microserviço de Reuniões (Node.js / Prisma)
  static const String baseUrlReunioes = 'http://10.0.2.2:8081/api/v1';

  /// Microserviço do Kanban (PHP / Laravel)
  static const String baseUrlKanban = 'http://10.0.2.2:8000/api';
}

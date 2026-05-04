import 'package:meu_projeto_faculdade/core/api_client.dart';
import 'package:meu_projeto_faculdade/core/api_config.dart';
import 'package:meu_projeto_faculdade/core/result.dart';

/// Antes: usava `package:http` diretamente com token manual.
/// Agora: usa [ApiClient] (token JWT injetado automaticamente) e [Result]
/// para tratamento de erros padronizado.
class PegarParticipantesService {
  final ApiClient _apiClient;

  PegarParticipantesService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(baseUrl: ApiConfig.baseUrlReunioes);

  /// Busca os participantes de uma reunião pelo ID.
  ///
  /// Retorna [Result] com a lista de participantes em caso de sucesso,
  /// ou uma mensagem de erro em caso de falha.
  Future<Result<List<dynamic>>> getParticipantes(int idReuniao) async {
    final result = await _apiClient.post(
      '/reunioes/participantes/listar',
      body: {'idReuniao': idReuniao},
    );

    return result.when(
      success: (data) {
        if (data['status'] == 'ok' && data['data'] != null) {
          return Result.success(data['data'] as List<dynamic>);
        }
        return Result.failure(data['message'] ?? 'Nenhum dado retornado');
      },
      failure: (message, statusCode) {
        return Result.failure(message, statusCode: statusCode);
      },
    );
  }
}

/// Função legada mantida para compatibilidade reversa.
/// Delega para [PegarParticipantesService].
Future<dynamic> getParticipantes(dynamic idReuniao) async {
  final service = PegarParticipantesService();
  final result = await service.getParticipantes(
    int.parse(idReuniao.toString()),
  );

  return result.when(
    success: (data) => data,
    failure: (_, __) => null,
  );
}

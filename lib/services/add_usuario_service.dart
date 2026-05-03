import 'package:meu_projeto_faculdade/core/api_client.dart';
import 'package:meu_projeto_faculdade/core/result.dart';

/// Antes: usava `package:http` diretamente e montava headers manualmente.
/// Agora: usa [ApiClient] para injeção automática do JWT e [Result] para
/// tratamento de erros padronizado.
class AddUsuarioService {
  final ApiClient _apiClient;

  AddUsuarioService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Adiciona um participante a uma reunião.
  /// 
  /// Retorna [Result] com `true` em caso de sucesso ou mensagem de erro.
  Future<Result<bool>> addUsuarioReuniao(
    int idReuniao,
    int idParticipante,
  ) async {
    final result = await _apiClient.post(
      '/reunioes/participantes/adicionar',
      body: {
        'idReuniao': idReuniao,
        'idParticipante': idParticipante,
      },
    );

    return result.when(
      success: (data) {
        if (data['status'] == 'ok') {
          return Result.success(true);
        }
        return Result.failure(data['message'] ?? 'Erro desconhecido');
      },
      failure: (message, statusCode) {
        return Result.failure(message, statusCode: statusCode);
      },
    );
  }
}

/// Função legada mantida para compatibilidade reversa.
/// Delega para [AddUsuarioService].
Future<Map<String, dynamic>> addUsuarioReuniao(
    dynamic idReuniao, dynamic idParticipante) async {
  final service = AddUsuarioService();
  final result = await service.addUsuarioReuniao(
    int.parse(idReuniao.toString()),
    int.parse(idParticipante.toString()),
  );

  return result.when(
    success: (data) => {'data': true, 'message': 'Participante adicionado'},
    failure: (message, _) => {'data': false, 'message': message},
  );
}
import 'package:meu_projeto_faculdade/core/api_client.dart';
import 'package:meu_projeto_faculdade/core/api_config.dart';
import 'package:meu_projeto_faculdade/core/result.dart';
import 'package:meu_projeto_faculdade/dtos/version_info.dart';

/// Repositório dedicado ao consumo do endpoint de versão do microserviço Node.
/// Mesmo padrão de ReuniaoApiRepository (ApiClient + Result centralizados).
class VersionApiRepository {
  final ApiClient _apiClient;

  // baseUrlNode -> http://host:8081/api/v1 ; path /version -> /api/v1/version
  VersionApiRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(baseUrl: ApiConfig.baseUrlNode);

  /// Endpoint público: withAuth: false evita mandar Bearer token à toa.
  Future<VersionInfo> getVersion() async {
    final Result<Map<String, dynamic>> result =
        await _apiClient.get('/version', withAuth: false);

    return result.when(
      success: (data) => VersionInfo.fromJson(data),
      failure: (message, _) => throw Exception('Falha ao obter versão: $message'),
    );
  }
}
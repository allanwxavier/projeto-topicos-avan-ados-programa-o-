import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_config.dart';

class ApiClient {
  late final Dio nodeClient;
  late final Dio phpClient;
  final _storage = const FlutterSecureStorage();

  ApiClient() {
    nodeClient = _createDio(ApiConfig.baseUrlNode);
    phpClient = _createDio(ApiConfig.baseUrlPhp);
  }

  Dio _createDio(String baseUrl) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        contentType: 'application/json',
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'jwt_token');
          if (token != null) {
            options.headers['Authorization'] =
                'Bearer $token'; // <- Resolve o Bug 2
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );

    return dio;
  }
}

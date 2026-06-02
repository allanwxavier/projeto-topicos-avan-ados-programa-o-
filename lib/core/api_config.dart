import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;

class ApiConfig {
  ApiConfig._();

  static const String _prodUrl = 'https://meetsync-backend-2lz9.onrender.com';

  static String get _hostNode => kIsWeb
      ? 'localhost'
      : Platform.isAndroid
      ? '10.0.2.2'
      : '127.0.0.1';

  static const int portNode = 8081;

  static String get baseUrlReunioes => kReleaseMode 
      ? '$_prodUrl/api/v1' 
      : 'http://$_hostNode:$portNode/api/v1';

  static String get baseUrlNode => baseUrlReunioes;

  static String get socketUrlNode => kReleaseMode 
      ? _prodUrl 
      : 'http://$_hostNode:$portNode';

  static String get baseUrlKanban => kReleaseMode 
      ? '$_prodUrl/api/v1'
      : (kIsWeb
          ? 'http://localhost:8000/api'
          : Platform.isAndroid
          ? 'http://10.0.2.2:8000/api'
          : 'http://127.0.0.1:8000/api');

  static String get baseUrlPhp => baseUrlKanban;
}

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  ApiConfig._();

  static String get _hostNode => kIsWeb
      ? 'localhost'
      : Platform.isAndroid
      ? '10.0.2.2'
      : '127.0.0.1';

  static const int portNode = 8081;

  static String get baseUrlReunioes => 'http://$_hostNode:$portNode/api/v1';

  static String get baseUrlNode => baseUrlReunioes;

  static String get socketUrlNode => 'http://$_hostNode:$portNode';

  static String get baseUrlKanban => kIsWeb
      ? 'http://localhost:8000/api'
      : Platform.isAndroid
      ? 'http://10.0.2.2:8000/api'
      : 'http://127.0.0.1:8000/api';

  static String get baseUrlPhp => baseUrlKanban;
}

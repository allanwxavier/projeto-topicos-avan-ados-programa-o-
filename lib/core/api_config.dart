import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static String get baseUrlNode => kIsWeb
      ? 'http://localhost:8080/api/v1'
      : Platform.isAndroid
      ? 'http://10.0.2.2:8080/api/v1'
      : 'http://127.0.0.1:8080/api/v1';

  static String get baseUrlPhp => kIsWeb
      ? 'http://localhost:8000/api'
      : Platform.isAndroid
      ? 'http://10.0.2.2:8000/api'
      : 'http://127.0.0.1:8000/api';
}

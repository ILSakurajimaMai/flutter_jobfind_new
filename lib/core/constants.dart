// File hằng số chứa các đường dẫn API và biến toàn cục.
import 'package:flutter/foundation.dart';

class Constants {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }
    return 'http://10.0.2.2:5000/api'; // Android Emulator
  }

  static String get hubUrl {
    return baseUrl.replaceAll('/api', '/hubs/chat');
  }
}

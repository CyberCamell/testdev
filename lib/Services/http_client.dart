import 'dart:io';
import 'package:http/http.dart' as http;

class CustomHttpClient {
  static http.Client? _client;

  static http.Client getClient() {
    if (_client == null) {
      // Create HttpClient with SSL certificate verification disabled
      final httpClient = HttpClient();
      httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      _client = http.IOClient(httpClient);
    }
    return _client!;
  }

  static void disposeClient() {
    _client?.close();
    _client = null;
  }
} 
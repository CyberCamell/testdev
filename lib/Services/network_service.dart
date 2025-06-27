import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:http/io_client.dart';

class NetworkService {
  static const Duration _cacheDuration = Duration(minutes: 5);
  static final Map<String, dynamic> _cache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  
  // Create a custom HTTP client that bypasses SSL certificate verification
  static http.Client? _httpClient;
  
  static http.Client _getHttpClient() {
    if (_httpClient == null) {
      // Override the HttpClient to disable certificate verification
      final httpClient = HttpClient();
      httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      _httpClient = IOClient(httpClient);
    }
    return _httpClient!;
  }

  static Future<dynamic> get(String url, {bool useCache = true}) async {
    if (useCache) {
      final cachedData = _getCachedData(url);
      if (cachedData != null) {
        return cachedData;
      }
    }

    try {
      final client = _getHttpClient();
      final response = await client.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (useCache) {
          _cacheData(url, data);
        }
        return data;
      }
      throw Exception('Failed to load data');
    } catch (e) {
      rethrow;
    }
  }

  static Future<dynamic> post(String url, Map<String, dynamic> body) async {
    try {
      final client = _getHttpClient();
      final response = await client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to post data');
    } catch (e) {
      rethrow;
    }
  }

  static void _cacheData(String url, dynamic data) {
    _cache[url] = data;
    _cacheTimestamps[url] = DateTime.now();
  }

  static dynamic _getCachedData(String url) {
    final timestamp = _cacheTimestamps[url];
    if (timestamp != null) {
      final age = DateTime.now().difference(timestamp);
      if (age < _cacheDuration) {
        return _cache[url];
      } else {
        _cache.remove(url);
        _cacheTimestamps.remove(url);
      }
    }
    return null;
  }

  static void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }
}

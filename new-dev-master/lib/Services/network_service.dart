import 'dart:convert';
import 'package:http/http.dart' as http;

class NetworkService {
  static const Duration _cacheDuration = Duration(minutes: 5);
  static final Map<String, dynamic> _cache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};

  static Future<dynamic> get(String url, {bool useCache = true}) async {
    if (useCache) {
      final cachedData = _getCachedData(url);
      if (cachedData != null) {
        return cachedData;
      }
    }

    try {
      final response = await http.get(Uri.parse(url));
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
      final response = await http.post(
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

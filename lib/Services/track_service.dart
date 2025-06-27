import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'auth_service.dart'; // Import AuthService to get the token
import '../models/track.dart'; // Import the Track model
import '../models/language.dart'; // Import the Language model
import '../models/term.dart';

class TrackService {
  // Use the same base URL as AuthService. Avoid direct dependency if possible in larger apps (e.g., use config).
  static const String _baseUrl =
      'https://api.devguide.help';

  // Method to fetch all tracks
  static Future<List<Track>> getTracks({
    String? query,
    String? category,
  }) async {
    final url = Uri.parse('$_baseUrl/api/tracks/');

    try {
      final token = await AuthService.getAccessToken(); // Handles refresh
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        // Use the imported Track model's fromJson factory
        final List<Track> tracks =
            data.map((json) => Track.fromJson(json)).toList();
        return tracks;
      } else {
        if (kDebugMode) {
          print(
            'Failed to fetch tracks: ${response.statusCode} ${response.body}',
          );
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching tracks: $e');
      }
      return [];
    }
  }

  // Method to fetch favorite tracks
  static Future<List<Track>> getFavoriteTracks() async {
    final url = Uri.parse("$_baseUrl/api/tracks/favorites/");

    try {
      final token = await AuthService.getAccessToken();
      if (token == null) {
        if (kDebugMode) print("Cannot fetch favorites: Not logged in.");
        return [];
      }

      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };

      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        // Use the imported Track model's fromJson factory
        final List<Track> tracks =
            data.map((json) => Track.fromJson(json)).toList();
        return tracks;
      } else {
        if (kDebugMode) {
          print(
            "Failed to fetch favorite tracks: ${response.statusCode} ${response.body}",
          );
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching favorite tracks: $e");
      }
      return [];
    }
  }

  // Method to add a track to favorites
  static Future<bool> addFavoriteTrack(int trackId) async {
    final url = Uri.parse("$_baseUrl/api/tracks/favorite/add/$trackId/");
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) return false;

      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };

      final response = await http
          .post(url, headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        if (kDebugMode) {
          print(
            "Failed to add favorite: ${response.statusCode} ${response.body}",
          );
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error adding favorite: $e");
      }
      return false;
    }
  }

  // Method to remove a track from favorites
  static Future<bool> removeFavoriteTrack(int trackId) async {
    final url = Uri.parse("$_baseUrl/api/tracks/favorite/remove/$trackId/");
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) return false;

      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };

      final response = await http
          .delete(url, headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 204) {
        // 204 No Content is common for delete operations
        return true;
      } else {
        if (kDebugMode) {
          print(
            "Failed to remove favorite: ${response.statusCode} ${response.body}",
          );
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error removing favorite: $e");
      }
      return false;
    }
  }

  static Future<Track?> getTrackDetail(int trackId) async {
    final url = Uri.parse("$_baseUrl/api/tracks/$trackId/");
    try {
      final token = await AuthService.getAccessToken();
      final headers = {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      };
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        return Track.fromJson(jsonDecode(response.body));
      }
      if (kDebugMode) {
        print("Failed to fetch track detail: ${response.statusCode} ${response.body}");
      }
      return null;
    } catch (e) {
      if (kDebugMode) print("Error fetching track detail: $e");
      return null;
    }
  }

  static Future<List<Language>> getLanguages() async {
    final url = Uri.parse("$_baseUrl/api/languages/");
    try {
      final token = await AuthService.getAccessToken();
      final headers = {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      };

      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Language.fromJson(json)).toList();
      } else {
        if (kDebugMode) {
          print("Failed to fetch languages: ${response.statusCode} ${response.body}");
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching languages: $e");
      }
      return [];
    }
  }

  static Future<List<Language>> getFavoriteLanguages() async {
    final url = Uri.parse("$_baseUrl/api/languages/favorites/");
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) {
        if (kDebugMode) print("Cannot fetch favorite languages: Not logged in.");
        return [];
      }

      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };

      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Language.fromJson(json)).toList();
      } else {
        if (kDebugMode) {
          print("Failed to fetch favorite languages: ${response.statusCode} ${response.body}");
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching favorite languages: $e");
      }
      return [];
    }
  }

  static Future<bool> addFavoriteLanguage(int languageId) async {
    final url = Uri.parse("$_baseUrl/api/languages/favorite/add/$languageId/");
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) return false;

      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };

      final response = await http
          .post(url, headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        if (kDebugMode) {
          print("Failed to add favorite language: ${response.statusCode} ${response.body}");
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error adding favorite language: $e");
      }
      return false;
    }
  }

  static Future<bool> removeFavoriteLanguage(int languageId) async {
    final url = Uri.parse("$_baseUrl/api/languages/favorite/remove/$languageId/");
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) return false;

      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };

      final response = await http
          .delete(url, headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        if (kDebugMode) {
          print("Failed to remove favorite language: ${response.statusCode} ${response.body}");
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error removing favorite language: $e");
      }
      return false;
    }
  }

  static Future<List<Language>> getTrackLanguages(int trackId) async {
    // Using the same endpoint structure as the JavaScript code
    final url = Uri.parse("$_baseUrl/api/tracks/$trackId/");
    if (kDebugMode) {
      print("Fetching track details for track $trackId from URL: $url");
    }
    try {
      final token = await AuthService.getAccessToken();
      final headers = {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      };

      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print("Track response status: ${response.statusCode}");
        print("Track response body: ${response.body}");
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Extract languages from the track data
        final List<dynamic> languagesData = data['languages'] ?? [];
        final languages = languagesData.map((json) => Language.fromJson(json)).toList();
        if (kDebugMode) {
          print("Parsed ${languages.length} languages for track $trackId");
        }
        return languages;
      } else {
        if (kDebugMode) {
          print("Failed to fetch track: ${response.statusCode} ${response.body}");
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching track: $e");
      }
      return [];
    }
  }

  static Future<Language?> getLanguageById(int languageId) async {
    final url = Uri.parse("$_baseUrl/api/languages/$languageId/");
    try {
      final token = await AuthService.getAccessToken();
      final headers = {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      };

      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Language.fromJson(data);
      } else {
        if (kDebugMode) {
          print("Failed to fetch language: ${response.statusCode} ${response.body}");
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching language: $e");
      }
      return null;
    }
  }

  static Future<List<Term>> getLanguageTerms(String languageName) async {
    final url = Uri.parse("$_baseUrl/api/languages/$languageName/terms/");
    try {
      final token = await AuthService.getAccessToken();
      final headers = {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      };

      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Term.fromJson(json)).toList();
      } else {
        if (kDebugMode) {
          print("Failed to fetch language terms: ${response.statusCode} ${response.body}");
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching language terms: $e");
      }
      return [];
    }
  }

  // static Future<List<Track>> searchTracks(String query) async { ... }
}

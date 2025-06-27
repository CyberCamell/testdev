import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String _userDataKey = 'user_data';
  static const String _tokensKey = 'tokens';
  static const String _settingsKey = 'settings';

  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userDataKey, jsonEncode(userData));
    } catch (e) {
      print('Error saving user data: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(_userDataKey);
      if (userDataString != null) {
        return jsonDecode(userDataString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  static Future<void> saveTokens(Map<String, dynamic> tokens) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokensKey, jsonEncode(tokens));
    } catch (e) {
      print('Error saving tokens: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tokensString = prefs.getString(_tokensKey);
      if (tokensString != null) {
        return jsonDecode(tokensString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting tokens: $e');
      return null;
    }
  }

  static Future<void> saveSettings(Map<String, dynamic> settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_settingsKey, jsonEncode(settings));
    } catch (e) {
      print('Error saving settings: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsString = prefs.getString(_settingsKey);
      if (settingsString != null) {
        return jsonDecode(settingsString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting settings: $e');
      return null;
    }
  }

  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      print('Error clearing cache: $e');
      rethrow;
    }
  }
} 
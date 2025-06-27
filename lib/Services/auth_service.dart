import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _baseUrl =
      'https://api.devguide.help';
  static const String _tokenKey = 'auth_token';
  static const String _isGuestKey = 'is_guest';
  static const String _resetTokenKey = 'reset_token';
  static const String _resetEmailKey = 'reset_email';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _rememberMeKey = 'remember_me';
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> _getPrefs() async {
    if (_prefs == null) {
      try {
        _prefs = await SharedPreferences.getInstance();
      } catch (e) {
        if (kDebugMode) {
          print('Error initializing SharedPreferences: $e');
        }
        rethrow;
      }
    }
    return _prefs!;
  }

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required Map<String, dynamic> userData,
    bool rememberMe = false,
  }) async {
    try {
      final prefs = await _getPrefs();

      // Save tokens
      await prefs.setString(_accessTokenKey, accessToken);
      await prefs.setString(_refreshTokenKey, refreshToken);

      // Save user data as JSON string
      await prefs.setString(_userDataKey, jsonEncode(userData));

      // Save remember me preference
      await prefs.setBool(_rememberMeKey, rememberMe);

      // Set not guest
      await prefs.setBool(_isGuestKey, false);

      // Parse token to get expiry (JWT tokens have expiry in payload)
      try {
        final parts = accessToken.split('.');
        if (parts.length == 3) {
          final payload = parts[1];
          final normalized = base64Url.normalize(payload);
          final decoded = utf8.decode(base64Url.decode(normalized));
          final payloadMap = jsonDecode(decoded);

          if (payloadMap.containsKey('exp')) {
            // JWT exp is in seconds since epoch
            final expiryTime =
                payloadMap['exp'] * 1000; // Convert to milliseconds
            await prefs.setString(_tokenExpiryKey, expiryTime.toString());
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error parsing token expiry: $e');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving tokens: $e');
      }
      rethrow;
    }
  }

  static Future<String?> getAccessToken() async {
    try {
      final prefs = await _getPrefs();
      final token = prefs.getString(_accessTokenKey);

      if (token == null) return null;

      // Check if token is expired
      final expiryTimeStr = prefs.getString(_tokenExpiryKey);
      if (expiryTimeStr != null) {
        final expiryTime = int.parse(expiryTimeStr);
        if (DateTime.now().millisecondsSinceEpoch >= expiryTime) {
          // Try to refresh token before returning null
          return await refreshToken();
        }
      }

      return token;
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving access token: $e');
      }
      return null;
    }
  }

  static Future<String?> getRefreshToken() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getString(_refreshTokenKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving refresh token: $e');
      }
      return null;
    }
  }

  static Future<String?> refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return null;

      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['access'];

        // Save the new access token
        final prefs = await _getPrefs();
        await prefs.setString(_accessTokenKey, newAccessToken);

        // Update expiry time
        try {
          final parts = newAccessToken.split('.');
          if (parts.length == 3) {
            final payload = parts[1];
            final normalized = base64Url.normalize(payload);
            final decoded = utf8.decode(base64Url.decode(normalized));
            final payloadMap = jsonDecode(decoded);

            if (payloadMap.containsKey('exp')) {
              final expiryTime = payloadMap['exp'] * 1000;
              await prefs.setString(_tokenExpiryKey, expiryTime.toString());
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing refreshed token expiry: $e');
          }
        }

        return newAccessToken;
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error refreshing token: $e');
      }
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await _getPrefs();
      final userDataString = prefs.getString(_userDataKey);

      if (userDataString == null) return null;

      return jsonDecode(userDataString) as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving user data: $e');
      }
      return null;
    }
  }

  static Future<bool> isGuest() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getBool(_isGuestKey) ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking guest mode: $e');
      }
      return false;
    }
  }

  static Future<void> setGuestMode() async {
    try {
      final prefs = await _getPrefs();
      await prefs.setBool(_isGuestKey, true);
      await prefs.remove(_tokenKey);
      await prefs.remove(_tokenExpiryKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error setting guest mode: $e');
      }
      rethrow;
    }
  }

  static Future<void> logout() async {
    try {
      final token = await getAccessToken();
      if (token != null) {
        // Make API call to logout
        final response = await http.post(
          Uri.parse('$_baseUrl/api/auth/logout/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode != 200) {
          if (kDebugMode) {
            print('Logout API call failed: ${response.body}');
          }
          // Continue with local logout even if API call fails
        }
      }

      // Clear local storage
      final prefs = await _getPrefs();
      await prefs.remove(_accessTokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_userDataKey);
      await prefs.remove(_rememberMeKey);
      await prefs.remove(_isGuestKey);
      await prefs.remove(_resetTokenKey);
      await prefs.remove(_resetEmailKey);
      await prefs.remove(_tokenExpiryKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error during logout: $e');
      }
      // Still clear local storage even if there's an error
      try {
        final prefs = await _getPrefs();
        await prefs.remove(_accessTokenKey);
        await prefs.remove(_refreshTokenKey);
        await prefs.remove(_userDataKey);
        await prefs.remove(_rememberMeKey);
        await prefs.remove(_isGuestKey);
        await prefs.remove(_resetTokenKey);
        await prefs.remove(_resetEmailKey);
        await prefs.remove(_tokenExpiryKey);
      } catch (e) {
        if (kDebugMode) {
          print('Error clearing local storage during logout: $e');
        }
      }
      rethrow;
    }
  }

  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await _getPrefs();
      final hasToken = prefs.getString(_accessTokenKey) != null;
      final guestMode = prefs.getBool(_isGuestKey) ?? false;

      if (hasToken) {
        // Check token expiration
        final expiryTimeStr = prefs.getString(_tokenExpiryKey);
        if (expiryTimeStr != null) {
          final expiryTime = int.parse(expiryTimeStr);
          if (DateTime.now().millisecondsSinceEpoch >= expiryTime) {
            final newToken = await refreshToken();
            return newToken != null || guestMode;
          }
        }
      }

      return hasToken || guestMode;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking login status: $e');
      }
      return false;
    }
  }

  // Password Reset Methods
  static Future<void> saveResetToken(String token, String email) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setString(_resetTokenKey, token);
      await prefs.setString(_resetEmailKey, email);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving reset token: $e');
      }
      rethrow;
    }
  }

  static Future<Map<String, String?>> getResetInfo() async {
    try {
      final prefs = await _getPrefs();
      return {
        'token': prefs.getString(_resetTokenKey),
        'email': prefs.getString(_resetEmailKey),
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting reset info: $e');
      }
      return {'token': null, 'email': null};
    }
  }

  static Future<void> clearResetInfo() async {
    try {
      final prefs = await _getPrefs();
      await prefs.remove(_resetTokenKey);
      await prefs.remove(_resetEmailKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing reset info: $e');
      }
      rethrow;
    }
  }

  static String get baseUrl => _baseUrl;

  // Profile Update Methods
  static Future<Map<String, dynamic>?> updateName(String newName) async {
    try {
      final token = await getAccessToken();
      if (token == null) {
        return null;
      }

      final response = await http.patch(
        Uri.parse('$_baseUrl/api/auth/update-name/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'full_name': newName}),
      );

      if (kDebugMode) {
        print('Name update response status: ${response.statusCode}');
        print('Name update response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final userData = await getUserData();
        if (userData != null) {
          userData['full_name'] = newName;
          final prefs = await _getPrefs();
          await prefs.setString(_userDataKey, jsonEncode(userData));
          return userData;
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating name: $e');
      }
      return null;
    }
  }

  static Future<Map<String, dynamic>?> updateEmail(String newEmail) async {
    try {
      final token = await getAccessToken();
      if (token == null) {
        if (kDebugMode) {
          print('No access token available for email update');
        }
        return null;
      }

      final response = await http.patch(
        Uri.parse('$_baseUrl/api/auth/update-email/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'email': newEmail}),
      );

      if (kDebugMode) {
        print('Email update response status: ${response.statusCode}');
        print('Email update response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final userData = await getUserData();
        if (userData != null) {
          userData['email'] = newEmail;
          final prefs = await _getPrefs();
          await prefs.setString(_userDataKey, jsonEncode(userData));
          if (kDebugMode) {
            print('Local user data updated with new email');
          }
          return userData;
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating email: $e');
      }
      return null;
    }
  }

  static Future<bool> updatePassword(String currentPassword, String newPassword) async {
    try {
      final token = await getAccessToken();
      if (token == null) {
        if (kDebugMode) {
          print('No access token available for password update');
        }
        return false;
      }

      if (kDebugMode) {
        print('Updating password with token: ${token.substring(0, 20)}...');
      }

      final response = await http.patch(
        Uri.parse('$_baseUrl/api/auth/update-password/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );

      if (kDebugMode) {
        print('Password update response status: ${response.statusCode}');
        print('Password update response body: ${response.body}');
      }

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating password: $e');
      }
      return false;
    }
  }

  static Future<Map<String, dynamic>?> updateProfilePicture(String imagePath) async {
    try {
      final token = await getAccessToken();
      if (token == null) {
        return null;
      }

      final request = http.MultipartRequest(
        'PATCH',
        Uri.parse('$_baseUrl/api/auth/update-profile-picture/'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      final file = await http.MultipartFile.fromPath('profile_picture', imagePath);
      request.files.add(file);

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (kDebugMode) {
        print('Profile picture update response status: ${response.statusCode}');
        print('Profile picture update response body: $responseData');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(responseData);
        
        final userData = await getUserData();
        if (userData != null && data['profile_picture'] != null) {
          String picturePath = data['profile_picture'];
          if (!picturePath.startsWith('http')) {
            picturePath = '$_baseUrl$picturePath';
          }
          userData['profile_picture'] = picturePath;
          final prefs = await _getPrefs();
          await prefs.setString(_userDataKey, jsonEncode(userData));
          return userData;
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating profile picture: $e');
      }
      return null;
    }
  }
}

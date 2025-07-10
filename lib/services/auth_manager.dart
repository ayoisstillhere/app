// lib/services/auth_manager.dart
import 'dart:convert';

import 'package:app/features/auth/data/models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';
import '../features/auth/domain/entities/user_entity.dart';

class AuthManager {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Cache variables for performance
  static String? _cachedToken;
  static String? _cachedRefreshToken;

  // Get token (with caching for performance)
  static Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;

    _cachedToken = await _secureStorage.read(key: _tokenKey);
    return _cachedToken;
  }

  // Set token
  static Future<void> setToken(String token) async {
    _cachedToken = token;
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  // Clear token (for logout)
  static Future<void> clearToken() async {
    _cachedToken = null;
    await _secureStorage.delete(key: _tokenKey);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        // Call the logout API endpoint
        final response = await http.post(
          Uri.parse("$baseUrl/api/v1/auth/logout"),
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        );

        // Log response for debugging if needed
        if (response.statusCode != 200) {
          print('Logout API failed with status: ${response.statusCode}');
        }
      }
    } catch (e) {
      // Log the error but continue with local logout
      print('Error during logout: $e');
    } finally {
      // Always clear tokens locally
      await clearToken();
      await clearRefreshToken();
      await clearSecretKeys();
    }
  }

  // Store refresh token securely
  static Future<void> setRefreshToken(String refreshToken) async {
    _cachedRefreshToken = refreshToken;
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  // Get refresh token securely
  static Future<String?> getRefreshToken() async {
    if (_cachedRefreshToken != null) return _cachedRefreshToken;

    _cachedRefreshToken = await _secureStorage.read(key: _refreshTokenKey);
    return _cachedRefreshToken;
  }

  // Clear refresh token securely
  static Future<void> clearRefreshToken() async {
    _cachedRefreshToken = null;
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  static Future<void> clearSecretKeys() async {
    await _secureStorage.delete(key: 'private_key');
  }

  // Refresh token method
  static Future<bool> refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      final response = await http.post(
        Uri.parse("$baseUrl/api/v1/auth/refresh"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "refreshToken": refreshToken,
          "deviceId": await _secureStorage.read(key: "fcm_token"),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Update both tokens if provided
        if (data['access_token'] != null) {
          await setToken(data['access_token']);
        }
        if (data['refresh_token'] != null) {
          await setRefreshToken(data['refresh_token']);
        }

        return true;
      } else {
        // If refresh fails, clear tokens and return false
        await clearAllTokens();
        return false;
      }
    } catch (e) {
      // Error handling
      print('Error refreshing token: $e');
      await clearAllTokens();
      return false;
    }
  }

  // Helper method to clear all tokens
  static Future<void> clearAllTokens() async {
    await clearToken();
    await clearRefreshToken();
  }

  // Check if token is expired (basic check - you might want to implement JWT parsing)
  static Future<bool> isTokenExpired() async {
    final token = await getToken();
    if (token == null) return true;

    // You can implement JWT token expiration check here
    // For now, this is a placeholder
    return false;
  }

  // Auto-refresh token if needed
  static Future<String?> getValidToken() async {
    final token = await getToken();
    if (token == null) return null;

    // Check if token is expired and try to refresh
    if (await isTokenExpired()) {
      final refreshed = await refreshToken();
      if (refreshed) {
        return await getToken();
      } else {
        return null;
      }
    }

    return token;
  }

  static Future<UserEntity?> getCurrentUser() async {
    final secureStorage = FlutterSecureStorage();
    final userJson = await secureStorage.read(key: 'currentUser');

    if (userJson != null) {
      // Convert the JSON string back to a UserEntity object
      return UserModel.fromJson(jsonDecode(userJson));
    }

    return null;
  }
}

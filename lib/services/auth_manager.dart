// lib/services/auth_manager.dart
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

class AuthManager {
  static const String _tokenKey = 'auth_token';
  static String? _cachedToken;
  static const String _refreshTokenKey = 'refresh_token';
  static String? _cachedRefreshToken;

  // Get token (with caching for performance)
  static Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;

    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString(_tokenKey);
    return _cachedToken;
  }

  // Set token
  static Future<void> setToken(String token) async {
    _cachedToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Clear token (for logout)
  static Future<void> clearToken() async {
    _cachedToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
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
          headers: {"Authorization": "Bearer $token"},
        );

        // Even if the API call fails, we should still clear the token locally
        // Check response for debugging purposes
        if (response.statusCode != 200) {}
      }
    } catch (e) {
      // Log the error but continue with local logout
    } finally {
      // Always clear the token locally
      await clearToken();
    }
  }

  // Store refresh token
  static Future<void> setRefreshToken(String refreshToken) async {
    _cachedRefreshToken = refreshToken;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  // Get refresh token
  static Future<String?> getRefreshToken() async {
    if (_cachedRefreshToken != null) return _cachedRefreshToken;

    final prefs = await SharedPreferences.getInstance();
    _cachedRefreshToken = prefs.getString(_refreshTokenKey);
    return _cachedRefreshToken;
  }

  // Clear refresh token
  static Future<void> clearRefreshToken() async {
    _cachedRefreshToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_refreshTokenKey);
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
        body: jsonEncode({"refreshToken": refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await setToken(data['access_token']);
        return true;
      } else {
        // If refresh fails, clear tokens and return false
        await clearToken();
        await clearRefreshToken();
        return false;
      }
    } catch (e) {
      // Error handling
      await clearToken();
      await clearRefreshToken();
      return false;
    }
  }
}

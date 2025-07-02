// lib/services/auth_manager.dart
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

class AuthManager {
  static const String _tokenKey = 'auth_token';
  static String? _cachedToken;
  
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
      if (response.statusCode != 200) {
        
      }
    }
  } catch (e) {
    // Log the error but continue with local logout
  } finally {
    // Always clear the token locally
    await clearToken();
  }
}
}
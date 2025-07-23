// lib/services/auth_manager.dart
import 'dart:convert';
import 'dart:io';

import 'package:app/features/auth/data/models/user_model.dart';
import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';

class AuthManager {
  // Storage Keys
  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _currentUserKey = 'currentUser';
  static const _fcmTokenKey = 'fcm_token';

  // Caches
  static String? _cachedToken;
  static String? _cachedRefreshToken;
  static SharedPreferences? _prefs;

  // Secure storage for iOS
  static const _secureStorage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Optional: Call at app startup to avoid lazy loading delay
  static Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get SharedPreferences (Android only)
  static Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Read securely (Platform-aware)
  static Future<String?> _readSecure(String key) async {
    return Platform.isIOS
        ? await _secureStorage.read(key: key)
        : (await _getPrefs()).getString(key);
  }

  /// Write securely (Platform-aware)
  static Future<void> _writeSecure(String key, String value) async {
    if (Platform.isIOS) {
      await _secureStorage.write(key: key, value: value);
    } else {
      await (await _getPrefs()).setString(key, value);
    }
  }

  /// Delete securely (Platform-aware)
  static Future<void> _deleteSecure(String key) async {
    if (Platform.isIOS) {
      await _secureStorage.delete(key: key);
    } else {
      await (await _getPrefs()).remove(key);
    }
  }

  // ───── TOKEN METHODS ─────────────────────────────────────────────────────────

  static Future<String?> getToken() async {
    return _cachedToken ??= await _readSecure(_tokenKey);
  }

  static Future<void> setToken(String token) async {
    _cachedToken = token;
    await _writeSecure(_tokenKey, token);
  }

  static Future<void> clearToken() async {
    _cachedToken = null;
    await _deleteSecure(_tokenKey);
  }

  static Future<String?> getRefreshToken() async {
    return _cachedRefreshToken ??= await _readSecure(_refreshTokenKey);
  }

  static Future<void> setRefreshToken(String refreshToken) async {
    _cachedRefreshToken = refreshToken;
    await _writeSecure(_refreshTokenKey, refreshToken);
  }

  static Future<void> clearRefreshToken() async {
    _cachedRefreshToken = null;
    await _deleteSecure(_refreshTokenKey);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> clearAllTokens() async {
    await clearToken();
    await clearRefreshToken();
  }

  // ───── FCM TOKEN ────────────────────────────────────────────────────────────

  static Future<void> setFCMToken(String fcmToken) async {
    await _writeSecure(_fcmTokenKey, fcmToken);
  }

  static Future<String?> getFCMToken() async {
    return await _readSecure(_fcmTokenKey);
  }

  // ───── USER DATA ────────────────────────────────────────────────────────────

  static Future<UserEntity?> getCurrentUser() async {
    final userJson = await _readSecure(_currentUserKey);
    if (userJson != null) {
      try {
        return UserModel.fromJson(jsonDecode(userJson));
      } catch (e) {
        debugPrint('Error parsing stored user data: $e');
        await clearCurrentUser();
      }
    }
    return await _fetchCurrentUser();
  }

  static Future<void> clearCurrentUser() async {
    await _deleteSecure(_currentUserKey);
  }

  static Future<UserEntity?> _fetchCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/user/profile'),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(jsonDecode(response.body));
        await _writeSecure(_currentUserKey, jsonEncode(user));
        return user;
      }

      if (response.statusCode == 401) {
        await logout();
      }

      throw Exception('Failed to fetch current user: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error fetching current user: $e');
      rethrow;
    }
  }

  // ───── USER PRIVATE KEY ─────────────────────────────────────────────────────

  static Future<void> setUserPrivateKey(
    String userId,
    String privateKey,
  ) async {
    await _writeSecure('${userId}_private_key', privateKey);
  }

  static Future<String?> getUserPrivateKey(String userId) async {
    return await _readSecure('${userId}_private_key');
  }

  static Future<void> clearSecretKeys() async {
    final user = await getCurrentUser();
    if (user != null) {
      await _deleteSecure('${user.id}_private_key');
    }
  }

  // ───── REFRESH TOKEN ────────────────────────────────────────────────────────

  static Future<bool> refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) return false;

      final fcmToken = await getFCMToken();
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/auth/refresh'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"refreshToken": refreshToken, "deviceId": fcmToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['access_token'] != null) {
          await setToken(data['access_token']);
        }
        if (data['refresh_token'] != null) {
          await setRefreshToken(data['refresh_token']);
        }
        await _fetchCurrentUser();
        return true;
      } else {
        await clearAllTokens();
        return false;
      }
    } catch (e) {
      debugPrint('Error refreshing token: $e');
      await clearAllTokens();
      return false;
    }
  }

  // ───── VALIDATION ───────────────────────────────────────────────────────────

  static Future<bool> isTokenExpired() async {
    final token = await getToken();
    if (token == null) return true;

    // TODO: Implement real JWT expiry check if needed
    return false;
  }

  static Future<String?> getValidToken() async {
    final token = await getToken();
    if (token == null) return null;

    if (await isTokenExpired()) {
      final refreshed = await refreshToken();
      return refreshed ? await getToken() : null;
    }

    return token;
  }

  // ───── LOGOUT ───────────────────────────────────────────────────────────────

  static Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        final response = await http.post(
          Uri.parse('$baseUrl/api/v1/auth/logout'),
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        );
        if (response.statusCode != 200) {
          debugPrint('Logout API failed with status: ${response.statusCode}');
        }
      }
    } catch (e) {
      debugPrint('Error during logout: $e');
    } finally {
      await clearAllUserData();
    }
  }

  static Future<void> clearAllUserData() async {
    await clearAllTokens();
    await clearCurrentUser();
    // await clearSecretKeys(); // Uncomment if needed

    // Google sign-out
    await GoogleSignIn().signOut();

    _cachedToken = null;
    _cachedRefreshToken = null;
  }
}

import 'dart:typed_data';
import 'dart:io';

import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:app/services/auth_manager.dart';
import 'package:encrypt/encrypt.dart' as symmetric;
import 'package:fast_rsa/fast_rsa.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../constants.dart'; // For baseUrl

class SecretChatEncryptionService {
  // iOS secure storage configuration
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static SharedPreferences? _prefs;

  // Initialize SharedPreferences for Android
  static Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Platform-specific storage methods
  static Future<String?> _readSecure(String key) async {
    if (Platform.isIOS) {
      return await _secureStorage.read(key: key);
    } else {
      // Android - use SharedPreferences
      final prefs = await _getPrefs();
      return prefs.getString(key);
    }
  }

  static Future<void> _writeSecure(String key, String value) async {
    if (Platform.isIOS) {
      await _secureStorage.write(key: key, value: value);
    } else {
      // Android - use SharedPreferences
      final prefs = await _getPrefs();
      await prefs.setString(key, value);
    }
  }

  static Future<void> _deleteSecure(String key) async {
    if (Platform.isIOS) {
      await _secureStorage.delete(key: key);
    } else {
      // Android - use SharedPreferences
      final prefs = await _getPrefs();
      await prefs.remove(key);
    }
  }

  Future<Map<String, String>> _generateKeys() async {
    KeyPair keyPair = await RSA.generate(2048);

    String publicKey = keyPair.publicKey;
    String privateKey = keyPair.privateKey;

    return {'publicKey': publicKey, 'privateKey': privateKey};
  }

  /// Updates the user's public key on the server
  Future<bool> updatePublicKey() async {
    try {
      final token = await AuthManager.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      Map<String, String> keys = await _generateKeys();
      String publicKey = keys['publicKey']!;
      String privateKey = keys['privateKey']!;

      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/auth/update-public-key'),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'publicKey': publicKey}),
      );

      if (response.statusCode == 200) {
        await storePrivateKey(privateKey);
        return true;
      } else {
        print('Failed to update public key. Status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error updating public key: $e');
      return false;
    }
  }

  Future<void> storePrivateKey(String privateKey) async {
    try {
      UserEntity? user = await AuthManager.getCurrentUser();
      if (user == null) {
        throw Exception('No current user found');
      }

      await _writeSecure('${user.id}_private_key', privateKey);
    } catch (e) {
      print('Error storing private key: $e');
      throw Exception('Failed to store private key');
    }
  }

  // Retrieve private key securely
  Future<String?> getPrivateKey() async {
    try {
      UserEntity? user = await AuthManager.getCurrentUser();
      if (user == null) {
        return null;
      }

      return await _readSecure('${user.id}_private_key');
    } catch (e) {
      print('Error retrieving private key: $e');
      return null;
    }
  }

  // Clear private key (useful for logout)
  Future<void> clearPrivateKey() async {
    try {
      UserEntity? user = await AuthManager.getCurrentUser();
      if (user != null) {
        await _deleteSecure('${user.id}_private_key');
      }
    } catch (e) {
      print('Error clearing private key: $e');
    }
  }

  Future<bool> ensureKeyPairExists() async {
    try {
      // Check if private key already exists
      final privateKey = await getPrivateKey();

      // If private key exists, we don't need to generate new keys
      if (privateKey != null && privateKey.isNotEmpty) {
        return true;
      }

      // No private key found, generate and store new key pair
      return await updatePublicKey();
    } catch (e) {
      print('Error ensuring key pair exists: $e');
      return false;
    }
  }

  /// Decrypts an RSA-encrypted conversation key using the stored private key
  Future<String> decryptConversationKey(String encryptedConversationKey) async {
    try {
      // Get the private key from secure storage
      String? privateKey = await getPrivateKey();
      if (privateKey == null) {
        final encryptionService = SecretChatEncryptionService();
        await encryptionService.ensureKeyPairExists();
        privateKey = await encryptionService.getPrivateKey();
      }

      // Decrypt the conversation key using RSA and the private key
      final decryptedConversationKey = await RSA.decryptPKCS1v15(
        encryptedConversationKey,
        privateKey!,
      );

      return decryptedConversationKey;
    } catch (e) {
      print('Error decrypting conversation key: $e');
      throw Exception('Failed to decrypt conversation key: $e');
    }
  }

  /// Encrypts a conversation key with a recipient's public key using RSA
  Future<String> encryptConversationKey(
    String plaintextConversationKey,
    String recipientPublicKey,
  ) async {
    try {
      final encryptedConversationKey = await RSA.encryptPKCS1v15(
        plaintextConversationKey,
        recipientPublicKey,
      );

      return encryptedConversationKey;
    } catch (e) {
      print('Error encrypting conversation key: $e');
      throw Exception('Failed to encrypt conversation key: $e');
    }
  }

  /// Encrypts a message using the conversation key (AES symmetric encryption)
  String encryptMessage(String plaintextMessage, String conversationKey) {
    try {
      // Convert hex conversation key to bytes
      final keyBytes = _hexStringToBytes(conversationKey);
      final iv = _generateRandomIV();

      // Use AES for symmetric encryption with the conversation key
      final encrypter = symmetric.Encrypter(
        symmetric.AES(symmetric.Key(keyBytes), mode: symmetric.AESMode.cbc),
      );
      final encrypted = encrypter.encrypt(
        plaintextMessage,
        iv: symmetric.IV(iv),
      );

      // Combine IV and ciphertext with a separator
      final ivBase64 = base64.encode(iv);
      final encryptedBase64 = encrypted.base64;

      return "$ivBase64:$encryptedBase64";
    } catch (e) {
      print('Error encrypting message: $e');
      throw Exception('Failed to encrypt message: $e');
    }
  }

  /// Decrypts a message using the conversation key (AES symmetric decryption)
  String decryptMessage(String encryptedMessage, String conversationKey) {
    try {
      // Split the combined IV and ciphertext
      final parts = encryptedMessage.split(':');
      if (parts.length != 2) {
        throw Exception('Invalid encrypted message format');
      }

      final ivBase64 = parts[0];
      final encryptedBase64 = parts[1];

      // Convert hex conversation key to bytes
      final keyBytes = _hexStringToBytes(conversationKey);
      final iv = base64.decode(ivBase64);

      // Use AES for symmetric decryption with the conversation key
      final encrypter = symmetric.Encrypter(
        symmetric.AES(symmetric.Key(keyBytes), mode: symmetric.AESMode.cbc),
      );

      final decryptedMessage = encrypter.decrypt(
        symmetric.Encrypted.fromBase64(encryptedBase64),
        iv: symmetric.IV(iv),
      );

      return decryptedMessage;
    } catch (e) {
      print('Error decrypting message: $e');
      throw Exception('Failed to decrypt message: $e');
    }
  }

  // Helper method to store current user with platform-specific storage
  static Future<void> storeCurrentUser(UserEntity user) async {
    try {
      await _writeSecure('currentUser', jsonEncode(user));
    } catch (e) {
      print('Error storing current user: $e');
      throw Exception('Failed to store current user');
    }
  }

  // Helper method to get current user with platform-specific storage
  static Future<UserEntity?> getCurrentUser() async {
    try {
      final userJson = await _readSecure('currentUser');
      if (userJson != null) {
        // You'll need to import your UserModel class
        // return UserModel.fromJson(jsonDecode(userJson));
        return null; // Replace with actual deserialization
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Store conversation key for caching (optional)
  Future<void> storeConversationKey(
    String conversationId,
    String conversationKey,
  ) async {
    try {
      await _writeSecure('conversation_key_$conversationId', conversationKey);
    } catch (e) {
      print('Error storing conversation key: $e');
    }
  }

  // Get cached conversation key (optional)
  Future<String?> getConversationKey(String conversationId) async {
    try {
      return await _readSecure('conversation_key_$conversationId');
    } catch (e) {
      print('Error getting conversation key: $e');
      return null;
    }
  }

  // Clear conversation key (optional)
  Future<void> clearConversationKey(String conversationId) async {
    try {
      await _deleteSecure('conversation_key_$conversationId');
    } catch (e) {
      print('Error clearing conversation key: $e');
    }
  }

  // Clear all encryption data (useful for logout)
  Future<void> clearAllEncryptionData() async {
    try {
      await clearPrivateKey();
      // Clear any other encryption-related data as needed
    } catch (e) {
      print('Error clearing encryption data: $e');
    }
  }

  // Helper methods (continued)
  Uint8List _hexStringToBytes(String hex) {
    String normalized = hex.replaceAll(' ', '');
    if (normalized.length % 2 != 0) {
      throw Exception('Invalid hex string length');
    }

    Uint8List bytes = Uint8List(normalized.length ~/ 2);
    for (int i = 0; i < bytes.length; i++) {
      String hexByte = normalized.substring(i * 2, i * 2 + 2);
      bytes[i] = int.parse(hexByte, radix: 16);
    }
    return bytes;
  }

  /// Generate a random IV for AES encryption
  Uint8List _generateRandomIV() {
    final iv = symmetric.IV.fromSecureRandom(16);
    return iv.bytes;
  }
}

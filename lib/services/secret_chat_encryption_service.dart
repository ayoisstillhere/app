import 'dart:typed_data';

import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:app/services/auth_manager.dart';
import 'package:encrypt/encrypt.dart' as symmetric;
import 'package:fast_rsa/fast_rsa.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../constants.dart'; // For baseUrl

class SecretChatEncryptionService {
  final _secureStorage = FlutterSecureStorage();

  Future<Map<String, String>> _generateKeys() async {
    KeyPair keyPair = await RSA.generate(2048);

    String publicKey = keyPair.publicKey;
    String privateKey = keyPair.privateKey;

    return {'publicKey': publicKey, 'privateKey': privateKey};
  }

  /// Updates the user's public key on the server
  Future<bool> updatePublicKey() async {
    final token = await AuthManager.getToken();
    Map<String, String> keys = await _generateKeys();
    String publicKey = keys['publicKey']!;
    String privateKey = keys['privateKey']!;
    try {
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
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<void> storePrivateKey(String privateKey) async {
    UserEntity? user = await AuthManager.getCurrentUser();
    if (user == null) {
      // Fetch the current user
    }
    await _secureStorage.write(
      key: '${user!.id}_private_key',
      value: privateKey,
    );
  }

  // Retrieve private key securely
  Future<String?> getPrivateKey() async {
    UserEntity? user = await AuthManager.getCurrentUser();
    return await _secureStorage.read(key: '${user!.id}_private_key');
  }

  Future<bool> ensureKeyPairExists() async {
    // Check if private key already exists
    final privateKey = await getPrivateKey();

    // If private key exists, we don't need to generate new keys
    if (privateKey != null && privateKey.isNotEmpty) {
      return true;
    }

    // No private key found, generate and store new key pair
    return await updatePublicKey();
  }

  /// Decrypts an RSA-encrypted conversation key using the stored private key
  Future<String> decryptConversationKey(String encryptedConversationKey) async {
    try {
      // Get the private key from secure storage
      final privateKey = await getPrivateKey();
      if (privateKey == null) {
        throw Exception('Private key not found');
      }

      // Decrypt the conversation key using RSA and the private key
      final decryptedConversationKey = await RSA.decryptPKCS1v15(
        encryptedConversationKey,
        privateKey,
      );

      return decryptedConversationKey;
    } catch (e) {
      print('Error decrypting conversation key: $e');
      throw Exception('Failed to decrypt conversation key');
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
      throw Exception('Failed to encrypt conversation key');
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
      throw Exception('Failed to encrypt message');
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
      throw Exception('Failed to decrypt message');
    }
  }

  // Helper methods (continued)
  Uint8List _hexStringToBytes(String hex) {
    String normalized = hex.replaceAll(' ', '');
    Uint8List bytes = Uint8List(normalized.length ~/ 2);
    for (int i = 0; i < bytes.length; i++) {
      bytes[i] = int.parse(normalized.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return bytes;
  }

  /// Generate a random IV for AES encryption
  Uint8List _generateRandomIV() {
    final iv = symmetric.IV.fromSecureRandom(16);
    return iv.bytes;
  }
}

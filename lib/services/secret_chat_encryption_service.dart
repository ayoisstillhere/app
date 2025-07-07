import 'package:app/services/auth_manager.dart';
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
    await _secureStorage.write(key: 'private_key', value: privateKey);
  }

  // Retrieve private key securely
  Future<String?> getPrivateKey() async {
    return await _secureStorage.read(key: 'private_key');
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
}

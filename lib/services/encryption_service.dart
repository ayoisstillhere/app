import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';

class FlutterEncryptionService {
  static const String _algorithm = 'AES-256-GCM';
  static const int _keyLength = 32; // 256 bits
  static const int _ivLength = 16; // 128 bits
  static const int _tagLength = 16; // 128 bits for GCM tag

  FlutterEncryptionService();

  /// Generates a unique encryption key for a conversation (64 hex characters)
  String generateConversationKey() {
    final random = Random.secure();
    final bytes = Uint8List(_keyLength);
    for (int i = 0; i < _keyLength; i++) {
      bytes[i] = random.nextInt(256);
    }
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Encrypts text with a specific conversation key
  /// Returns format: iv:tag:encrypted (same as Node.js service)
  String encryptWithConversationKey(String text, String conversationKey) {
    try {
      // Convert hex key to bytes
      final keyBytes = _hexToBytes(conversationKey);
      if (keyBytes.length != _keyLength) {
        throw Exception('Invalid conversation key length');
      }

      // Convert text to bytes
      final plainBytes = utf8.encode(text);

      // Generate random IV
      final iv = _generateSecureRandom(_ivLength);

      // Encrypt using AES-GCM
      final result = _encryptAesGcm(plainBytes, keyBytes, iv);

      // Format: iv:tag:encrypted (same as Node.js)
      final ivHex = iv.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
      final tagHex = result['tag']!
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join();
      final encryptedHex = result['encrypted']!
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join();

      return '$ivHex:$tagHex:$encryptedHex';
    } catch (error) {
      throw Exception('Failed to encrypt with conversation key: $error');
    }
  }

  /// Decrypts text with a specific conversation key
  /// Expects format: iv:tag:encrypted
  String decryptWithConversationKey(
    String encryptedData,
    String conversationKey,
  ) {
    try {
      // Parse the encrypted data
      final parts = encryptedData.split(':');
      if (parts.length != 3) {
        throw Exception('Invalid encrypted data format');
      }

      final ivBytes = _hexToBytes(parts[0]);
      final tagBytes = _hexToBytes(parts[1]);
      final encryptedBytes = _hexToBytes(parts[2]);

      // Convert hex key to bytes
      final keyBytes = _hexToBytes(conversationKey);
      if (keyBytes.length != _keyLength) {
        throw Exception('Invalid conversation key length');
      }

      // Decrypt using AES-GCM
      final decryptedBytes = _decryptAesGcm(
        encryptedBytes,
        keyBytes,
        ivBytes,
        tagBytes,
      );

      // Convert back to string
      return utf8.decode(decryptedBytes);
    } catch (error) {
      throw Exception('Failed to decrypt with conversation key: $error');
    }
  }

  /// Encrypts buffer/bytes with conversation key
  /// Returns a map with encryptedData and metadata
  Map<String, dynamic> encryptBufferWithConversationKey(
    Uint8List buffer,
    String conversationKey,
  ) {
    try {
      // Convert hex key to bytes
      final keyBytes = _hexToBytes(conversationKey);
      if (keyBytes.length != _keyLength) {
        throw Exception('Invalid conversation key length');
      }

      // Generate random IV
      final iv = _generateSecureRandom(_ivLength);

      // Encrypt using AES-GCM
      final result = _encryptAesGcm(buffer, keyBytes, iv);

      // Create metadata: iv:tag
      final ivHex = iv.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
      final tagHex = result['tag']!
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join();
      final metadata = '$ivHex:$tagHex';

      return {
        'encryptedData': Uint8List.fromList(result['encrypted']!),
        'metadata': metadata,
      };
    } catch (error) {
      throw Exception('Failed to encrypt buffer with conversation key: $error');
    }
  }

  /// Decrypts buffer/bytes with conversation key
  Uint8List decryptBufferWithConversationKey(
    Uint8List encryptedBuffer,
    String metadata,
    String conversationKey,
  ) {
    try {
      // Parse metadata
      final parts = metadata.split(':');
      if (parts.length != 2) {
        throw Exception('Invalid metadata format');
      }

      final ivBytes = _hexToBytes(parts[0]);
      final tagBytes = _hexToBytes(parts[1]);

      // Convert hex key to bytes
      final keyBytes = _hexToBytes(conversationKey);
      if (keyBytes.length != _keyLength) {
        throw Exception('Invalid conversation key length');
      }

      // Decrypt using AES-GCM
      final decrypted = _decryptAesGcm(
        encryptedBuffer,
        keyBytes,
        ivBytes,
        tagBytes,
      );

      return Uint8List.fromList(decrypted);
    } catch (error) {
      throw Exception('Failed to decrypt buffer with conversation key: $error');
    }
  }

  /// Internal method to encrypt using AES-GCM
  Map<String, List<int>> _encryptAesGcm(
    List<int> plaintext,
    List<int> key,
    List<int> iv,
  ) {
    final cipher = GCMBlockCipher(AESEngine());
    final keyParam = KeyParameter(Uint8List.fromList(key));
    final ivParam = ParametersWithIV(keyParam, Uint8List.fromList(iv));

    cipher.init(true, ivParam); // true for encryption

    final ciphertext = cipher.process(Uint8List.fromList(plaintext));
    final tag = cipher.mac;

    return {'encrypted': ciphertext, 'tag': tag};
  }

  /// Internal method to decrypt using AES-GCM
  List<int> _decryptAesGcm(
    List<int> ciphertext,
    List<int> key,
    List<int> iv,
    List<int> tag,
  ) {
    final cipher = GCMBlockCipher(AESEngine());
    final keyParam = KeyParameter(Uint8List.fromList(key));
    final ivParam = ParametersWithIV(keyParam, Uint8List.fromList(iv));

    cipher.init(false, ivParam); // false for decryption

    // Combine ciphertext and tag for GCM decryption
    final ciphertextWithTag = Uint8List.fromList([...ciphertext, ...tag]);

    final plaintext = cipher.process(ciphertextWithTag);

    return plaintext;
  }

  /// Generate secure random bytes
  List<int> _generateSecureRandom(int length) {
    final random = Random.secure();
    final bytes = <int>[];
    for (int i = 0; i < length; i++) {
      bytes.add(random.nextInt(256));
    }
    return bytes;
  }

  /// Helper method to convert hex string to bytes
  Uint8List _hexToBytes(String hex) {
    final result = Uint8List(hex.length ~/ 2);
    for (int i = 0; i < hex.length; i += 2) {
      result[i ~/ 2] = int.parse(hex.substring(i, i + 2), radix: 16);
    }
    return result;
  }
}

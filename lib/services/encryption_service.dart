import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';

/// Encryption service providing AES-256-GCM encryption capabilities
class EncryptionService {
  static const String _algorithm = 'AES-256-GCM';
  static const int _keyLength = 32; // 256 bits
  static const int _ivLength = 16; // 128 bits

  late final Uint8List _secretKey;
  final Random _random = Random.secure();

  /// Constructor that accepts an optional encryption key
  /// If no key is provided, you should set it using setSecretKey()
  EncryptionService({String? encryptionKey}) {
    if (encryptionKey != null) {
      _secretKey = _hexStringToBytes(encryptionKey);
    }
  }

  /// Set the secret key from a hex string (equivalent to environment variable)
  void setSecretKey(String hexKey) {
    _secretKey = _hexStringToBytes(hexKey);
  }

  /// Generate a random encryption key (for initial setup)
  static String generateSecretKey() {
    final random = Random.secure();
    final bytes = Uint8List(32);
    for (int i = 0; i < 32; i++) {
      bytes[i] = random.nextInt(256);
    }
    return _bytesToHexString(bytes);
  }

  /// Generates a unique encryption key for a conversation (for enhanced security)
  String generateConversationKey() {
    final bytes = Uint8List(_keyLength);
    for (int i = 0; i < _keyLength; i++) {
      bytes[i] = _random.nextInt(256);
    }
    return _bytesToHexString(bytes);
  }

  /// Encrypts data with a specific conversation key
  String encryptWithConversationKey(String text, String conversationKey) {
    try {
      final key = _hexStringToBytes(conversationKey);
      final iv = _generateRandomBytes(_ivLength);

      final encrypter = Encrypter(AES(Key(key), mode: AESMode.gcm));
      final encrypted = encrypter.encrypt(text, iv: IV(iv));

      // Format: iv:tag:encrypted
      final ivHex = _bytesToHexString(iv);
      final tagHex = _bytesToHexString(
        encrypted.bytes.sublist(encrypted.bytes.length - 16),
      );
      final encryptedHex = _bytesToHexString(
        encrypted.bytes.sublist(0, encrypted.bytes.length - 16),
      );

      return '$ivHex:$tagHex:$encryptedHex';
    } catch (error) {
      _logError('Conversation encryption error: $error');
      throw Exception('Failed to encrypt with conversation key');
    }
  }

  /// Decrypts data with a specific conversation key
  String decryptWithConversationKey(
    String encryptedData,
    String conversationKey,
  ) {
    try {
      final key = _hexStringToBytes(conversationKey);
      final parts = encryptedData.split(':');

      if (parts.length != 3) {
        throw Exception('Invalid encrypted data format');
      }

      final iv = _hexStringToBytes(parts[0]);
      final tag = _hexStringToBytes(parts[1]);
      final encryptedBytes = _hexStringToBytes(parts[2]);

      // Combine encrypted data and tag for decryption
      final combinedData = Uint8List.fromList([...encryptedBytes, ...tag]);

      final encrypter = Encrypter(AES(Key(key), mode: AESMode.gcm));
      final encrypted = Encrypted(combinedData);

      final decrypted = encrypter.decrypt(encrypted, iv: IV(iv));
      return decrypted;
    } catch (error) {
      _logError('Conversation decryption error: $error');
      throw Exception('Failed to decrypt with conversation key');
    }
  }

  /// Helper method to convert hex string to bytes
  static Uint8List _hexStringToBytes(String hex) {
    final result = Uint8List(hex.length ~/ 2);
    for (int i = 0; i < hex.length; i += 2) {
      result[i ~/ 2] = int.parse(hex.substring(i, i + 2), radix: 16);
    }
    return result;
  }

  /// Helper method to convert bytes to hex string
  static String _bytesToHexString(Uint8List bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Generate random bytes
  Uint8List _generateRandomBytes(int length) {
    final bytes = Uint8List(length);
    for (int i = 0; i < length; i++) {
      bytes[i] = _random.nextInt(256);
    }
    return bytes;
  }

  /// Simple logging method (replace with your preferred logging solution)
  void _logError(String message) {
    print('EncryptionService Error: $message');
  }
}

/// Result class for buffer encryption operations
class EncryptionResult {
  final Uint8List encryptedData;
  final String metadata;

  EncryptionResult({required this.encryptedData, required this.metadata});
}
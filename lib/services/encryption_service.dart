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
      final tagHex = _bytesToHexString(encrypted.bytes.sublist(encrypted.bytes.length - 16));
      final encryptedHex = _bytesToHexString(encrypted.bytes.sublist(0, encrypted.bytes.length - 16));
      
      return '$ivHex:$tagHex:$encryptedHex';
    } catch (error) {
      _logError('Conversation encryption error: $error');
      throw Exception('Failed to encrypt with conversation key');
    }
  }

  /// Decrypts data with a specific conversation key
  String decryptWithConversationKey(String encryptedData, String conversationKey) {
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

  /// Encrypts buffer with conversation key
  EncryptionResult encryptBufferWithConversationKey(Uint8List buffer, String conversationKey) {
    try {
      final key = _hexStringToBytes(conversationKey);
      final iv = _generateRandomBytes(_ivLength);
      
      final encrypter = Encrypter(AES(Key(key), mode: AESMode.gcm));
      final encrypted = encrypter.encryptBytes(buffer, iv: IV(iv));
      
      // Separate encrypted data and tag
      final encryptedData = encrypted.bytes.sublist(0, encrypted.bytes.length - 16);
      final tag = encrypted.bytes.sublist(encrypted.bytes.length - 16);
      
      final ivHex = _bytesToHexString(iv);
      final tagHex = _bytesToHexString(tag);
      final metadata = '$ivHex:$tagHex';
      
      return EncryptionResult(
        encryptedData: Uint8List.fromList(encryptedData),
        metadata: metadata,
      );
    } catch (error) {
      _logError('Buffer conversation encryption error: $error');
      throw Exception('Failed to encrypt buffer with conversation key');
    }
  }

  /// Decrypts buffer with conversation key
  Uint8List decryptBufferWithConversationKey(Uint8List encryptedBuffer, String metadata, String conversationKey) {
    try {
      final key = _hexStringToBytes(conversationKey);
      final parts = metadata.split(':');
      
      if (parts.length != 2) {
        throw Exception('Invalid metadata format');
      }

      final iv = _hexStringToBytes(parts[0]);
      final tag = _hexStringToBytes(parts[1]);
      
      // Combine encrypted data and tag for decryption
      final combinedData = Uint8List.fromList([...encryptedBuffer, ...tag]);
      
      final encrypter = Encrypter(AES(Key(key), mode: AESMode.gcm));
      final encrypted = Encrypted(combinedData);
      
      final decrypted = encrypter.decryptBytes(encrypted, iv: IV(iv));
      return Uint8List.fromList(decrypted);
    } catch (error) {
      _logError('Buffer conversation decryption error: $error');
      throw Exception('Failed to decrypt buffer with conversation key');
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

  EncryptionResult({
    required this.encryptedData,
    required this.metadata,
  });
}

/// Example usage and testing
void main() {
  // Example usage
  final encryptionService = EncryptionService();
  
  // Set up the secret key (in a real app, this would come from secure storage)
  final secretKey = EncryptionService.generateSecretKey();
  encryptionService.setSecretKey(secretKey);
  
  // Generate a conversation key
  final conversationKey = encryptionService.generateConversationKey();
  print('Generated conversation key: $conversationKey');
  
  // Test string encryption/decryption
  const testMessage = 'This is a secret message!';
  final encrypted = encryptionService.encryptWithConversationKey(testMessage, conversationKey);
  print('Encrypted: $encrypted');
  
  final decrypted = encryptionService.decryptWithConversationKey(encrypted, conversationKey);
  print('Decrypted: $decrypted');
  print('Match: ${testMessage == decrypted}');
  
  // Test buffer encryption/decryption
  final testBuffer = Uint8List.fromList('Hello, World!'.codeUnits);
  final bufferResult = encryptionService.encryptBufferWithConversationKey(testBuffer, conversationKey);
  print('Buffer encrypted, metadata: ${bufferResult.metadata}');
  
  final decryptedBuffer = encryptionService.decryptBufferWithConversationKey(
    bufferResult.encryptedData,
    bufferResult.metadata,
    conversationKey,
  );
  final decryptedString = String.fromCharCodes(decryptedBuffer);
  print('Buffer decrypted: $decryptedString');
  print('Buffer match: ${String.fromCharCodes(testBuffer) == decryptedString}');
}
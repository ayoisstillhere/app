import 'dart:io';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class FileEncryptor {
  static Future<Map<String, dynamic>> encryptFile(File inputFile) async {
    // Generate 32-byte AES key
    final key = encrypt.Key.fromSecureRandom(32);
    final iv = encrypt.IV.fromSecureRandom(16); // AES-CBC IV

    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc),
    );
    final fileBytes = await inputFile.readAsBytes();

    final encrypted = encrypter.encryptBytes(fileBytes, iv: iv);
    final encryptedBytes = encrypted.bytes;

    // Calculate SHA-256 hash for integrity verification
    final sha256Hash = sha256.convert(fileBytes).toString();

    // Save encrypted file locally
    final encryptedFilePath = p.join(
      inputFile.parent.path,
      'encrypted_${p.basename(inputFile.path)}',
    );
    final encryptedFile = File(encryptedFilePath);
    await encryptedFile.writeAsBytes(encryptedBytes);

    return {
      'encryptedFile': encryptedFile,
      'key': base64.encode(key.bytes),
      'iv': base64.encode(iv.bytes),
      'hash': sha256Hash,
    };
  }

  static Future<File> decryptFile(
    File encryptedFile,
    String base64Key,
    String base64Iv,
  ) async {
    final key = encrypt.Key.fromBase64(base64Key);
    final iv = encrypt.IV.fromBase64(base64Iv);

    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc),
    );
    final encryptedBytes = await encryptedFile.readAsBytes();

    final decryptedBytes = encrypter.decryptBytes(
      encrypt.Encrypted(encryptedBytes),
      iv: iv,
    );

    final decryptedFilePath = p.join(
      encryptedFile.parent.path,
      'decrypted_${p.basename(encryptedFile.path)}',
    );
    final decryptedFile = File(decryptedFilePath);
    await decryptedFile.writeAsBytes(decryptedBytes);
    return decryptedFile;
  }

  static Future<File> downloadEncryptedFile(String url, String filename) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = p.join(directory.path, filename);
      final file = File(filePath);

      await file.writeAsBytes(response.bodyBytes);

      return file;
    } else {
      throw Exception('Failed to download file: ${response.statusCode}');
    }
  }

  static Future<File> secureDownloadAndDecrypt(
    String fileUrl,
    String encryptedFilename,
    String base64Key,
    String base64Iv,
  ) async {
    try {
      final encryptedFile = await downloadEncryptedFile(
        fileUrl,
        encryptedFilename,
      );
      return await decryptFile(encryptedFile, base64Key, base64Iv);
    } catch (e) {
      throw Exception('Failed to download and decrypt file: $e');
    }
  }
}

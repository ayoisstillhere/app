import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
    // Cache management
  static const String _cacheKeyPrefix = 'cached_file_';
  static const String _cacheMetadataKey = 'cache_metadata';
  static const int _maxCacheSize = 100 * 1024 * 1024; // 100MB
  static const int _maxCacheAge = 7 * 24 * 60 * 60 * 1000; // 7 days in milliseconds

  // Add method to clear cache (optional, for settings screen)
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metadataJson = prefs.getString(_cacheMetadataKey) ?? '{}';
      final metadata = jsonDecode(metadataJson) as Map<String, dynamic>;

      // Delete all cached files
      for (final entry in metadata.entries) {
        final data = entry.value as Map<String, dynamic>;
        final file = File(data['path'] as String);
        if (await file.exists()) {
          await file.delete();
        }
        await prefs.remove(entry.key);
      }

      // Clear metadata
      await prefs.remove(_cacheMetadataKey);

      // Remove cache directory if empty
      final appDir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${appDir.path}/message_cache');
      if (await cacheDir.exists()) {
        final files = await cacheDir.list().toList();
        if (files.isEmpty) {
          await cacheDir.delete();
        }
      }
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  // Add method to get cache size (optional, for settings screen)
  static Future<int> getCacheSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metadataJson = prefs.getString(_cacheMetadataKey) ?? '{}';
      final metadata = jsonDecode(metadataJson) as Map<String, dynamic>;

      int totalSize = 0;
      for (final entry in metadata.entries) {
        final data = entry.value as Map<String, dynamic>;
        totalSize += data['size'] as int;
      }

      return totalSize;
    } catch (e) {
      print('Error getting cache size: $e');
      return 0;
    }
  }
}

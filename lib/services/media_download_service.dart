import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart'; // Alternative 1
// import 'package:gal/gal.dart'; // Alternative 2 - uncomment if using

class MediaDownloadService {
  // Method 1: Using image_gallery_saver (most popular alternative)
  static Future<bool> saveImageToGallery(File imageFile) async {
    try {
      // Request permissions
      if (Platform.isAndroid) {
        final permission = await Permission.storage.request();
        if (!permission.isGranted) {
          return false;
        }
      } else if (Platform.isIOS) {
        final permission = await Permission.photos.request();
        if (!permission.isGranted) {
          return false;
        }
      }

      // Save to gallery
      final result = await ImageGallerySaver.saveFile(imageFile.path);
      return result['isSuccess'] ?? false;
    } catch (e) {
      debugPrint('Error saving image: $e');
      return false;
    }
  }

  static Future<bool> saveVideoToGallery(File videoFile) async {
    try {
      // Request permissions
      if (Platform.isAndroid) {
        final permission = await Permission.storage.request();
        if (!permission.isGranted) {
          return false;
        }
      } else if (Platform.isIOS) {
        final permission = await Permission.photos.request();
        if (!permission.isGranted) {
          return false;
        }
      }

      // Save to gallery
      final result = await ImageGallerySaver.saveFile(
        videoFile.path,
        isReturnPathOfIOS: true,
      );
      return result['isSuccess'] ?? false;
    } catch (e) {
      debugPrint('Error saving video: $e');
      return false;
    }
  }

  // Method 2: Using gal package (lightweight alternative)
  /*
  static Future<bool> saveImageToGalleryWithGal(File imageFile) async {
    try {
      if (!await Gal.hasAccess()) {
        if (!await Gal.requestAccess()) {
          return false;
        }
      }
      
      await Gal.putImage(imageFile.path);
      return true;
    } catch (e) {
      debugPrint('Error saving image with Gal: $e');
      return false;
    }
  }

  static Future<bool> saveVideoToGalleryWithGal(File videoFile) async {
    try {
      if (!await Gal.hasAccess()) {
        if (!await Gal.requestAccess()) {
          return false;
        }
      }
      
      await Gal.putVideo(videoFile.path);
      return true;
    } catch (e) {
      debugPrint('Error saving video with Gal: $e');
      return false;
    }
  }
  */

  // Method 3: Save to app documents and share
  static Future<bool> saveToDocumentsAndShare(File mediaFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = mediaFile.path.split('/').last;
      final newPath = '${directory.path}/$fileName';

      await mediaFile.copy(newPath);

      // Share the file
      await SharePlus.instance.share(
        ShareParams(text: 'Downloaded from chat', files: [XFile(newPath)]),
      );

      return true;
    } catch (e) {
      debugPrint('Error saving and sharing: $e');
      return false;
    }
  }

  // Method 4: Save to Downloads folder (Android only)
  static Future<bool> saveToDownloads(File mediaFile) async {
    if (!Platform.isAndroid) return false;

    try {
      final permission = await Permission.storage.request();
      if (!permission.isGranted) {
        return false;
      }

      final directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final fileName = mediaFile.path.split('/').last;
      final newPath = '${directory.path}/$fileName';

      await mediaFile.copy(newPath);
      return true;
    } catch (e) {
      debugPrint('Error saving to downloads: $e');
      return false;
    }
  }
}

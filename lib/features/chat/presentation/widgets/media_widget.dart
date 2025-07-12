import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../components/full_screen_file_image_viewer.dart';
import '../../../../services/file_encryptor.dart';
import '../../../../size_config.dart';
import '../../domain/entities/get_media_response_entity.dart';

class MediaWidget extends StatefulWidget {
  const MediaWidget({super.key, required this.data});
  final Datum data;

  @override
  State<MediaWidget> createState() => _MediaWidgetState();
}

class _MediaWidgetState extends State<MediaWidget> {
  File? decryptedFile;
  bool isDecrypting = false;
  String? decryptionError;

  Future<void> _decryptFile() async {
    if (!mounted) return;

    setState(() {
      isDecrypting = true;
      decryptionError = null;
    });

    try {
      dynamic json = jsonDecode(widget.data.encryptionMetadata!);
      final file = await FileEncryptor.secureDownloadAndDecrypt(
        widget.data.mediaUrl,
        json['filename'],
        json['key'],
        json['iv'],
      );

      if (mounted) {
        setState(() {
          decryptedFile = file;
          isDecrypting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          decryptionError = 'Failed to decrypt file: ${e.toString()}';
          isDecrypting = false;
        });
      }
    }
  }

  void _openFullScreenViewer() {
    if (decryptedFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullScreenFileImageViewer(
            imageFile: decryptedFile!,
            title: _getFileName(),
          ),
        ),
      );
    }
  }

  String _getFileName() {
    try {
      dynamic json = jsonDecode(widget.data.encryptionMetadata!);
      return json['filename'] ?? 'Image';
    } catch (e) {
      return 'Image';
    }
  }

  @override
  void initState() {
    super.initState();
    _decryptFile();
  }

  @override
  Widget build(BuildContext context) {
    if (isDecrypting) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(getProportionateScreenWidth(5)),
          color: Colors.grey[200],
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (decryptionError != null) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(getProportionateScreenWidth(5)),
          color: Colors.grey[200],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 32),
              SizedBox(height: 8),
              Text(
                'Failed to load',
                style: TextStyle(color: Colors.red, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: _openFullScreenViewer,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(getProportionateScreenWidth(5)),
          image: DecorationImage(
            image: decryptedFile != null
                ? FileImage(decryptedFile!)
                : const AssetImage('assets/images/place_holder.jpg'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

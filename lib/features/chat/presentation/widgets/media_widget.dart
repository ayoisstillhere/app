import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _decryptFile();
  }

  @override
  Widget build(BuildContext context) {
    return isDecrypting
        ? const CircularProgressIndicator()
        : GestureDetector(
            onTap: () {},
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      getProportionateScreenWidth(5),
                    ),
                    image: DecorationImage(
                      image: decryptedFile != null
                          ? FileImage(decryptedFile!)
                          : const AssetImage('assets/images/place_holder.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import '../../../../services/file_encryptor.dart';
import '../../../../size_config.dart';
import '../../domain/entities/get_media_response_entity.dart';

class FileWidget extends StatefulWidget {
  final Datum data;

  const FileWidget({super.key, required this.data});

  @override
  State<FileWidget> createState() => _FileWidgetState();
}

class _FileWidgetState extends State<FileWidget> {
  bool isDecrypting = true;
  String? decryptionError;
  File? decryptedFile;
  String fileName = "File";

  @override
  void initState() {
    super.initState();
    _decryptFile();
  }

  Future<void> _decryptFile() async {
    if (!mounted) return;

    setState(() {
      isDecrypting = true;
      decryptionError = null;
    });

    try {
      dynamic json = jsonDecode(widget.data.encryptionMetadata!);
      fileName = json['filename'] ?? "File";

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
          decryptionError = 'Failed to decrypt: ${e.toString()}';
          isDecrypting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isDecrypting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (decryptionError != null) {
      return Container(
        padding: EdgeInsets.all(getProportionateScreenWidth(8)),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(getProportionateScreenWidth(5)),
        ),
        child: Icon(Icons.error_outline, color: Colors.red),
      );
    }

    return GestureDetector(
      onTap: () {
        OpenFile.open(decryptedFile!.path);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(getProportionateScreenWidth(5)),
          color: Theme.of(context).cardColor,
        ),
        padding: EdgeInsets.all(getProportionateScreenWidth(8)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insert_drive_file,
              size: getProportionateScreenWidth(24),
            ),
            SizedBox(height: getProportionateScreenHeight(4)),
            Text(
              fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: getProportionateScreenHeight(12)),
            ),
          ],
        ),
      ),
    );
  }
}

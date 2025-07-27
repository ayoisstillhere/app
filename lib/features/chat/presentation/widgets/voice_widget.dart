import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../services/file_encryptor.dart';
import '../../../../size_config.dart';
import '../../domain/entities/get_media_response_entity.dart';

class VoiceWidget extends StatefulWidget {
  final Datum data;

  const VoiceWidget({super.key, required this.data});

  @override
  State<VoiceWidget> createState() => _VoiceWidgetState();
}

class _VoiceWidgetState extends State<VoiceWidget> {
  bool isDecrypting = true;
  String? decryptionError;
  File? decryptedFile;
  bool isPlaying = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _decryptFile();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _setupAudio() async {
    if (decryptedFile != null) {
      try {
        await _audioPlayer.setFilePath(decryptedFile!.path);
        _audioPlayer.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            setState(() {
              isPlaying = false;
            });
          }
        });
      } catch (e) {
        // Handle audio setup error
      }
    }
  }

  void _togglePlay() async {
    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
      setState(() {
        isPlaying = false;
      });
    } else {
      await _audioPlayer.play();
      setState(() {
        isPlaying = true;
      });
    }
  }

  Future<void> _decryptFile() async {
    if (!mounted) return;

    setState(() {
      isDecrypting = true;
      decryptionError = null;
    });
    await _setupAudio();

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
          decryptionError = 'Failed to decrypt: ${e.toString()}';
          isDecrypting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isDecrypting) {
      return const ListTile(
        leading: CircularProgressIndicator(),
        title: Text("Loading voice message..."),
      );
    }

    if (decryptionError != null) {
      return ListTile(
        leading: Icon(Icons.error_outline, color: Colors.red),
        title: Text("Error loading voice message"),
      );
    }

    return ListTile(
      leading: IconButton(
        icon: Icon(
          isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
        ),
        onPressed: _togglePlay,
        iconSize: getProportionateScreenWidth(32),
      ),
      title: Text(
        "Voice message",
        style: TextStyle(
          fontSize: getProportionateScreenHeight(14),
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        "Recorded  ${_formatTime(widget.data.createdAt)}",
        style: TextStyle(fontSize: getProportionateScreenHeight(12)),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }
}

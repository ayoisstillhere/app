import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:app/features/chat/domain/entities/text_message_entity.dart';
import 'package:just_audio/just_audio.dart';
import 'package:open_file/open_file.dart';

import '../../../../constants.dart';
import '../../../../services/file_encryptor.dart';
import '../../../../size_config.dart';

class MessageBubble extends StatefulWidget {
  final TextMessageEntity message;
  final bool isDark;
  final String imageUrl;
  final UserEntity currentUser;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isDark,
    required this.imageUrl,
    required this.currentUser,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  File? decryptedFile;
  bool isDecrypting = false;
  String? decryptionError;
  late AudioPlayer _audioPlayer;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  Future<void> _decryptFile() async {
    if (!mounted) return;
    if (widget.message.type == MessageType.TEXT.name) return;

    setState(() {
      isDecrypting = true;
      decryptionError = null;
    });

    try {
      dynamic json = jsonDecode(widget.message.encryptionMetadata!);
      final file = await FileEncryptor.secureDownloadAndDecrypt(
        widget.message.mediaUrl!,
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

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void initState() {
    super.initState();
    // Call async method properly
    _decryptFile();
    _audioPlayer = AudioPlayer();

    // Using mounted check to prevent updates after widget disposal
    _audioPlayer.durationStream.listen((d) {
      if (mounted) setState(() => duration = d ?? Duration.zero);
    });
    _audioPlayer.positionStream.listen((p) {
      if (mounted) setState(() => position = p);
    });
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) setState(() => isPlaying = state.playing);
    });
  }

  @override
  void dispose() {
    // Make sure we stop playback before disposing
    if (_audioPlayer.playing) {
      _audioPlayer.stop().then((_) {
        _audioPlayer.dispose();
      });
    } else {
      _audioPlayer.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMe = widget.message.senderId == widget.currentUser.id;
    final bubbleColor = widget.isDark
        ? kGreyInputFillDark
        : kGreyInputBorder.withValues(alpha: 0.3);

    final textColor = isMe ? kWhite : (widget.isDark ? kWhite : kBlack);

    if (widget.message.type == MessageType.TEXT.name) {
      return _buildTextMessage(isMe, bubbleColor, textColor);
    } else if (widget.message.type == MessageType.IMAGE.name) {
      return _buildImageMessage();
    } else if (widget.message.type == MessageType.VIDEO.name) {
      return _buildVideoMessage();
    } else if (widget.message.type == MessageType.AUDIO.name) {
      return _buildAudioMessage();
    } else if (widget.message.type == MessageType.FILE.name) {
      return _buildFileMessage();
    } else {
      return Container();
    }
  }

  Widget _buildLoadingOrError() {
    final bool isMe = widget.message.senderId == widget.currentUser.id;
    final bubbleColor = widget.isDark
        ? kGreyInputFillDark
        : kGreyInputBorder.withValues(alpha: 0.3);
    final textColor = isMe ? kWhite : (widget.isDark ? kWhite : kBlack);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: getProportionateScreenHeight(2)),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            Container(
              height: getProportionateScreenHeight(24),
              width: getProportionateScreenWidth(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(widget.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: getProportionateScreenWidth(8)),
          ],
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: getProportionateScreenWidth(280),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: getProportionateScreenWidth(16),
                  vertical: getProportionateScreenHeight(12),
                ),
                decoration: isMe
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          getProportionateScreenWidth(10),
                        ),
                        gradient: kChatBubbleGradient,
                      )
                    : BoxDecoration(
                        color: bubbleColor,
                        borderRadius: BorderRadius.circular(
                          getProportionateScreenWidth(10),
                        ),
                      ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isDecrypting) ...[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: getProportionateScreenWidth(16),
                            height: getProportionateScreenHeight(16),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                textColor,
                              ),
                            ),
                          ),
                          SizedBox(width: getProportionateScreenWidth(8)),
                          Text(
                            'Decrypting...',
                            style: TextStyle(
                              color: textColor,
                              fontSize: getProportionateScreenHeight(12),
                            ),
                          ),
                        ],
                      ),
                    ] else if (decryptionError != null) ...[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error,
                            color: Colors.red,
                            size: getProportionateScreenHeight(16),
                          ),
                          SizedBox(width: getProportionateScreenWidth(8)),
                          Expanded(
                            child: Text(
                              decryptionError!,
                              style: TextStyle(
                                color: textColor,
                                fontSize: getProportionateScreenHeight(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    SizedBox(height: getProportionateScreenHeight(4)),
                    Text(
                      _formatTime(widget.message.createdAt.toDate()),
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.6),
                        fontSize: getProportionateScreenHeight(10),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding _buildTextMessage(bool isMe, Color bubbleColor, Color textColor) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: getProportionateScreenHeight(2)),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            Container(
              height: getProportionateScreenHeight(24),
              width: getProportionateScreenWidth(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(widget.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: getProportionateScreenWidth(8)),
          ],

          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: getProportionateScreenWidth(300),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: getProportionateScreenWidth(16),
                  vertical: getProportionateScreenHeight(10),
                ),
                decoration: isMe
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          getProportionateScreenWidth(10),
                        ),
                        gradient: kChatBubbleGradient,
                      )
                    : BoxDecoration(
                        color: bubbleColor,
                        borderRadius: BorderRadius.circular(
                          getProportionateScreenWidth(10),
                        ),
                      ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.message.content,
                      style: TextStyle(
                        color: textColor,
                        fontSize: getProportionateScreenHeight(14),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: getProportionateScreenHeight(2)),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(widget.message.createdAt.toDate()),
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.6),
                            fontSize: getProportionateScreenHeight(10),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageMessage() {
    // Show loading/error state if file is not ready
    if (isDecrypting || decryptionError != null || decryptedFile == null) {
      return _buildLoadingOrError();
    }

    final bool isMe = widget.message.senderId == widget.currentUser.id;
    final bubbleColor = widget.isDark
        ? kGreyInputFillDark
        : kGreyInputBorder.withValues(alpha: 0.3);
    final textColor = isMe ? kWhite : (widget.isDark ? kWhite : kBlack);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: getProportionateScreenHeight(2)),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            Container(
              height: getProportionateScreenHeight(24),
              width: getProportionateScreenWidth(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(widget.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: getProportionateScreenWidth(8)),
          ],
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: getProportionateScreenWidth(250),
              ),
              child: Container(
                padding: EdgeInsets.all(getProportionateScreenWidth(4)),
                decoration: isMe
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          getProportionateScreenWidth(10),
                        ),
                        gradient: kChatBubbleGradient,
                      )
                    : BoxDecoration(
                        color: bubbleColor,
                        borderRadius: BorderRadius.circular(
                          getProportionateScreenWidth(10),
                        ),
                      ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        getProportionateScreenWidth(8),
                      ),
                      child: Image.file(
                        decryptedFile!,
                        width: double.infinity,
                        height: getProportionateScreenHeight(200),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return SizedBox(
                            height: getProportionateScreenHeight(200),
                            child: Center(
                              child: Icon(
                                Icons.error,
                                color: textColor,
                                size: getProportionateScreenHeight(24),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: getProportionateScreenHeight(4)),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(widget.message.createdAt.toDate()),
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.6),
                            fontSize: getProportionateScreenHeight(10),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoMessage() {
    // Show loading/error state if file is not ready
    if (isDecrypting || decryptionError != null || decryptedFile == null) {
      return _buildLoadingOrError();
    }

    final bool isMe = widget.message.senderId == widget.currentUser.id;
    final bubbleColor = widget.isDark
        ? kGreyInputFillDark
        : kGreyInputBorder.withValues(alpha: 0.3);
    final textColor = isMe ? kWhite : (widget.isDark ? kWhite : kBlack);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: getProportionateScreenHeight(2)),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            Container(
              height: getProportionateScreenHeight(24),
              width: getProportionateScreenWidth(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(widget.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: getProportionateScreenWidth(8)),
          ],
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: getProportionateScreenWidth(250),
              ),
              child: Container(
                padding: EdgeInsets.all(getProportionateScreenWidth(4)),
                decoration: isMe
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          getProportionateScreenWidth(10),
                        ),
                        gradient: kChatBubbleGradient,
                      )
                    : BoxDecoration(
                        color: bubbleColor,
                        borderRadius: BorderRadius.circular(
                          getProportionateScreenWidth(10),
                        ),
                      ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Handle video playback - you'll need to implement this
                        // For example, navigate to a video player screen
                        // print('Play video: ${decryptedFile!.path}');
                      },
                      child: Container(
                        height: getProportionateScreenHeight(200),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(
                            getProportionateScreenWidth(8),
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Video thumbnail - you might want to generate this from the video file
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(
                                  getProportionateScreenWidth(8),
                                ),
                              ),
                              child: Icon(
                                Icons.videocam,
                                size: getProportionateScreenHeight(40),
                                color: Colors.grey[400],
                              ),
                            ),
                            // Play button overlay
                            Container(
                              height: getProportionateScreenHeight(50),
                              width: getProportionateScreenWidth(50),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: getProportionateScreenHeight(30),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: getProportionateScreenHeight(4)),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.videocam,
                          size: getProportionateScreenHeight(12),
                          color: textColor.withValues(alpha: 0.6),
                        ),
                        SizedBox(width: getProportionateScreenWidth(4)),
                        Text(
                          'Video',
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.8),
                            fontSize: getProportionateScreenHeight(12),
                          ),
                        ),
                        SizedBox(width: getProportionateScreenWidth(8)),
                        Text(
                          _formatTime(widget.message.createdAt.toDate()),
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.6),
                            fontSize: getProportionateScreenHeight(10),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioMessage() {
    // Show loading/error state if file is not ready
    if (isDecrypting || decryptionError != null || decryptedFile == null) {
      return _buildLoadingOrError();
    }

    final bool isMe = widget.message.senderId == widget.currentUser.id;
    final bubbleColor = widget.isDark
        ? kGreyInputFillDark
        : kGreyInputBorder.withValues(alpha: 0.3);
    final textColor = isMe ? kWhite : (widget.isDark ? kWhite : kBlack);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: getProportionateScreenHeight(2)),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            Container(
              height: getProportionateScreenHeight(24),
              width: getProportionateScreenWidth(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(widget.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: getProportionateScreenWidth(8)),
          ],
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: getProportionateScreenWidth(280),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: getProportionateScreenWidth(16),
                  vertical: getProportionateScreenHeight(12),
                ),
                decoration: isMe
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          getProportionateScreenWidth(10),
                        ),
                        gradient: kChatBubbleGradient,
                      )
                    : BoxDecoration(
                        color: bubbleColor,
                        borderRadius: BorderRadius.circular(
                          getProportionateScreenWidth(10),
                        ),
                      ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            try {
                              if (isPlaying) {
                                await _audioPlayer.pause();
                              } else {
                                // Check if we need to load the file first
                                if (_audioPlayer.audioSource == null) {
                                  // Make sure the widget is still mounted before proceeding
                                  if (!mounted) return;
                                  await _audioPlayer.setFilePath(
                                    decryptedFile!.path,
                                  );
                                }
                                await _audioPlayer.play();
                              }
                            } catch (e) {
                              // print('Audio play error: $e');
                            }
                          },
                          child: Container(
                            height: getProportionateScreenHeight(40),
                            width: getProportionateScreenWidth(40),
                            decoration: BoxDecoration(
                              color: textColor.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: textColor,
                              size: getProportionateScreenHeight(20),
                            ),
                          ),
                        ),
                        SizedBox(width: getProportionateScreenWidth(12)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Audio progress bar
                              SizedBox(
                                height: getProportionateScreenHeight(20),
                                child: Stack(
                                  alignment: Alignment.centerLeft,
                                  children: [
                                    Container(
                                      height: getProportionateScreenHeight(4),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: textColor.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    if (duration != Duration.zero)
                                      FractionallySizedBox(
                                        widthFactor:
                                            position.inMilliseconds /
                                            (duration.inMilliseconds == 0
                                                ? 1
                                                : duration.inMilliseconds),
                                        child: Container(
                                          height: getProportionateScreenHeight(
                                            4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: textColor,
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              SizedBox(height: getProportionateScreenHeight(4)),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(position),
                                    style: TextStyle(
                                      color: textColor.withValues(alpha: 0.6),
                                      fontSize: getProportionateScreenHeight(
                                        10,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _formatDuration(duration),
                                    style: TextStyle(
                                      color: textColor.withValues(alpha: 0.6),
                                      fontSize: getProportionateScreenHeight(
                                        10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: getProportionateScreenHeight(4)),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.mic,
                          size: getProportionateScreenHeight(12),
                          color: textColor.withValues(alpha: 0.6),
                        ),
                        SizedBox(width: getProportionateScreenWidth(4)),
                        Text(
                          'Voice message',
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.8),
                            fontSize: getProportionateScreenHeight(12),
                          ),
                        ),
                        SizedBox(width: getProportionateScreenWidth(8)),
                        Text(
                          _formatTime(widget.message.createdAt.toDate()),
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.6),
                            fontSize: getProportionateScreenHeight(10),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileMessage() {
    // Show loading/error state if file is not ready
    if (isDecrypting || decryptionError != null || decryptedFile == null) {
      return _buildLoadingOrError();
    }

    final bool isMe = widget.message.senderId == widget.currentUser.id;
    final bubbleColor = widget.isDark
        ? kGreyInputFillDark
        : kGreyInputBorder.withValues(alpha: 0.3);
    final textColor = isMe ? kWhite : (widget.isDark ? kWhite : kBlack);

    // Extract file name from decrypted file path
    final fileName = decryptedFile!.path.split('/').last;
    final fileExtension = fileName.split('.').last.toUpperCase();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: getProportionateScreenHeight(2)),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            Container(
              height: getProportionateScreenHeight(24),
              width: getProportionateScreenWidth(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(widget.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: getProportionateScreenWidth(8)),
          ],
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: getProportionateScreenWidth(280),
              ),
              child: GestureDetector(
                onTap: () async {
                  try {
                    // Use OpenFile to open the file with the default app
                    final result = await OpenFile.open(decryptedFile!.path);
                    if (result.type != ResultType.done) {
                      // print('Error opening file: ${result.message}');
                    }
                  } catch (e) {
                    // print('Error opening file: $e');
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: getProportionateScreenWidth(16),
                    vertical: getProportionateScreenHeight(12),
                  ),
                  decoration: isMe
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            getProportionateScreenWidth(10),
                          ),
                          gradient: kChatBubbleGradient,
                        )
                      : BoxDecoration(
                          color: bubbleColor,
                          borderRadius: BorderRadius.circular(
                            getProportionateScreenWidth(10),
                          ),
                        ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: getProportionateScreenHeight(40),
                            width: getProportionateScreenWidth(40),
                            decoration: BoxDecoration(
                              color: textColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                fileExtension.length > 3
                                    ? fileExtension.substring(0, 3)
                                    : fileExtension,
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: getProportionateScreenHeight(12),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: getProportionateScreenWidth(12)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fileName.length > 20
                                      ? '${fileName.substring(0, 17)}...'
                                      : fileName,
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: getProportionateScreenHeight(14),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(
                                  height: getProportionateScreenHeight(2),
                                ),
                                Text(
                                  'Tap to open',
                                  style: TextStyle(
                                    color: textColor.withValues(alpha: 0.6),
                                    fontSize: getProportionateScreenHeight(10),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: getProportionateScreenHeight(4)),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getFileIcon(fileExtension),
                            size: getProportionateScreenHeight(12),
                            color: textColor.withValues(alpha: 0.6),
                          ),
                          SizedBox(width: getProportionateScreenWidth(4)),
                          Text(
                            'File',
                            style: TextStyle(
                              color: textColor.withValues(alpha: 0.8),
                              fontSize: getProportionateScreenHeight(12),
                            ),
                          ),
                          SizedBox(width: getProportionateScreenWidth(8)),
                          Text(
                            _formatTime(widget.message.createdAt.toDate()),
                            style: TextStyle(
                              color: textColor.withValues(alpha: 0.6),
                              fontSize: getProportionateScreenHeight(10),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  } // Helper method to get appropriate file icon

  IconData _getFileIcon(String fileExtension) {
    switch (fileExtension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'zip':
      case 'rar':
        return Icons.folder_zip;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }
}

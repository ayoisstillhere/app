import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:app/features/chat/domain/entities/text_message_entity.dart';
import 'package:just_audio/just_audio.dart';
import 'package:open_file/open_file.dart';

import '../../../../components/full_screen_file_image_viewer.dart';
import '../../../../constants.dart';
import '../../../../services/file_encryptor.dart';
import '../../../../services/media_download_service.dart';
import '../../../../services/message_reaction_service.dart';
import '../../../../size_config.dart';
import 'full_screen_video_player.dart';
import 'message_reactions_display.dart';
import 'reaction_picker.dart';

class MessageBubble extends StatefulWidget {
  final TextMessageEntity message;
  final bool isDark;
  final String imageUrl;
  final UserEntity currentUser;
  final String? username;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isDark,
    required this.imageUrl,
    required this.currentUser,
    this.username = '',
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

  // Cache management
  static const String _cacheKeyPrefix = 'cached_file_';
  static const String _cacheMetadataKey = 'cache_metadata';
  static const int _maxCacheSize = 100 * 1024 * 1024; // 100MB
  static const int _maxCacheAge =
      7 * 24 * 60 * 60 * 1000; // 7 days in milliseconds

  // Add these for reactions
  bool _showReactionPicker = false;
  OverlayEntry? _reactionPickerOverlay;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _decryptFile();
    _audioPlayer = AudioPlayer();

    _audioPlayer.durationStream.listen((d) {
      if (mounted) setState(() => duration = d ?? Duration.zero);
    });

    _audioPlayer.positionStream.listen((p) {
      if (mounted) setState(() => position = p);
    });

    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          isPlaying = state.playing;
        });

        // Handle playback completion
        if (state.processingState == ProcessingState.completed) {
          if (mounted) {
            setState(() {
              isPlaying = false;
              position = Duration.zero;
            });
          }
          // Reset to beginning for next play
          _audioPlayer.stop();
          _audioPlayer.seek(Duration.zero);
        }
      }
    });
  }

  // Add these methods for reaction handling
  void _showReactionPickerOverlay() {
    if (_reactionPickerOverlay != null) {
      _hideReactionPickerOverlay();
      return;
    }

    // Add this check before creating overlay
    if (!mounted || !context.mounted) return;

    setState(() {
      _showReactionPicker = true;
    });

    _reactionPickerOverlay = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, -60),
          child: Material(
            color: Colors.transparent,
            child: Container(
              alignment: Alignment.center,
              child: ReactionPicker(
                onReactionSelected: _handleReactionSelected,
                onCancel: _hideReactionPickerOverlay,
              ),
            ),
          ),
        ),
      ),
    );

    // Add safety check before inserting overlay
    if (mounted && context.mounted) {
      Overlay.of(context).insert(_reactionPickerOverlay!);
    }
  }

  void _hideReactionPickerOverlay() {
    _reactionPickerOverlay?.remove();
    _reactionPickerOverlay = null;

    // Add this null check and ensure widget is still active
    if (mounted && context.mounted) {
      setState(() {
        _showReactionPicker = false;
      });
    }
  }

  void _handleReactionSelected(String emoji) async {
    _hideReactionPickerOverlay();

    // Check if current user has already reacted with this emoji
    final reactions = widget.message.reactions;
    final userIds = reactions[emoji] as List<String>? ?? [];
    final hasReacted = userIds.contains(widget.currentUser.id);

    bool success;
    if (hasReacted) {
      success = await MessageReactionsService.removeReaction(
        widget.message.id,
        emoji,
      );
    } else {
      success = await MessageReactionsService.addReaction(
        widget.message.id,
        emoji,
      );
    }

    if (!success) {
      _showSnackBar('Failed to update reaction');
    }
    // Note: You'll need to update the message in your parent widget
    // when reactions change, typically through a callback or state management
  }

  void _handleReactionTap(String emoji) async {
    // Toggle reaction when tapping existing reaction
    final reactions = widget.message.reactions ?? {};
    final userIds =
        (reactions[emoji] as List?)
            ?.map((item) => item['userId'] as String)
            .toList() ??
        <String>[];
    final hasReacted = userIds.contains(widget.currentUser.id);

    bool success;
    if (hasReacted) {
      success = await MessageReactionsService.removeReaction(
        widget.message.id,
        emoji,
      );
    } else {
      success = await MessageReactionsService.addReaction(
        widget.message.id,
        emoji,
      );
    }

    if (!success) {
      _showSnackBar('Failed to update reaction');
    }
  }

  Future<String> _getCacheKey() async {
    // Create a unique cache key based on message ID and media URL
    final content = '${widget.message.id}_${widget.message.mediaUrl}';
    final bytes = utf8.encode(content);
    final digest = sha256.convert(bytes);
    return '$_cacheKeyPrefix${digest.toString()}';
  }

  Future<Directory> _getCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/message_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  Future<File?> _getCachedFile() async {
    try {
      final cacheKey = await _getCacheKey();
      final prefs = await SharedPreferences.getInstance();
      final cachedPath = prefs.getString(cacheKey);

      if (cachedPath != null) {
        final file = File(cachedPath);
        if (await file.exists()) {
          // Check if file is still valid (not too old)
          final stat = await file.stat();
          final now = DateTime.now().millisecondsSinceEpoch;
          final fileAge = now - stat.modified.millisecondsSinceEpoch;

          if (fileAge < _maxCacheAge) {
            return file;
          } else {
            // File is too old, remove it
            await _removeCachedFile(cacheKey, cachedPath);
          }
        } else {
          // File doesn't exist, remove from cache
          await prefs.remove(cacheKey);
        }
      }
    } catch (e) {
      debugPrint('Error getting cached file: $e');
    }
    return null;
  }

  Future<void> _cacheFile(File file) async {
    try {
      final cacheKey = await _getCacheKey();
      final cacheDir = await _getCacheDirectory();

      // Create cache filename with original extension
      dynamic json = jsonDecode(widget.message.encryptionMetadata!);
      final originalFilename = json['filename'] as String;
      final extension = originalFilename.split('.').last;
      final cacheFilename =
          '${cacheKey.replaceAll(_cacheKeyPrefix, '')}.$extension';
      final cachedFile = File('${cacheDir.path}/$cacheFilename');

      // Copy file to cache directory
      await file.copy(cachedFile.path);

      // Store cache reference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(cacheKey, cachedFile.path);

      // Update cache metadata
      await _updateCacheMetadata(
        cacheKey,
        cachedFile.path,
        await cachedFile.length(),
      );

      // Clean up old cache if needed
      await _cleanupOldCache();
    } catch (e) {
      debugPrint('Error caching file: $e');
    }
  }

  Future<void> _updateCacheMetadata(String key, String path, int size) async {
    final prefs = await SharedPreferences.getInstance();
    final metadataJson = prefs.getString(_cacheMetadataKey) ?? '{}';
    final metadata = jsonDecode(metadataJson) as Map<String, dynamic>;

    metadata[key] = {
      'path': path,
      'size': size,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    await prefs.setString(_cacheMetadataKey, jsonEncode(metadata));
  }

  Future<void> _removeCachedFile(String key, String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);

      // Update metadata
      final metadataJson = prefs.getString(_cacheMetadataKey) ?? '{}';
      final metadata = jsonDecode(metadataJson) as Map<String, dynamic>;
      metadata.remove(key);
      await prefs.setString(_cacheMetadataKey, jsonEncode(metadata));
    } catch (e) {
      debugPrint('Error removing cached file: $e');
    }
  }

  Future<void> _cleanupOldCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metadataJson = prefs.getString(_cacheMetadataKey) ?? '{}';
      final metadata = jsonDecode(metadataJson) as Map<String, dynamic>;

      // Calculate total cache size
      int totalSize = 0;
      final entries = <MapEntry<String, dynamic>>[];

      for (final entry in metadata.entries) {
        final data = entry.value as Map<String, dynamic>;
        totalSize += data['size'] as int;
        entries.add(MapEntry(entry.key, data));
      }

      // If cache is too large, remove oldest files
      if (totalSize > _maxCacheSize) {
        entries.sort(
          (a, b) => (a.value['timestamp'] as int).compareTo(
            b.value['timestamp'] as int,
          ),
        );

        for (final entry in entries) {
          if (totalSize <= _maxCacheSize * 0.8)
            break; // Clean to 80% of max size

          final data = entry.value as Map<String, dynamic>;
          await _removeCachedFile(entry.key, data['path'] as String);
          totalSize -= data['size'] as int;
        }
      }

      // Remove files older than max age
      final now = DateTime.now().millisecondsSinceEpoch;
      final keysToRemove = <String>[];

      for (final entry in metadata.entries) {
        final data = entry.value as Map<String, dynamic>;
        final age = now - (data['timestamp'] as int);

        if (age > _maxCacheAge) {
          keysToRemove.add(entry.key);
        }
      }

      for (final key in keysToRemove) {
        final data = metadata[key] as Map<String, dynamic>;
        await _removeCachedFile(key, data['path'] as String);
      }
    } catch (e) {
      debugPrint('Error cleaning up cache: $e');
    }
  }

  // Update your _decryptFile method to preload audio duration
  Future<void> _decryptFile() async {
    if (!mounted) return;
    if (widget.message.type == MessageType.TEXT.name) return;

    // First, try to get cached file
    final cachedFile = await _getCachedFile();
    if (cachedFile != null) {
      if (mounted) {
        setState(() {
          decryptedFile = cachedFile;
        });
        // If it's an audio file, preload it to get duration
        if (widget.message.type == MessageType.AUDIO.name) {
          await _preloadAudioFile(cachedFile);
        }
      }
      return;
    }

    // If not cached, decrypt and cache
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

        // Cache the file for future use
        await _cacheFile(file);

        // If it's an audio file, preload it to get duration
        if (widget.message.type == MessageType.AUDIO.name) {
          await _preloadAudioFile(file);
        }
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

  // Add this method to preload audio file and get duration
  Future<void> _preloadAudioFile(File audioFile) async {
    try {
      await _audioPlayer.setFilePath(audioFile.path);
      // The duration will be automatically updated via the stream listener
    } catch (e) {
      // print('Error preloading audio file: $e');
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
  void dispose() {
    // Clean up overlay first before disposing other resources
    _hideReactionPickerOverlay();

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

    Widget messageContent;

    if (widget.message.type == MessageType.TEXT.name) {
      messageContent = _buildTextMessage(isMe, bubbleColor, textColor);
    } else if (widget.message.type == MessageType.IMAGE.name) {
      messageContent = _buildImageMessage();
    } else if (widget.message.type == MessageType.VIDEO.name) {
      messageContent = _buildVideoMessage();
    } else if (widget.message.type == MessageType.AUDIO.name) {
      messageContent = _buildAudioMessage();
    } else if (widget.message.type == MessageType.FILE.name) {
      messageContent = _buildFileMessage();
    } else {
      messageContent = Container();
    }

    return _buildMessageWithReactions(
      messageContent: messageContent,
      isMe: isMe,
      textColor: textColor,
    );
  }

  // Add this method to wrap your message content with long press detection
  Widget _buildMessageWithReactions({
    required Widget messageContent,
    required bool isMe,
    required Color textColor,
  }) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onLongPress: _showReactionPickerOverlay,
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            messageContent,
            // Add reactions display
            if (widget.message.reactions.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(
                  left: isMe ? 0 : getProportionateScreenWidth(32),
                ),
                child: MessageReactionsDisplay(
                  reactions: widget.message.reactions,
                  currentUser: widget.currentUser,
                  onReactionTap: _handleReactionTap,
                  isDark: widget.isDark,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Rest of your existing methods remain the same...
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
                  image: widget.imageUrl.isEmpty
                      ? NetworkImage(defaultAvatar)
                      : NetworkImage(widget.imageUrl),
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
                            'Loading...',
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
            Column(
              children: [
                Container(
                  height: getProportionateScreenHeight(24),
                  width: getProportionateScreenWidth(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: widget.imageUrl.isEmpty
                          ? NetworkImage(defaultAvatar)
                          : NetworkImage(widget.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // if (!isMe && widget.username!.isNotEmpty)
                //   Text(
                //     "${widget.username}",
                //     style: TextStyle(
                //       color: kWhite,
                //       fontSize: getProportionateScreenHeight(12),
                //     ),
                //   ),
              ],
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
                  horizontal: getProportionateScreenWidth(10),
                  vertical: getProportionateScreenHeight(2),
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
                  image: widget.imageUrl.isEmpty
                      ? NetworkImage(defaultAvatar)
                      : NetworkImage(widget.imageUrl),
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
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            getProportionateScreenWidth(8),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              if (decryptedFile != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        FullScreenFileImageViewer(
                                          imageFile: decryptedFile!,
                                          title: decryptedFile!.path
                                              .split('/')
                                              .last,
                                        ),
                                  ),
                                );
                              }
                            },
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
                        ),
                        // Download button overlay
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () =>
                                _showDownloadOptions(context, decryptedFile!),
                            child: Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.download,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
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
                  image: widget.imageUrl.isEmpty
                      ? NetworkImage(defaultAvatar)
                      : NetworkImage(widget.imageUrl),
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
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Navigate to full screen video player
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullScreenVideoPlayer(
                                  videoFile: decryptedFile!,
                                  message: widget.message,
                                ),
                              ),
                            );
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
                                // Video thumbnail
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
                        // Download button overlay
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () =>
                                _showDownloadOptions(context, decryptedFile!),
                            child: Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.download,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
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

  // Helper method to show download options
  void _showDownloadOptions(BuildContext context, File mediaFile) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Save to Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  await _downloadToGallery(mediaFile);
                },
              ),
              ListTile(
                leading: Icon(Icons.share),
                title: Text('Share'),
                onTap: () async {
                  Navigator.pop(context);
                  await _shareFile(mediaFile);
                },
              ),
              if (Platform.isAndroid)
                ListTile(
                  leading: Icon(Icons.download),
                  title: Text('Save to Downloads'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _downloadToFolder(mediaFile);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // Helper methods for download actions
  Future<void> _downloadToGallery(File mediaFile) async {
    try {
      bool success;
      if (mediaFile.path.toLowerCase().contains('.mp4') ||
          mediaFile.path.toLowerCase().contains('.mov')) {
        success = await MediaDownloadService.saveVideoToGallery(mediaFile);
      } else {
        success = await MediaDownloadService.saveImageToGallery(mediaFile);
      }

      _showSnackBar(success ? 'Saved to gallery' : 'Failed to save to gallery');
    } catch (e) {
      _showSnackBar('Error saving file');
    }
  }

  Future<void> _shareFile(File mediaFile) async {
    try {
      await SharePlus.instance.share(
        ShareParams(files: [XFile(mediaFile.path)]),
      );
    } catch (e) {
      _showSnackBar('Error sharing file');
    }
  }

  Future<void> _downloadToFolder(File mediaFile) async {
    try {
      final success = await MediaDownloadService.saveToDownloads(mediaFile);
      _showSnackBar(success ? 'Saved to Downloads' : 'Failed to save');
    } catch (e) {
      _showSnackBar('Error saving file');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
                  image: widget.imageUrl.isEmpty
                      ? NetworkImage(defaultAvatar)
                      : NetworkImage(widget.imageUrl),
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
                child: Row(
                  children: [
                    // Play/Pause button
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

                    // Audio bars visualization
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Audio bars with scrubbing capability
                          SizedBox(
                            height: getProportionateScreenHeight(24),
                            child: _buildScrubbableAudioBars(textColor),
                          ),
                          SizedBox(height: getProportionateScreenHeight(4)),

                          // Duration and timestamp row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.mic,
                                    size: getProportionateScreenHeight(12),
                                    color: textColor.withValues(alpha: 0.6),
                                  ),
                                  SizedBox(
                                    width: getProportionateScreenWidth(4),
                                  ),
                                  Text(
                                    isPlaying
                                        ? _formatDuration(
                                            duration - position,
                                          ) // Countdown when playing
                                        : _formatDuration(
                                            duration,
                                          ), // Total duration when not playing
                                    style: TextStyle(
                                      color: textColor.withValues(alpha: 0.8),
                                      fontSize: getProportionateScreenHeight(
                                        12,
                                      ),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrubbableAudioBars(Color textColor) {
    final int barCount = 40;
    final double maxHeight = getProportionateScreenHeight(20);
    final double minHeight = getProportionateScreenHeight(3);
    final double barWidth = getProportionateScreenWidth(2);
    final double barSpacing = getProportionateScreenWidth(1);

    return GestureDetector(
      onTapDown: (details) {
        _onAudioBarTap(details.localPosition);
      },
      onPanUpdate: (details) {
        _onAudioBarTap(details.localPosition);
      },
      child: SizedBox(
        height: maxHeight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(barCount, (index) {
                // Calculate progress based on current position
                final double progress = duration.inMilliseconds > 0
                    ? position.inMilliseconds / duration.inMilliseconds
                    : 0.0;

                // Determine if this bar should be "filled" (played)
                final bool isPlayed = (index / barCount) <= progress;

                // Generate varied heights for a more natural look
                final double heightFactor = _getBarHeight(index);
                final double barHeight =
                    minHeight + (maxHeight - minHeight) * heightFactor;

                return AnimatedContainer(
                  duration: Duration(milliseconds: 150),
                  width: barWidth,
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: isPlayed
                        ? textColor.withValues(alpha: 0.8)
                        : textColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(1),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }

  void _onAudioBarTap(Offset localPosition) async {
    if (duration.inMilliseconds > 0) {
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final double totalWidth =
          renderBox.size.width -
          getProportionateScreenWidth(
            16 * 2 + 40 + 12,
          ); // Account for padding and button

      final double progress = (localPosition.dx / totalWidth).clamp(0.0, 1.0);
      final Duration seekPosition = Duration(
        milliseconds: (duration.inMilliseconds * progress).round(),
      );

      try {
        await _audioPlayer.seek(seekPosition);
      } catch (e) {
        // print('Audio seek error: $e');
      }
    }
  }

  double _getBarHeight(int index) {
    // Create a pseudo-random but consistent pattern for bar heights
    // This simulates audio waveform visualization
    final List<double> pattern = [
      0.3,
      0.7,
      0.5,
      0.9,
      0.2,
      0.8,
      0.4,
      0.6,
      0.1,
      0.9,
      0.5,
      0.3,
      0.8,
      0.6,
      0.4,
      0.7,
      0.2,
      0.9,
      0.5,
      0.3,
      0.8,
      0.1,
      0.6,
      0.9,
      0.4,
      0.7,
      0.2,
      0.5,
      0.8,
      0.3,
      0.6,
      0.9,
      0.1,
      0.4,
      0.7,
      0.5,
      0.2,
      0.8,
      0.6,
      0.3,
    ];

    return pattern[index % pattern.length];
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
                  image: widget.imageUrl.isEmpty
                      ? NetworkImage(defaultAvatar)
                      : NetworkImage(widget.imageUrl),
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

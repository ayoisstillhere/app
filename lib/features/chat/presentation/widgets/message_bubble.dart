import 'package:flutter/material.dart';

import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:app/features/chat/domain/entities/text_message_entity.dart';

import '../../../../constants.dart';
import '../../../../size_config.dart';

class MessageBubble extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    final bool isMe = message.senderId == currentUser.id;
    final bubbleColor = isDark
        ? kGreyInputFillDark
        : kGreyInputBorder.withValues(alpha: 0.3);

    final textColor = isMe ? kWhite : (isDark ? kWhite : kBlack);

    if (message.type == MessageType.TEXT.name) {
      return _buildTextMessage(isMe, bubbleColor, textColor);
    } else if (message.type == MessageType.IMAGE.name) {
      return _buildImageMessage();
    } else if (message.type == MessageType.VIDEO.name) {
      return _buildVideoMessage();
    } else if (message.type == MessageType.AUDIO.name) {
      return _buildAudioMessage();
    } else if (message.type == MessageType.FILE.name) {
      return _buildFileMessage();
    } else {
      return Container();
    }
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
                  image: NetworkImage(imageUrl),
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
                      message.content,
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
                          _formatTime(message.createdAt.toDate()),
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

  // Add these methods to your MessageBubble class

  Padding _buildImageMessage() {
    final bool isMe = message.senderId == currentUser.id;
    final bubbleColor = isDark
        ? kGreyInputFillDark
        : kGreyInputBorder.withValues(alpha: 0.3);
    final textColor = isMe ? kWhite : (isDark ? kWhite : kBlack);

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
                  image: NetworkImage(imageUrl),
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
                      child: Image.network(
                        message.content, // Assuming content contains image URL
                        width: double.infinity,
                        height: getProportionateScreenHeight(200),
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return SizedBox(
                            height: getProportionateScreenHeight(200),
                            child: Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
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
                          _formatTime(message.createdAt.toDate()),
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

  Padding _buildVideoMessage() {
    final bool isMe = message.senderId == currentUser.id;
    final bubbleColor = isDark
        ? kGreyInputFillDark
        : kGreyInputBorder.withValues(alpha: 0.3);
    final textColor = isMe ? kWhite : (isDark ? kWhite : kBlack);

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
                  image: NetworkImage(imageUrl),
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
                    Container(
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
                          // Video thumbnail or placeholder
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(
                                getProportionateScreenWidth(8),
                              ),
                            ),
                            child: Icon(
                              Icons.videocam,
                              size: getProportionateScreenHeight(40),
                              color: Colors.grey[600],
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
                          _formatTime(message.createdAt.toDate()),
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

  Padding _buildAudioMessage() {
    final bool isMe = message.senderId == currentUser.id;
    final bubbleColor = isDark
        ? kGreyInputFillDark
        : kGreyInputBorder.withValues(alpha: 0.3);
    final textColor = isMe ? kWhite : (isDark ? kWhite : kBlack);

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
                  image: NetworkImage(imageUrl),
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
                        Container(
                          height: getProportionateScreenHeight(40),
                          width: getProportionateScreenWidth(40),
                          decoration: BoxDecoration(
                            color: textColor.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.play_arrow,
                            color: textColor,
                            size: getProportionateScreenHeight(20),
                          ),
                        ),
                        SizedBox(width: getProportionateScreenWidth(12)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Audio waveform placeholder
                              SizedBox(
                                height: getProportionateScreenHeight(20),
                                child: Row(
                                  children: List.generate(
                                    20,
                                    (index) => Container(
                                      width: getProportionateScreenWidth(2),
                                      height: getProportionateScreenHeight(
                                        (index % 4 + 1) * 5,
                                      ),
                                      margin: EdgeInsets.only(
                                        right: getProportionateScreenWidth(1),
                                      ),
                                      decoration: BoxDecoration(
                                        color: textColor.withValues(alpha: 0.6),
                                        borderRadius: BorderRadius.circular(1),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: getProportionateScreenHeight(4)),
                              Text(
                                '0:00', // Duration placeholder
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
                          _formatTime(message.createdAt.toDate()),
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

  Padding _buildFileMessage() {
    final bool isMe = message.senderId == currentUser.id;
    final bubbleColor = isDark
        ? kGreyInputFillDark
        : kGreyInputBorder.withValues(alpha: 0.3);
    final textColor = isMe ? kWhite : (isDark ? kWhite : kBlack);

    // Extract file name from content or use a default
    final fileName = message.content.split('/').last;
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
                  image: NetworkImage(imageUrl),
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
                        Container(
                          height: getProportionateScreenHeight(40),
                          width: getProportionateScreenWidth(40),
                          decoration: BoxDecoration(
                            color: textColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(
                              getProportionateScreenWidth(8),
                            ),
                          ),
                          child: Icon(
                            _getFileIcon(fileExtension),
                            color: textColor,
                            size: getProportionateScreenHeight(20),
                          ),
                        ),
                        SizedBox(width: getProportionateScreenWidth(12)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fileName,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: getProportionateScreenHeight(12),
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: getProportionateScreenHeight(2)),
                              Text(
                                '$fileExtension file',
                                style: TextStyle(
                                  color: textColor.withValues(alpha: 0.6),
                                  fontSize: getProportionateScreenHeight(10),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.download,
                          color: textColor.withValues(alpha: 0.6),
                          size: getProportionateScreenHeight(16),
                        ),
                      ],
                    ),
                    SizedBox(height: getProportionateScreenHeight(4)),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.attach_file,
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
                          _formatTime(message.createdAt.toDate()),
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

  // Helper method to get appropriate file icon
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

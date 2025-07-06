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
}

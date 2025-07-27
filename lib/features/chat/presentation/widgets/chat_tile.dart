import 'package:app/features/chat/presentation/pages/secret_chat_screen.dart';
import 'package:flutter/material.dart';

import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:app/features/chat/domain/entities/get_messages_response_entity.dart';
import 'package:app/features/chat/presentation/pages/chat_screen.dart';

import '../../../../constants.dart';
import '../../../../services/encryption_service.dart';
import '../../../../size_config.dart';

class ChatTile extends StatefulWidget {
  const ChatTile({
    super.key,
    required this.dividerColor,
    required this.image,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unreadMessages,
    required this.chatId,
    required this.currentUser,
    required this.encryptionKey,
    required this.chatHandle,
    required this.isGroup,
    required this.participants,
    required this.isConversationMuted,
    required this.isSecretChat,
    required this.isConversationBlockedForMe,
    this.isSelected = false,
    this.showCheckbox = false,
    this.onSelectionChanged,
  });

  final Color dividerColor;
  final String image;
  final String name;
  final String lastMessage;
  final DateTime time;
  final int unreadMessages;
  final String chatId;
  final UserEntity currentUser;
  final String? encryptionKey;
  final String chatHandle;
  final bool isGroup;
  final List<Participant> participants;
  final bool isConversationMuted;
  final bool isSecretChat;
  final bool isConversationBlockedForMe;
  final bool isSelected;
  final bool showCheckbox;
  final Function(bool)? onSelectionChanged;

  @override
  State<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  late final EncryptionService _encryptionService;
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  void _initializeServices() {
    _encryptionService = EncryptionService();
    _encryptionService.setSecretKey(
      '967f042a1b97cb7ec81f7b7825deae4b05a661aae329b738d7068b044de6f56a',
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (widget.isSecretChat) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SecretChatScreen(
                chatId: widget.chatId,
                name: widget.name,
                imageUrl: widget.image,
                currentUser: widget.currentUser,
                isGroup: widget.isGroup,
                chatHandle: widget.chatHandle,
                participants: widget.participants,
                isConversationMuted: widget.isConversationMuted,
                isConversationBlockedForMe: widget.isConversationBlockedForMe,
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                chatId: widget.chatId,
                name: widget.name,
                imageUrl: widget.image,
                currentUser: widget.currentUser,
                encryptionKey: widget.encryptionKey!,
                isGroup: widget.isGroup,
                chatHandle: widget.chatHandle,
                participants: widget.participants,
                isConversationMuted: widget.isConversationMuted,
                isConversationBlockedForMe: widget.isConversationBlockedForMe,
              ),
            ),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: getProportionateScreenHeight(10),
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: widget.dividerColor, width: 1.0),
          ),
        ),
        child: Row(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  height: getProportionateScreenHeight(56),
                  width: getProportionateScreenWidth(56),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: widget.image.isEmpty
                          ? NetworkImage(defaultAvatar)
                          : NetworkImage(widget.image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: getProportionateScreenWidth(16)),
                SizedBox(
                  height: getProportionateScreenHeight(47),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: getProportionateScreenHeight(16),
                        ),
                      ),
                      Spacer(),
                      SizedBox(
                        width: getProportionateScreenWidth(245),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: getProportionateScreenWidth(140),
                              child: Text(
                                widget.lastMessage,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: getProportionateScreenHeight(12),
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            widget.showCheckbox
                                ? Container()
                                : Text(
                                    _formatTime(widget.time),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: getProportionateScreenHeight(
                                        12,
                                      ),
                                      color: kGreyTimeText,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Spacer(),
            widget.showCheckbox
                ? SizedBox(
                    height: getProportionateScreenHeight(25),
                    width: getProportionateScreenWidth(25),
                    child: Checkbox(
                      value: widget.isSelected,
                      onChanged: (value) {
                        if (widget.onSelectionChanged != null) {
                          widget.onSelectionChanged!(value ?? false);
                        }
                      },
                    ),
                  )
                : widget.unreadMessages > 0
                ? Container(
                    height: getProportionateScreenHeight(25),
                    width: getProportionateScreenWidth(25),
                    decoration: BoxDecoration(
                      color: kAccentColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${widget.unreadMessages}',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: getProportionateScreenHeight(12),
                          color: Colors.black,
                        ),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
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

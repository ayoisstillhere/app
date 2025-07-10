import 'dart:convert';

import 'package:app/features/chat/data/models/get_messages_response_model.dart';
import 'package:app/features/chat/presentation/pages/secret_chat_screen.dart';
import 'package:fast_rsa/fast_rsa.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:timeago/timeago.dart' as timeago;

import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:app/features/chat/domain/entities/get_messages_response_entity.dart';
import 'package:app/features/chat/presentation/pages/chat_screen.dart';

import '../../../../constants.dart';
import '../../../../services/auth_manager.dart';
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
          ).then((result) {
            if (result != null && result['recreateSecretChat'] == true) {
              // Call a method to recreate the secret chat
              _recreateSecretChat(deleteFormerChat: true);
            }
          });
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
                            Text(
                              timeago.format(widget.time),
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: getProportionateScreenHeight(12),
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
            widget.unreadMessages > 0
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

  Future<void> _recreateSecretChat({bool deleteFormerChat = true}) async {
    if (widget.isGroup) {
      return;
    }
    final token = await AuthManager.getToken();
    final uri = Uri.parse('$baseUrl/api/v1/chat/secret-conversations');

    // Generate a conversation key for end-to-end encryption
    final conversationKey = _encryptionService.generateConversationKey();

    // Get the current user's participant data
    final myParticipant = widget.participants.firstWhere(
      (participant) => participant.userId == widget.currentUser.id,
      orElse: () => throw Exception("Current user not found in participants"),
    );

    // Get the other participant's data
    final otherParticipant = widget.participants.firstWhere(
      (participant) => participant.userId != widget.currentUser.id,
      orElse: () => throw Exception("Other participant not found"),
    );

    // Get both public keys
    final myPublicKey = myParticipant.user.publicKey;
    final otherPublicKey = otherParticipant.user.publicKey;

    // Use RSA to encrypt the conversation key with both public keys
    final myEncryptedKey = await RSA.encryptPKCS1v15(
      conversationKey,
      myPublicKey!,
    );
    final otherEncryptedKey = await RSA.encryptPKCS1v15(
      conversationKey,
      otherPublicKey!,
    );

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "participantUserIds": widget.participants.map((e) => e.userId).toList(),
      "myConversationKey": myEncryptedKey,
      "otherParticipantConversationKey": otherEncryptedKey,
      "deleteFormerChat": deleteFormerChat,
    });

    try {
      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SecretChatScreen(
              chatId: jsonDecode(response.body)['id'],
              name: widget.name,
              imageUrl: widget.image,
              currentUser: widget.currentUser,
              chatHandle: widget.chatHandle,
              isGroup: false,
              participants: (jsonDecode(response.body)['participants'] as List)
                  .map((e) => ParticipantModel.fromJson(e))
                  .toList(),

              isConversationMuted: jsonDecode(
                response.body,
              )['isConversationMutedForMe'],
              isConversationBlockedForMe: jsonDecode(
                response.body,
              )['isConversationBlockedForMe'],
            ),
          ),
        ).then((result) {
          if (result != null && result['recreateSecretChat'] == true) {
            _recreateSecretChat(deleteFormerChat: true);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(e.toString(), style: TextStyle(color: Colors.white)),
        ),
      );
    }
  }
}

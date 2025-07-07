import 'dart:convert';

import 'package:app/constants.dart';
import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:app/features/chat/data/models/get_messages_response_model.dart';
import 'package:app/features/chat/domain/entities/get_messages_response_entity.dart';
import 'package:app/features/chat/presentation/pages/chat_screen.dart';
import 'package:app/features/chat/presentation/pages/secret_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../services/auth_manager.dart';
import '../../../../size_config.dart';

class ChatSuggestionTile extends StatefulWidget {
  const ChatSuggestionTile({
    super.key,
    required this.dividerColor,
    required this.image,
    required this.name,
    required this.handle,
    required this.isSelected,
    this.showCheckbox = false,
    this.onSelectionChanged,
    required this.userId,
    required this.currentUser,
  });

  final Color dividerColor;
  final String image;
  final String name;
  final String handle;
  final bool isSelected;
  final bool showCheckbox;
  final Function(bool)? onSelectionChanged;
  final String userId;
  final UserEntity currentUser;

  @override
  State<ChatSuggestionTile> createState() => _ChatSuggestionTileState();
}

class _ChatSuggestionTileState extends State<ChatSuggestionTile> {
  List<String> selectedUsers = [];

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (!widget.showCheckbox) {
          selectedUsers.add(widget.userId);
          selectedUsers.add(widget.currentUser.id);
          await _createChat(selectedUsers);
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: getProportionateScreenHeight(56),
              width: getProportionateScreenWidth(56),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(widget.image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: getProportionateScreenWidth(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: getProportionateScreenHeight(16),
                    ),
                  ),
                  SizedBox(height: getProportionateScreenHeight(4)),
                  Text(
                    '@${widget.handle}',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: getProportionateScreenHeight(12),
                      color: Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            if (widget.showCheckbox)
              Checkbox(
                value: widget.isSelected,
                onChanged: (value) {
                  if (widget.onSelectionChanged != null) {
                    widget.onSelectionChanged!(value ?? false);
                  }
                },
                checkColor: Colors.white,
                activeColor: kAccentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    getProportionateScreenWidth(5),
                  ),
                ),
                side: BorderSide(
                  color:
                      MediaQuery.of(context).platformBrightness ==
                          Brightness.dark
                      ? kGreyInputFillDark
                      : kLightPurple,
                  width: 1.0,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _createChat(List selectedUsers) async {
    final url = Uri.parse('$baseUrl/api/v1/chat/conversations');
    final token = await AuthManager.getToken();

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "participantUserIds": selectedUsers,
      "type": "DIRECT",
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (jsonDecode(response.body)['isSecret']) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SecretChatScreen(
                chatId: jsonDecode(response.body)['id'],
                name: widget.name,
                imageUrl: widget.image,
                currentUser: widget.currentUser,
                encryptionKey: jsonDecode(response.body)['encryptionKey'],
                chatHandle: widget.handle,
                isGroup: false,
                participants: List<Participant>.from(
                  (jsonDecode(response.body)['participants'] as List)
                      .map((e) => ParticipantModel.fromJson(e))
                      .toList(),
                ),
                isConversationMuted: jsonDecode(
                  response.body,
                )['isConversationMutedForMe'],
              ),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                chatId: jsonDecode(response.body)['id'],
                name: widget.name,
                imageUrl: widget.image,
                currentUser: widget.currentUser,
                encryptionKey: jsonDecode(response.body)['encryptionKey'],
                chatHandle: widget.handle,
                isGroup: false,
                participants: List<Participant>.from(
                  (jsonDecode(response.body)['participants'] as List)
                      .map((e) => ParticipantModel.fromJson(e))
                      .toList(),
                ),
                isConversationMuted: jsonDecode(
                  response.body,
                )['isConversationMutedForMe'],
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              jsonDecode(
                response.body,
              )['message'].toString().replaceAll(RegExp(r'\[|\]'), ''),
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            jsonDecode(
              "$e",
            )['message'].toString().replaceAll(RegExp(r'\[|\]'), ''),
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }
}

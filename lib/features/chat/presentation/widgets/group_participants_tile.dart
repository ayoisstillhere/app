import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../constants.dart';
import '../../../../services/auth_manager.dart';
import '../../../../size_config.dart';
import '../../domain/entities/get_messages_response_entity.dart';

class GroupParticipantsTile extends StatefulWidget {
  const GroupParticipantsTile({
    super.key,
    required this.dividerColor,
    required this.participant,
    required this.conversationId,
  });

  final Color dividerColor;
  final Participant participant;
  final String conversationId;

  @override
  State<GroupParticipantsTile> createState() => _GroupParticipantsTileState();
}

class _GroupParticipantsTileState extends State<GroupParticipantsTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: getProportionateScreenHeight(10)),
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
                image: widget.participant.user.profileImage!.isEmpty
                    ? NetworkImage(defaultAvatar)
                    : NetworkImage(widget.participant.user.profileImage!),
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
                  widget.participant.user.fullName!,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: getProportionateScreenHeight(16),
                  ),
                ),
                SizedBox(height: getProportionateScreenHeight(4)),
                Text(
                  '@${widget.participant.user.username}',
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
          InkWell(
            onTap: _removeParticipant,
            child: Text(
              "Remove",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
                fontSize: getProportionateScreenHeight(13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _removeParticipant() async {
    final token = await AuthManager.getToken();
    try {
      final response = await http.put(
        Uri.parse(
          '$baseUrl/api/v1/chat/conversations/${widget.conversationId}/remove-participant',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'userId': widget.participant.userId}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "Participant removed successfully.",
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
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
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Failed to remove participant. Please try again.",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }
}

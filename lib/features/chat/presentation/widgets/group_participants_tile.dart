import 'package:flutter/material.dart';

import '../../../../constants.dart';
import '../../../../size_config.dart';
import '../../domain/entities/get_messages_response_entity.dart';

class GroupParticipantsTile extends StatelessWidget {
  const GroupParticipantsTile({
    super.key,
    required this.dividerColor,
    required this.participant,
  });

  final Color dividerColor;
  final Participant participant;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: getProportionateScreenHeight(10)),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: dividerColor, width: 1.0)),
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
                image: participant.user.profileImage!.isEmpty
                    ? NetworkImage(defaultAvatar)
                    : NetworkImage(participant.user.profileImage!),
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
                  participant.user.fullName!,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: getProportionateScreenHeight(16),
                  ),
                ),
                SizedBox(height: getProportionateScreenHeight(4)),
                Text(
                  '@${participant.user.username}',
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
          Text(
            "Remove",
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w500,
              fontSize: getProportionateScreenHeight(13),
            ),
          ),
        ],
      ),
    );
  }
}

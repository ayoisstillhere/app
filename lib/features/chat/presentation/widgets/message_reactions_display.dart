import 'package:flutter/material.dart';
import 'package:app/features/auth/domain/entities/user_entity.dart';
import '../../../../size_config.dart';

class MessageReactionsDisplay extends StatelessWidget {
  final Map reactions;
  final UserEntity currentUser;
  final Function(String emoji) onReactionTap;
  final bool isDark;

  const MessageReactionsDisplay({
    super.key,
    required this.reactions,
    required this.currentUser,
    required this.onReactionTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (reactions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(
        top: getProportionateScreenHeight(4),
        bottom: getProportionateScreenHeight(2),
      ),
      child: Wrap(
        spacing: getProportionateScreenWidth(4),
        runSpacing: getProportionateScreenHeight(2),
        children: reactions.entries.map((entry) {
          final emoji = entry.key as String;
          final reactionList = entry.value as List;
          final userIds = reactionList
              .map((item) => item['userId'] as String)
              .toList();
          final count = userIds.length;
          final hasCurrentUserReacted = userIds.contains(currentUser.id);

          return GestureDetector(
            onTap: () => onReactionTap(emoji),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(8),
                vertical: getProportionateScreenHeight(4),
              ),
              decoration: BoxDecoration(
                color: hasCurrentUserReacted
                    ? (isDark
                          ? Colors.blue.withOpacity(0.3)
                          : Colors.blue.withOpacity(0.1))
                    : (isDark
                          ? Colors.grey.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(
                  getProportionateScreenWidth(12),
                ),
                border: hasCurrentUserReacted
                    ? Border.all(color: Colors.blue.withOpacity(0.5), width: 1)
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    emoji,
                    style: TextStyle(
                      fontSize: getProportionateScreenHeight(14),
                    ),
                  ),
                  if (count > 1) ...[
                    SizedBox(width: getProportionateScreenWidth(4)),
                    Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: getProportionateScreenHeight(12),
                        fontWeight: FontWeight.w500,
                        color: hasCurrentUserReacted
                            ? Colors.blue
                            : (isDark ? Colors.white70 : Colors.black54),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

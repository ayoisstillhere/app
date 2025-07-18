import 'package:flutter/material.dart';
import '../../../../size_config.dart';

class ReactionPicker extends StatelessWidget {
  final Function(String emoji) onReactionSelected;
  final VoidCallback onCancel;

  const ReactionPicker({
    super.key,
    required this.onReactionSelected,
    required this.onCancel,
  });

  static const List<String> _defaultEmojis = [
    '👍',
    '👎',
    '❤️',
    '😂',
    '😮',
    '😢',
    '🔥',
    '✨',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: getProportionateScreenWidth(12),
        vertical: getProportionateScreenHeight(8),
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(getProportionateScreenWidth(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ..._defaultEmojis.map(
            (emoji) => GestureDetector(
              onTap: () => onReactionSelected(emoji),
              child: Container(
                padding: EdgeInsets.all(getProportionateScreenWidth(6)),
                margin: EdgeInsets.symmetric(
                  horizontal: getProportionateScreenWidth(2),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    getProportionateScreenWidth(16),
                  ),
                ),
                child: Text(
                  emoji,
                  style: TextStyle(fontSize: getProportionateScreenHeight(18)),
                ),
              ),
            ),
          ),
          SizedBox(width: getProportionateScreenWidth(8)),
          GestureDetector(
            onTap: onCancel,
            child: Container(
              padding: EdgeInsets.all(getProportionateScreenWidth(4)),
              child: Icon(
                Icons.close,
                size: getProportionateScreenHeight(14),
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

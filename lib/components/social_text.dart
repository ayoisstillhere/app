import 'package:app/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class SocialText extends StatelessWidget {
  final String text;
  final TextStyle? baseStyle;
  final Function(String)? onMentionTap;
  final Function(String)? onHashtagTap;

  const SocialText({
    super.key,
    required this.text,
    this.baseStyle,
    this.onMentionTap,
    this.onHashtagTap,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(text: _buildTextSpan(context), textAlign: TextAlign.left);
  }

  TextSpan _buildTextSpan(BuildContext context) {
    final List<TextSpan> spans = [];
    final RegExp pattern = RegExp(r'(@\w+|#\w+)');
    final matches = pattern.allMatches(text);

    int lastIndex = 0;

    for (final match in matches) {
      // Add text before the match
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: text.substring(lastIndex, match.start),
            style: baseStyle ?? Theme.of(context).textTheme.bodyLarge,
          ),
        );
      }

      // Add the matched mention or hashtag
      final matchedText = match.group(0)!;
      final isMention = matchedText.startsWith('@');
      final isHashtag = matchedText.startsWith('#');

      spans.add(
        TextSpan(
          text: matchedText,
          style: (baseStyle ?? Theme.of(context).textTheme.bodyLarge)?.copyWith(
            color: kAccentColor,
            fontWeight: FontWeight.w600,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              if (isMention && onMentionTap != null) {
                onMentionTap!(matchedText.substring(1)); // Remove @ symbol
              } else if (isHashtag && onHashtagTap != null) {
                onHashtagTap!(matchedText.substring(1)); // Remove # symbol
              }
            },
        ),
      );

      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastIndex),
          style: baseStyle ?? Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return TextSpan(children: spans);
  }
}

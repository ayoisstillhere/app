import 'package:app/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialText extends StatelessWidget {
  final String text;
  final TextStyle? baseStyle;
  final Function(String)? onMentionTap;
  final Function(String)? onHashtagTap;
  final Function(String)? onLinkTap;

  const SocialText({
    super.key,
    required this.text,
    this.baseStyle,
    this.onMentionTap,
    this.onHashtagTap,
    this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(text: _buildTextSpan(context), textAlign: TextAlign.left);
  }

  TextSpan _buildTextSpan(BuildContext context) {
    final List<TextSpan> spans = [];

    // Enhanced pattern to match mentions, hashtags, and URLs
    final RegExp pattern = RegExp(
      r'(@\w+|#\w+|https?://[^\s]+|www\.[^\s]+|[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]*\.(?:com|org|net|edu|gov|mil|int|co|io|me|ly|tv|cc|de|uk|ca|au|jp|fr|it|es|nl|br|ru|cn|in|kr|mx|se|no|dk|fi|pl|be|ch|at|cz|gr|pt|hu|ro|bg|hr|sk|si|ee|lv|lt|lu|mt|cy|is|ad|sm|va|mc|li|gi|je|gg|im|fo|gl|sj|ax|pm|re|yt|gp|mq|gf|nc|pf|wf|tf|aq|bv|hm|gs|fk|sh|ta|ac|io|so|tk|to|nu|nf|cx|cc|ws|tv|fm|pw|mh|mp|gu|as|pr|vi|um|us|mil|gov|edu|org|net|com|info|biz|name|pro|museum|aero|coop|travel|jobs|mobi|tel|cat|post|xxx|asia|xxx|arpa|root|example|invalid|localhost|test|local|lan|internal|corp|home|localdomain|lan|dev|localhost|local|home|corp|domain|example|invalid|test|onion|exit|i2p|bit|lib|coin|bazar|cia|fbi|gov|mil|edu|com|org|net|int|aero|arpa|biz|cat|coop|info|jobs|mobi|museum|name|pro|travel|xxx|[a-z]{2})\b)',
      caseSensitive: false,
    );

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

      // Add the matched mention, hashtag, or link
      final matchedText = match.group(0)!;
      final isMention = matchedText.startsWith('@');
      final isHashtag = matchedText.startsWith('#');
      final isLink = _isUrl(matchedText);

      Color textColor;
      if (isLink) {
        textColor = kLightPurple; // Traditional link color
      } else {
        textColor = kAccentColor; // Your accent color for mentions/hashtags
      }

      spans.add(
        TextSpan(
          text: matchedText,
          style: (baseStyle ?? Theme.of(context).textTheme.bodyLarge)?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
            decoration: isLink ? TextDecoration.underline : null,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              if (isMention && onMentionTap != null) {
                onMentionTap!(matchedText.substring(1)); // Remove @ symbol
              } else if (isHashtag && onHashtagTap != null) {
                onHashtagTap!(matchedText.substring(1)); // Remove # symbol
              } else if (isLink) {
                _handleLinkTap(matchedText);
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

  bool _isUrl(String text) {
    return text.startsWith('http://') ||
        text.startsWith('https://') ||
        text.startsWith('www.') ||
        RegExp(
          r'^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]*\.[a-zA-Z]{2,}',
        ).hasMatch(text);
  }

  void _handleLinkTap(String url) {
    if (onLinkTap != null) {
      onLinkTap!(url);
    } else {
      // Default behavior: launch URL
      _launchUrl(url);
    }
  }

  void _launchUrl(String url) async {
    String formattedUrl = url;

    // Add protocol if missing
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      formattedUrl = 'https://$url';
    }

    final Uri uri = Uri.parse(formattedUrl);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Handle error - could show a snackbar or toast
        debugPrint('Could not launch $formattedUrl');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }
}

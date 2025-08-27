import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../constants.dart';
import '../../../../size_config.dart';
import '../pages/post_details_screen.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.iconColor,
    this.username,
    required this.action,
    required this.time,
    this.image,
    required this.isClickable,
    this.buttonText,
    this.postId,
    required this.currentUser,
  });

  final Color iconColor;
  final String? username;
  final String action;
  final DateTime time;
  final String? image;
  final bool isClickable;
  final String? buttonText;
  final String? postId;
  final UserEntity currentUser;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: getProportionateScreenHeight(25),
          width: getProportionateScreenWidth(25),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: image == null || image!.isEmpty
                  ? NetworkImage(defaultAvatar)
                  : NetworkImage(image!),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(width: getProportionateScreenWidth(10)),
        // username == null
        //     ? const Spacer()
        //     : Text(
        //         username!,
        //         style: TextStyle(
        //           fontWeight: FontWeight.w500,
        //           fontSize: getProportionateScreenWidth(13),
        //         ),
        //       ),
        SizedBox(width: getProportionateScreenWidth(2)),
        SizedBox(
          width: getProportionateScreenWidth(230),
          child: RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(children: _buildTextSpans(action)),
          ),
        ),
        SizedBox(width: getProportionateScreenWidth(6)),
        Text(
          ".",
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: getProportionateScreenWidth(13),
            color: kGreyHandleText,
          ),
        ),
        Text(
          _formatTime(time),
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: getProportionateScreenWidth(12),
            color: kGreyTimeText,
          ),
        ),
        Spacer(),
        isClickable
            ? InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostDetailsScreen(
                        postId: postId!,
                        currentUser: currentUser,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: getProportionateScreenWidth(10),
                    vertical: getProportionateScreenHeight(10),
                  ),
                  decoration: BoxDecoration(
                    color: kAccentColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      buttonText!,
                      style: TextStyle(
                        fontSize: 12,
                        color: kBlack,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              )
            : InkWell(
                onTap: () {},
                child: SvgPicture.asset(
                  "assets/icons/more-vertical.svg",
                  height: getProportionateScreenHeight(17),
                  width: getProportionateScreenWidth(17),
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                ),
              ),
      ],
    );
  }
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

// Helper method to build text spans with handle styling
List<TextSpan> _buildTextSpans(String text) {
  final List<TextSpan> spans = [];
  final RegExp handleRegex = RegExp(r'@\w+');

  int start = 0;

  for (final Match match in handleRegex.allMatches(text)) {
    // Add text before the handle
    if (match.start > start) {
      spans.add(
        TextSpan(
          text: text.substring(start, match.start),
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: getProportionateScreenWidth(13),
            color: kGreyHandleText,
          ),
        ),
      );
    }

    // Add the handle with special styling
    spans.add(
      TextSpan(
        text: match.group(0),
        // style: TextStyle(
        //   fontWeight: FontWeight.w500,
        //   fontSize: getProportionateScreenWidth(13),
        //   // You can add color here if needed, e.g., color: Colors.blue,
        // ),
      ),
    );

    start = match.end;
  }

  // Add remaining text after the last handle
  if (start < text.length) {
    spans.add(
      TextSpan(
        text: text.substring(start),
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: getProportionateScreenWidth(13),
          color: kGreyHandleText,
        ),
      ),
    );
  }

  // If no handles were found, return the original text with normal styling
  if (spans.isEmpty) {
    spans.add(
      TextSpan(
        text: text,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: getProportionateScreenWidth(13),
          color: kGreyHandleText,
        ),
      ),
    );
  }

  return spans;
}

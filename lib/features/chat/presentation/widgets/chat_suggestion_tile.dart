import 'package:flutter/material.dart';

import '../../../../size_config.dart';

class ChatSuggestionTile extends StatelessWidget {
  const ChatSuggestionTile({
    super.key,
    required this.dividerColor,
    required this.image,
    required this.name,
    required this.handle,
  });

  final Color dividerColor;
  final String image;
  final String name;
  final String handle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: getProportionateScreenHeight(10),
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: dividerColor, width: 1.0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            height: getProportionateScreenHeight(56),
            width: getProportionateScreenWidth(56),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(image),
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
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: getProportionateScreenHeight(16),
                  ),
                ),
                Spacer(),
                Row(
                  children: [
                    SizedBox(
                      width: getProportionateScreenWidth(228),
                      child: Text(
                        handle,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: getProportionateScreenHeight(12),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:app/features/chat/presentation/pages/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../constants.dart';
import '../../../../size_config.dart';

class ChatTile extends StatelessWidget {
  const ChatTile({
    super.key,
    required this.dividerColor,
    required this.image,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unreadMessages,
  });

  final Color dividerColor;
  final String image;
  final String name;
  final String lastMessage;
  final DateTime time;
  final int unreadMessages;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatScreen()),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: getProportionateScreenHeight(10),
        ),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: dividerColor, width: 1.0)),
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
                      SizedBox(
                        width: getProportionateScreenWidth(245),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: getProportionateScreenWidth(140),
                              child: Text(
                                lastMessage,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: getProportionateScreenHeight(12),
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            Text(
                              timeago.format(time),
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
            unreadMessages > 0
                ? Container(
                    height: getProportionateScreenHeight(25),
                    width: getProportionateScreenWidth(25),
                    decoration: BoxDecoration(
                      color: kAccentColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$unreadMessages',
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
}

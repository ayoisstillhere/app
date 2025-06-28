import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../constants.dart';
import '../../../../size_config.dart';
import 'social_text.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.dividerColor,
    required this.iconColor,
    required this.authorName,
    required this.authorHandle,
    required this.imageUrl,
    required this.postTime,
    required this.likes,
    required this.comments,
    required this.reposts,
    required this.bookmarks,
    required this.content,
  });

  final Color dividerColor;
  final Color iconColor;
  final String authorName;
  final String authorHandle;
  final String imageUrl;
  final String postTime;
  final int likes;
  final int comments;
  final int reposts;
  final int bookmarks;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: getProportionateScreenWidth(18),
        vertical: getProportionateScreenHeight(10),
      ),
      margin: EdgeInsets.only(top: getProportionateScreenHeight(6)),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: dividerColor, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () {},
                child: Container(
                  height: getProportionateScreenHeight(25),
                  width: getProportionateScreenWidth(25),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(width: getProportionateScreenWidth(10)),
              Text(
                authorName,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: getProportionateScreenHeight(13),
                ),
              ),
              SizedBox(width: getProportionateScreenWidth(2)),
              Text(
                '@$authorHandle',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.normal,
                  fontSize: getProportionateScreenHeight(13),
                  color: kGreyHandleText,
                ),
              ),
              SizedBox(width: getProportionateScreenWidth(2)),
              Text(
                '.',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.normal,
                  fontSize: getProportionateScreenHeight(13),
                  color: kGreyHandleText,
                ),
              ),
              SizedBox(width: getProportionateScreenWidth(2)),
              Text(
                postTime,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: getProportionateScreenHeight(12),
                  color: kGreyTimeText,
                ),
              ),
              Spacer(),
              InkWell(
                onTap: () {},
                child: SvgPicture.asset(
                  "assets/icons/more-vertical.svg",
                  height: getProportionateScreenHeight(17),
                  width: getProportionateScreenWidth(17),
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                ),
              ),
            ],
          ),
          SizedBox(height: getProportionateScreenHeight(5)),
          Padding(
            padding: EdgeInsets.only(
              left: getProportionateScreenWidth(37),
              right: getProportionateScreenWidth(10),
            ),
            child: PostText(
              text: content,
              baseStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontSize: getProportionateScreenHeight(15),
              ),
              onHashtagTap: (p0) {},
              onMentionTap: (p0) {},
            ),
          ),
          SizedBox(height: getProportionateScreenHeight(36)),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: getProportionateScreenWidth(37),
              vertical: getProportionateScreenHeight(5),
            ),
            child: Row(
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () {},
                      child: SvgPicture.asset(
                        "assets/icons/heart.svg",
                        height: getProportionateScreenHeight(15.55),
                        width: getProportionateScreenWidth(15.55),
                        colorFilter: ColorFilter.mode(
                          iconColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    SizedBox(width: getProportionateScreenWidth(5)),
                    Text('$likes'),
                  ],
                ),
                Spacer(),
                Row(
                  children: [
                    InkWell(
                      onTap: () {},
                      child: SvgPicture.asset(
                        "assets/icons/chats.svg",
                        height: getProportionateScreenHeight(15.55),
                        width: getProportionateScreenWidth(15.55),
                        colorFilter: ColorFilter.mode(
                          iconColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    SizedBox(width: getProportionateScreenWidth(5)),
                    Text('$comments'),
                  ],
                ),
                Spacer(),
                Row(
                  children: [
                    InkWell(
                      onTap: () {},
                      child: SvgPicture.asset(
                        "assets/icons/repost.svg",
                        height: getProportionateScreenHeight(15.55),
                        width: getProportionateScreenWidth(15.55),
                        colorFilter: ColorFilter.mode(
                          iconColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    SizedBox(width: getProportionateScreenWidth(5)),
                    Text('$reposts'),
                  ],
                ),
                Spacer(),
                Row(
                  children: [
                    InkWell(
                      onTap: () {},
                      child: SvgPicture.asset(
                        "assets/icons/bookmark.svg",
                        height: getProportionateScreenHeight(15.55),
                        width: getProportionateScreenWidth(15.55),
                        colorFilter: ColorFilter.mode(
                          iconColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    SizedBox(width: getProportionateScreenWidth(5)),
                    Text('$bookmarks'),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: getProportionateScreenHeight(10)),
        ],
      ),
    );
  }
}

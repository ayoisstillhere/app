import 'package:app/components/social_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../constants.dart';
import '../../../../size_config.dart';

class ReplyCard extends StatefulWidget {
  const ReplyCard({
    super.key,
    required this.dividerColor,
    required this.iconColor,
    required this.replyerName,
    required this.replyerHandle,
    required this.imageUrl,
    required this.postTime,
    required this.likes,
    required this.comments,
    required this.reposts,
    required this.bookmarks,
    required this.content,
    this.pictures = const [],
    required this.authorHandle,
  });

  final Color dividerColor;
  final Color iconColor;
  final String replyerName;
  final String replyerHandle;
  final String imageUrl;
  final DateTime postTime;
  final int likes;
  final int comments;
  final int reposts;
  final int bookmarks;
  final String content;
  final List<dynamic> pictures;
  final String authorHandle;

  @override
  State<ReplyCard> createState() => _ReplyCardState();
}

class _ReplyCardState extends State<ReplyCard> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
        border: Border(
          bottom: BorderSide(color: widget.dividerColor, width: 1),
        ),
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
                      image: NetworkImage(widget.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(width: getProportionateScreenWidth(10)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.replyerName,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: getProportionateScreenHeight(13),
                        ),
                      ),
                      SizedBox(width: getProportionateScreenWidth(2)),
                      Text(
                        '@${widget.replyerHandle}',
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
                        timeago.format(widget.postTime),
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: getProportionateScreenHeight(12),
                          color: kGreyTimeText,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: getProportionateScreenHeight(2)),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'replying to ',
                          style: Theme.of(context).textTheme.bodySmall!
                              .copyWith(fontWeight: FontWeight.w500),
                        ),
                        TextSpan(
                          text: '@${widget.authorHandle}',
                          style: Theme.of(context).textTheme.bodySmall!
                              .copyWith(
                                fontWeight: FontWeight.w500,
                                color: kAccentColor,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Spacer(),
              InkWell(
                onTap: () {},
                child: SvgPicture.asset(
                  "assets/icons/more-vertical.svg",
                  height: getProportionateScreenHeight(17),
                  width: getProportionateScreenWidth(17),
                  colorFilter: ColorFilter.mode(
                    widget.iconColor,
                    BlendMode.srcIn,
                  ),
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
            child: SocialText(
              text: widget.content,
              baseStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontSize: getProportionateScreenHeight(15),
              ),
              onHashtagTap: (p0) {},
              onMentionTap: (p0) {},
            ),
          ),
          widget.pictures.isEmpty
              ? Container()
              : SizedBox(height: getProportionateScreenHeight(10)),
          widget.pictures.isEmpty
              ? Container()
              : widget.pictures.length == 1
              ? Padding(
                  padding: EdgeInsets.only(
                    left: getProportionateScreenWidth(37),
                    right: getProportionateScreenWidth(10),
                  ),
                  child: Container(
                    width: double.infinity,
                    height: getProportionateScreenHeight(193),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        getProportionateScreenWidth(10),
                      ),
                      image: DecorationImage(
                        image: NetworkImage(widget.pictures[0]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                )
              : Column(
                  children: [
                    Container(
                      height: getProportionateScreenHeight(193),
                      margin: EdgeInsets.only(
                        left: getProportionateScreenWidth(37),
                        right: getProportionateScreenWidth(10),
                      ),
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (int page) {
                          setState(() {
                            _currentPage = page;
                          });
                        },
                        itemCount: widget.pictures.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.only(
                              right: getProportionateScreenWidth(5),
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                getProportionateScreenWidth(10),
                              ),
                              image: DecorationImage(
                                image: NetworkImage(widget.pictures[index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: getProportionateScreenHeight(12)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.pictures.length,
                        (index) => AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          margin: EdgeInsets.symmetric(
                            horizontal: getProportionateScreenWidth(2),
                          ),
                          height: getProportionateScreenHeight(6),
                          width: getProportionateScreenWidth(6),
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? kLightPurple
                                : kLightPurple.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(
                              getProportionateScreenWidth(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
          SizedBox(height: getProportionateScreenHeight(24)),
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
                          widget.iconColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    SizedBox(width: getProportionateScreenWidth(5)),
                    Text('${widget.likes}'),
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
                          widget.iconColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    SizedBox(width: getProportionateScreenWidth(5)),
                    Text('${widget.comments}'),
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
                          widget.iconColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    SizedBox(width: getProportionateScreenWidth(5)),
                    Text('${widget.reposts}'),
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
                          widget.iconColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    SizedBox(width: getProportionateScreenWidth(5)),
                    Text('${widget.bookmarks}'),
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

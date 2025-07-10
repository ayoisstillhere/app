import 'package:app/features/home/presentation/pages/post_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:timeago/timeago.dart' as timeago;

import 'package:app/components/social_text.dart';
import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:app/features/profile/presentation/pages/profile_screen.dart';

import '../../../../constants.dart';
import '../../../../services/auth_manager.dart';
import '../../../../size_config.dart';
import '../pages/write_comment_screen.dart';

class PostCard extends StatefulWidget {
  PostCard({
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
    this.pictures = const [],
    this.forSearch = false,
    required this.currentUser,
    required this.postId,
    this.notClickable = false,
    required this.isLiked,
    required this.isReposted,
    required this.isSaved,
    this.onCommentAdded,
    // New parameters for reply functionality
    this.isReply = false,
    this.replyingToHandle,
  });

  final Color dividerColor;
  final Color iconColor;
  final String authorName;
  final String authorHandle;
  final String imageUrl;
  final DateTime postTime;
  int likes;
  final int comments;
  int reposts;
  int bookmarks;
  final String content;
  final List<dynamic> pictures;
  final bool forSearch;
  final UserEntity currentUser;
  final String postId;
  final bool notClickable;
  bool isLiked;
  bool isReposted;
  bool isSaved;
  final VoidCallback? onCommentAdded;
  // New properties for reply functionality
  final bool isReply;
  final String? replyingToHandle;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late PageController _pageController;
  int _currentPage = 0;

  void _onLike() async {
    final token = await AuthManager.getToken();
    final wasLiked = widget.isLiked;

    setState(() {
      if (wasLiked) {
        widget.likes--;
      } else {
        widget.likes++;
      }
      widget.isLiked = !widget.isLiked;
    });

    if (wasLiked) {
      await http.delete(
        Uri.parse("$baseUrl/api/v1/posts/${widget.postId}/like"),
        headers: {"Authorization": "Bearer $token"},
      );
    } else {
      await http.post(
        Uri.parse("$baseUrl/api/v1/posts/${widget.postId}/like"),
        headers: {"Authorization": "Bearer $token"},
      );
    }
  }

  void _onRepost() async {
    final token = await AuthManager.getToken();
    final wasReposted = widget.isReposted;

    setState(() {
      if (wasReposted) {
        widget.reposts--;
      } else {
        widget.reposts++;
      }
      widget.isReposted = !widget.isReposted;
    });

    if (wasReposted) {
      await http.delete(
        Uri.parse("$baseUrl/api/v1/posts/${widget.postId}/repost"),
        headers: {"Authorization": "Bearer $token"},
      );
    } else {
      await http.post(
        Uri.parse("$baseUrl/api/v1/posts/${widget.postId}/repost"),
        headers: {"Authorization": "Bearer $token"},
      );
    }
  }

  void _onSave() async {
    final token = await AuthManager.getToken();
    final wasSaved = widget.isSaved;

    setState(() {
      if (wasSaved) {
        widget.bookmarks--;
      } else {
        widget.bookmarks++;
      }
      widget.isSaved = !widget.isSaved;
    });

    if (wasSaved) {
      await http.delete(
        Uri.parse("$baseUrl/api/v1/posts/${widget.postId}/save"),
        headers: {"Authorization": "Bearer $token"},
      );
    } else {
      await http.post(
        Uri.parse("$baseUrl/api/v1/posts/${widget.postId}/save"),
        headers: {"Authorization": "Bearer $token"},
      );
    }
  }

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
    return InkWell(
      onTap: () {
        if (widget.notClickable) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return PostDetailsScreen(
                postId: widget.postId,
                currentUser: widget.currentUser,
              );
            },
          ),
        );
      },
      child: Container(
        width: widget.forSearch
            ? getProportionateScreenWidth(391)
            : double.infinity,
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(
                          isVerified: true,
                          userName: widget.authorHandle,
                          currentUser: widget.currentUser,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: getProportionateScreenHeight(25),
                    width: getProportionateScreenWidth(25),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: widget.imageUrl.isEmpty
                            ? NetworkImage(defaultAvatar)
                            : NetworkImage(widget.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: getProportionateScreenWidth(10)),
                // Modified section to handle both regular posts and replies
                widget.isReply
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                widget.authorName,
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: getProportionateScreenHeight(
                                        13,
                                      ),
                                    ),
                              ),
                              SizedBox(width: getProportionateScreenWidth(2)),
                              Text(
                                '@${widget.authorHandle}',
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .copyWith(
                                      fontWeight: FontWeight.normal,
                                      fontSize: getProportionateScreenHeight(
                                        13,
                                      ),
                                      color: kGreyHandleText,
                                    ),
                              ),
                              SizedBox(width: getProportionateScreenWidth(2)),
                              Text(
                                '.',
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .copyWith(
                                      fontWeight: FontWeight.normal,
                                      fontSize: getProportionateScreenHeight(
                                        13,
                                      ),
                                      color: kGreyHandleText,
                                    ),
                              ),
                              SizedBox(width: getProportionateScreenWidth(2)),
                              Text(
                                timeago.format(widget.postTime),
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: getProportionateScreenHeight(
                                        12,
                                      ),
                                      color: kGreyTimeText,
                                    ),
                              ),
                            ],
                          ),
                          SizedBox(height: getProportionateScreenHeight(2)),
                          if (widget.replyingToHandle != null)
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'replying to ',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(fontWeight: FontWeight.w500),
                                  ),
                                  TextSpan(
                                    text: '@${widget.replyingToHandle}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: kAccentColor,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      )
                    : Row(
                        children: [
                          Text(
                            widget.authorName,
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: getProportionateScreenHeight(13),
                                ),
                          ),
                          SizedBox(width: getProportionateScreenWidth(2)),
                          Text(
                            '@${widget.authorHandle}',
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  fontWeight: FontWeight.normal,
                                  fontSize: getProportionateScreenHeight(13),
                                  color: kGreyHandleText,
                                ),
                          ),
                          SizedBox(width: getProportionateScreenWidth(2)),
                          Text(
                            '.',
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  fontWeight: FontWeight.normal,
                                  fontSize: getProportionateScreenHeight(13),
                                  color: kGreyHandleText,
                                ),
                          ),
                          SizedBox(width: getProportionateScreenWidth(2)),
                          Text(
                            timeago.format(widget.postTime),
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: getProportionateScreenHeight(12),
                                  color: kGreyTimeText,
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
                          image: widget.pictures[0].isEmpty
                              ? NetworkImage(defaultAvatar)
                              : NetworkImage(widget.pictures[0]),
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
                                  image: widget.pictures[index].isEmpty
                                      ? NetworkImage(defaultAvatar)
                                      : NetworkImage(widget.pictures[index]),
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
                  SizedBox(
                    width: getProportionateScreenWidth(36.55),
                    child: Row(
                      children: [
                        widget.isLiked
                            ? InkWell(
                                onTap: _onLike,
                                child: SvgPicture.asset(
                                  "assets/icons/heart_red.svg",
                                  height: getProportionateScreenHeight(20),
                                  width: getProportionateScreenWidth(20),
                                ),
                              )
                            : InkWell(
                                onTap: _onLike,
                                child: SvgPicture.asset(
                                  "assets/icons/heart.svg",
                                  height: getProportionateScreenHeight(20),
                                  width: getProportionateScreenWidth(20),
                                  colorFilter: ColorFilter.mode(
                                    widget.iconColor,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                        Spacer(),
                        Text('${widget.likes}'),
                      ],
                    ),
                  ),
                  Spacer(),
                  SizedBox(
                    width: getProportionateScreenWidth(36.55),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () async {
                            // Navigate to WriteCommentScreen
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WriteCommentScreen(
                                  currentUser: widget.currentUser,
                                  postId: widget.postId,
                                  authorProfileImage: widget.imageUrl,
                                  authorName: widget.authorName,
                                  media: [],
                                  content: widget.content,
                                  createdAt:
                                      widget.postTime, // Pass the current user
                                ),
                              ),
                            );

                            // If comment was posted successfully, you might want to refresh the post
                            if (result == true) {
                              // Optionally refresh the post data or increment comment count
                              // You can call a callback function here to update the parent widget
                              if (widget.onCommentAdded != null) {
                                widget.onCommentAdded!();
                              }
                            }
                          },
                          child: SvgPicture.asset(
                            "assets/icons/chats.svg",
                            height: getProportionateScreenHeight(20),
                            width: getProportionateScreenWidth(20),
                            colorFilter: ColorFilter.mode(
                              widget.iconColor,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        Spacer(),
                        Text('${widget.comments}'),
                      ],
                    ),
                  ),
                  Spacer(),
                  SizedBox(
                    width: getProportionateScreenWidth(36.55),
                    child: Row(
                      children: [
                        widget.isReposted
                            ? InkWell(
                                onTap: _onRepost,
                                child: SvgPicture.asset(
                                  "assets/icons/repeat_green.svg",
                                  height: getProportionateScreenHeight(20),
                                  width: getProportionateScreenWidth(20),
                                ),
                              )
                            : InkWell(
                                onTap: _onRepost,
                                child: SvgPicture.asset(
                                  "assets/icons/repost.svg",
                                  height: getProportionateScreenHeight(20),
                                  width: getProportionateScreenWidth(20),
                                  colorFilter: ColorFilter.mode(
                                    widget.iconColor,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                        Spacer(),
                        Text('${widget.reposts}'),
                      ],
                    ),
                  ),
                  Spacer(),
                  SizedBox(
                    width: getProportionateScreenWidth(36.55),
                    child: Row(
                      children: [
                        widget.isSaved
                            ? InkWell(
                                onTap: _onSave,
                                child: Icon(
                                  Icons.bookmark,
                                  size: getProportionateScreenHeight(20),
                                  color: kLightPurple,
                                ),
                              )
                            : InkWell(
                                onTap: _onSave,
                                child: SvgPicture.asset(
                                  "assets/icons/bookmark.svg",
                                  height: getProportionateScreenHeight(20),
                                  width: getProportionateScreenWidth(20),
                                  colorFilter: ColorFilter.mode(
                                    widget.iconColor,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                        Spacer(),
                        Text('${widget.bookmarks}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: getProportionateScreenHeight(10)),
          ],
        ),
      ),
    );
  }
}

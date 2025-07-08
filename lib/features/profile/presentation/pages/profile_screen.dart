import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:app/components/social_text.dart';
import 'package:app/features/auth/data/models/user_model.dart';
import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:app/features/home/domain/entities/post_response_entity.dart';
import 'package:app/features/profile/presentation/pages/settings_screen.dart';
import 'package:app/size_config.dart';

import '../../../../constants.dart';
import '../../../../services/auth_manager.dart';
import '../../../home/data/models/post_response_model.dart';
import '../../../home/presentation/widgets/post_Card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.isVerified,
    this.isFromNav = false,
    required this.userName,
    required this.currentUser,
  });
  final bool isVerified;
  final bool isFromNav;
  final String userName;
  final UserEntity currentUser;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController controller;
  bool canMessage = false;

  UserEntity? user;
  PostResponseEntity? posts;
  PostResponseEntity? reposts;
  PostResponseEntity? comments;
  PostResponseEntity? savedPosts;
  PostResponseEntity? likedPosts;
  PostResponseEntity? mediaPosts;

  bool isPostsLoaded = false;
  bool isRepostsLoaded = false;
  bool isCommentsLoaded = false;
  bool isSavedPostsLoaded = false;
  bool isLikedPostsLoaded = false;
  bool isUserLoaded = false;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 6, vsync: this);
    if (mounted) {
      _fetchUser();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _getPosts() async {
    final token = await AuthManager.getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/api/v1/posts/user/${user!.id}/posts"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200) {
      posts = PostResponseModel.fromJson(jsonDecode(response.body));
      if (mounted) {
        setState(() {
          mediaPosts = PostResponseEntity(
            posts!.posts.where((element) => element.media.isNotEmpty).toList(),
            posts!.pagination,
            posts!.user,
          );
          isPostsLoaded = true;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            jsonDecode(
              response.body,
            )['message'].toString().replaceAll(RegExp(r'\[|\]'), ''),
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  Future<void> _getReposts() async {
    final token = await AuthManager.getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/api/v1/posts/user/${user!.id}/reposts"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200) {
      reposts = PostResponseModel.fromJson(jsonDecode(response.body));
      if (mounted) {
        setState(() {
          isRepostsLoaded = true;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            jsonDecode(
              response.body,
            )['message'].toString().replaceAll(RegExp(r'\[|\]'), ''),
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  Future<void> _getComments() async {
    final token = await AuthManager.getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/api/v1/posts/user/${user!.id}/comments"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200) {
      comments = PostResponseModel.fromJson(jsonDecode(response.body));
      if (mounted) {
        setState(() {
          isCommentsLoaded = true;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            jsonDecode(
              response.body,
            )['message'].toString().replaceAll(RegExp(r'\[|\]'), ''),
          ),
        ),
      );
    }
  }

  Future<void> _getSavedPosts() async {
    final token = await AuthManager.getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/api/v1/posts/user/${user!.id}/saves"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200) {
      savedPosts = PostResponseModel.fromJson(jsonDecode(response.body));
      if (mounted) {
        setState(() {
          isSavedPostsLoaded = true;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            jsonDecode(
              response.body,
            )['message'].toString().replaceAll(RegExp(r'\[|\]'), ''),
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  Future<void> _getLikedPosts() async {
    final token = await AuthManager.getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/api/v1/posts/user/${user!.id}/likes"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200) {
      likedPosts = PostResponseModel.fromJson(jsonDecode(response.body));
      if (mounted) {
        setState(() {
          isLikedPostsLoaded = true;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            jsonDecode(
              response.body,
            )['message'].toString().replaceAll(RegExp(r'\[|\]'), ''),
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  Future<void> _fetchUser() async {
    final token = await AuthManager.getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/api/v1/user/profile/${widget.userName}"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          user = UserModel.fromJson(jsonDecode(response.body));
        });
        _getPosts();
        _getReposts();
        _getComments();
        _getSavedPosts();
        _getLikedPosts();
        setState(() {
          isUserLoaded = true;
          if (!user!.isOwnProfile && (user!.isFollowing || user!.followsYou)) {
            setState(() {
              canMessage = true;
            });
          }
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            jsonDecode(
              response.body,
            )['message'].toString().replaceAll(RegExp(r'\[|\]'), ''),
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kWhite
        : kBlack;
    final dividerColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kGreyInputFillDark
        : kGreyInputBorder;

    return Scaffold(
      body: isUserLoaded
          ? SafeArea(
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          _buildHeader(iconColor),
                          SizedBox(height: getProportionateScreenHeight(8)),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: getProportionateScreenWidth(24),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  height: getProportionateScreenHeight(68),
                                  width: getProportionateScreenWidth(68),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: NetworkImage(user!.profileImage),
                                      fit: BoxFit.cover,
                                    ),
                                    border: Border.all(
                                      width: 1,
                                      color: kPrimPurple,
                                    ),
                                  ),
                                ),
                                SizedBox(width: getProportionateScreenWidth(6)),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          user!.fullName,
                                          style: TextStyle(
                                            fontSize:
                                                getProportionateScreenHeight(
                                                  16,
                                                ),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (widget.isVerified)
                                          SvgPicture.asset(
                                            "assets/icons/verified.svg",
                                            height:
                                                getProportionateScreenHeight(
                                                  19.14,
                                                ),
                                            width: getProportionateScreenWidth(
                                              19.14,
                                            ),
                                          ),
                                      ],
                                    ),
                                    Text(
                                      "@${user!.username}",
                                      style: TextStyle(
                                        fontSize: getProportionateScreenHeight(
                                          13,
                                        ),
                                        color: kProfileText,
                                      ),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      NumberFormat.compact().format(
                                        user!.followerCount,
                                      ),
                                      style: TextStyle(
                                        fontSize: getProportionateScreenHeight(
                                          16,
                                        ),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      "Followers",
                                      style: TextStyle(
                                        fontSize: getProportionateScreenHeight(
                                          12,
                                        ),
                                        fontWeight: FontWeight.w500,
                                        color: kProfileText,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: getProportionateScreenWidth(10),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      NumberFormat.compact().format(
                                        user!.followingCount,
                                      ),
                                      style: TextStyle(
                                        fontSize: getProportionateScreenHeight(
                                          16,
                                        ),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      "Following",
                                      style: TextStyle(
                                        fontSize: getProportionateScreenHeight(
                                          12,
                                        ),
                                        fontWeight: FontWeight.w500,
                                        color: kProfileText,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: getProportionateScreenHeight(18)),
                          Padding(
                            padding: EdgeInsets.only(
                              left: getProportionateScreenWidth(30),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      "assets/icons/map-pin.svg",
                                      height: getProportionateScreenHeight(18),
                                      width: getProportionateScreenWidth(18),
                                    ),
                                    SizedBox(
                                      width: getProportionateScreenWidth(10),
                                    ),
                                    Text(
                                      user!.location,
                                      style: TextStyle(
                                        fontSize: getProportionateScreenHeight(
                                          12,
                                        ),
                                        fontWeight: FontWeight.w500,
                                        color: kProfileText,
                                      ),
                                    ),
                                    SizedBox(
                                      width: getProportionateScreenWidth(35),
                                    ),
                                    SvgPicture.asset(
                                      "assets/icons/calendar.svg",
                                      height: getProportionateScreenHeight(18),
                                      width: getProportionateScreenWidth(18),
                                    ),
                                    SizedBox(
                                      width: getProportionateScreenWidth(10),
                                    ),
                                    Text(
                                      'Since ${DateFormat('MMMM yyyy').format(user!.dateJoined)}',
                                      style: TextStyle(
                                        fontSize: getProportionateScreenHeight(
                                          12,
                                        ),
                                        fontWeight: FontWeight.w500,
                                        color: kProfileText,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: getProportionateScreenHeight(9),
                                ),
                                SocialText(
                                  text: user!.bio,
                                  baseStyle: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                        fontSize: getProportionateScreenHeight(
                                          12,
                                        ),
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: getProportionateScreenHeight(18)),
                          Padding(
                            padding: canMessage
                                ? EdgeInsets.symmetric(
                                    horizontal: getProportionateScreenWidth(20),
                                  )
                                : EdgeInsets.symmetric(
                                    horizontal: getProportionateScreenWidth(30),
                                  ),
                            child: Row(
                              children: [
                                if (user!.isOwnProfile)
                                  InkWell(
                                    onTap: () {},
                                    child: Container(
                                      height: getProportionateScreenHeight(27),
                                      width: canMessage
                                          ? getProportionateScreenWidth(158.5)
                                          : getProportionateScreenWidth(163.5),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 1,
                                          color: kProfileText,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          getProportionateScreenWidth(10),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text("Edit Profile"),
                                      ),
                                    ),
                                  ),
                                if (!user!.isOwnProfile &&
                                    !user!.isFollowing &&
                                    !user!.followsYou)
                                  InkWell(
                                    onTap: () async {
                                      await _followUser();
                                    },
                                    child: Container(
                                      height: getProportionateScreenHeight(27),
                                      width: canMessage
                                          ? getProportionateScreenWidth(158.5)
                                          : getProportionateScreenWidth(163.5),
                                      decoration: BoxDecoration(
                                        color: kAccentColor,
                                        borderRadius: BorderRadius.circular(
                                          getProportionateScreenWidth(10),
                                        ),
                                      ),
                                      child: Center(child: Text("Follow")),
                                    ),
                                  ),
                                if (!user!.isOwnProfile && user!.isFollowing)
                                  InkWell(
                                    onTap: () async {
                                      await _unfollowUser();
                                    },
                                    child: Container(
                                      height: getProportionateScreenHeight(27),
                                      width: canMessage
                                          ? getProportionateScreenWidth(158.5)
                                          : getProportionateScreenWidth(163.5),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 1,
                                          color: kProfileText,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          getProportionateScreenWidth(10),
                                        ),
                                      ),
                                      child: Center(child: Text("Unfollow")),
                                    ),
                                  ),
                                if (!user!.isOwnProfile &&
                                    user!.followsYou &&
                                    !user!.isFollowing)
                                  InkWell(
                                    onTap: () async {
                                      await _followUser();
                                    },
                                    child: Container(
                                      height: getProportionateScreenHeight(27),
                                      width: canMessage
                                          ? getProportionateScreenWidth(158.5)
                                          : getProportionateScreenWidth(163.5),
                                      decoration: BoxDecoration(
                                        color: kAccentColor,
                                        borderRadius: BorderRadius.circular(
                                          getProportionateScreenWidth(10),
                                        ),
                                      ),
                                      child: Center(child: Text("Follow Back")),
                                    ),
                                  ),
                                Spacer(),
                                InkWell(
                                  onTap: () {},
                                  child: Container(
                                    height: getProportionateScreenHeight(27),
                                    width: canMessage
                                        ? getProportionateScreenWidth(158.5)
                                        : getProportionateScreenWidth(163.5),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1,
                                        color: kProfileText,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        getProportionateScreenWidth(10),
                                      ),
                                    ),
                                    child: Center(child: Text("Share Profile")),
                                  ),
                                ),
                                if (!user!.isOwnProfile &&
                                    (user!.isFollowing || user!.followsYou))
                                  Spacer(),
                                if (canMessage)
                                  InkWell(
                                    onTap: () {},
                                    child: SvgPicture.asset(
                                      "assets/icons/mail.svg",
                                      height: getProportionateScreenHeight(24),
                                      width: getProportionateScreenWidth(24),
                                      colorFilter: ColorFilter.mode(
                                        kProfileText,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(height: getProportionateScreenHeight(18)),
                        ],
                      ),
                    ),
                    SliverPersistentHeader(
                      delegate: _SliverAppBarDelegate(
                        TabBar(
                          controller: controller,
                          tabAlignment: TabAlignment.start,
                          isScrollable: true,
                          indicatorColor: kLightPurple,
                          dividerColor: dividerColor,
                          labelStyle: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(fontWeight: FontWeight.w500),
                          unselectedLabelStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(fontWeight: FontWeight.w500),
                          tabs: [
                            Tab(
                              child: SizedBox(
                                width: getProportionateScreenWidth(70),
                                child: Center(child: Text("Posts")),
                              ),
                            ),
                            Tab(
                              child: SizedBox(
                                width: getProportionateScreenWidth(70),
                                child: Center(child: Text("Reposts")),
                              ),
                            ),
                            Tab(
                              child: SizedBox(
                                width: getProportionateScreenWidth(70),
                                child: Center(child: Text("Media")),
                              ),
                            ),
                            Tab(
                              child: SizedBox(
                                width: getProportionateScreenWidth(70),
                                child: Center(child: Text("Comments")),
                              ),
                            ),
                            Tab(
                              child: SizedBox(
                                width: getProportionateScreenWidth(70),
                                child: Center(child: Text("Saved")),
                              ),
                            ),
                            Tab(
                              child: SizedBox(
                                width: getProportionateScreenWidth(70),
                                child: Center(child: Text("Liked")),
                              ),
                            ),
                          ],
                          indicatorSize: TabBarIndicatorSize.label,
                        ),
                      ),
                      pinned: true,
                    ),
                  ];
                },
                body: TabBarView(
                  controller: controller,
                  children: [
                    isPostsLoaded
                        ? ListView.builder(
                            itemCount: posts!.posts.length,
                            itemBuilder: (context, index) {
                              final post = posts!.posts[index];
                              return GestureDetector(
                                onTap: () {},
                                child: PostCard(
                                  dividerColor: dividerColor,
                                  iconColor: iconColor,
                                  authorName: post.author.fullName,
                                  authorHandle: post.author.username,
                                  imageUrl: post.author.profileImage,
                                  postTime: post.createdAt,
                                  likes: post.count.likes,
                                  comments: post.count.comments,
                                  reposts: post.count.reposts,
                                  bookmarks: post.count.saves,
                                  content: post.content,
                                  pictures: post.media,
                                  currentUser: user!,
                                  postId: post.id,
                                  isLiked: post.isLiked,
                                  isReposted: post.isReposted,
                                  isSaved: post.isSaved,
                                ),
                              );
                            },
                          )
                        : Center(child: CircularProgressIndicator()),
                    isRepostsLoaded
                        ? ListView.builder(
                            itemCount: reposts!.posts.length,
                            itemBuilder: (context, index) {
                              final repost = reposts!.posts[index];

                              return GestureDetector(
                                onTap: () {},
                                child: PostCard(
                                  dividerColor: dividerColor,
                                  iconColor: iconColor,
                                  authorName: repost.author.fullName,
                                  authorHandle: repost.author.username,
                                  imageUrl: repost.author.profileImage,
                                  postTime: repost.createdAt,
                                  likes: repost.count.likes,
                                  comments: repost.count.comments,
                                  reposts: repost.count.reposts,
                                  bookmarks: repost.count.saves,
                                  content: repost.content,
                                  pictures: repost.media,
                                  currentUser: user!,
                                  postId: repost.id,
                                  isLiked: repost.isLiked,
                                  isReposted: repost.isReposted,
                                  isSaved: repost.isSaved,
                                ),
                              );
                            },
                          )
                        : Center(child: CircularProgressIndicator()),
                    isPostsLoaded
                        ? ListView.builder(
                            itemCount: mediaPosts!.posts.length,
                            itemBuilder: (context, index) {
                              final media = mediaPosts!.posts[index];
                              return GestureDetector(
                                onTap: () {},
                                child: PostCard(
                                  dividerColor: dividerColor,
                                  iconColor: iconColor,
                                  authorName: media.author.fullName,
                                  authorHandle: media.author.username,
                                  imageUrl: media.author.profileImage,
                                  postTime: media.createdAt,
                                  likes: media.count.likes,
                                  comments: media.count.comments,
                                  reposts: media.count.reposts,
                                  bookmarks: media.count.saves,
                                  content: media.content,
                                  pictures: media.media,
                                  currentUser: user!,
                                  postId: media.id,
                                  isLiked: media.isLiked,
                                  isReposted: media.isReposted,
                                  isSaved: media.isSaved,
                                ),
                              );
                            },
                          )
                        : Center(child: CircularProgressIndicator()),
                    isCommentsLoaded
                        ? ListView.builder(
                            itemCount: comments!.posts.length,
                            itemBuilder: (context, index) {
                              final comment = comments!.posts[index];
                              return GestureDetector(
                                onTap: () {},
                                child: PostCard(
                                  dividerColor: dividerColor,
                                  iconColor: iconColor,
                                  authorHandle: comment.author.username,
                                  imageUrl: comment.author.profileImage,
                                  postTime: comment.createdAt,
                                  likes: comment.count.likes,
                                  comments: 0,
                                  reposts: 0,
                                  bookmarks: 0,
                                  content: comment.content,
                                  pictures: comment.media,
                                  authorName: comment.author.fullName,
                                  currentUser: widget.currentUser,
                                  postId: comment.id,
                                  isLiked: comment.isLiked,
                                  isReposted: comment.isReposted,
                                  isSaved: comment.isSaved,
                                  isReply: comment.isReply,
                                  replyingToHandle:
                                      comment.parentPost!.author.username,
                                ),
                              );
                            },
                          )
                        : Center(child: CircularProgressIndicator()),
                    isSavedPostsLoaded
                        ? ListView.builder(
                            itemCount: savedPosts!.posts.length,
                            itemBuilder: (context, index) {
                              final savedPost = savedPosts!.posts[index];
                              return GestureDetector(
                                onTap: () {},
                                child: PostCard(
                                  dividerColor: dividerColor,
                                  iconColor: iconColor,
                                  authorName: savedPost.author.fullName,
                                  authorHandle: savedPost.author.username,
                                  imageUrl: savedPost.author.profileImage,
                                  postTime: savedPost.createdAt,
                                  likes: savedPost.count.likes,
                                  comments: savedPost.count.comments,
                                  reposts: savedPost.count.reposts,
                                  bookmarks: savedPost.count.saves,
                                  content: savedPost.content,
                                  pictures: savedPost.media,
                                  currentUser: user!,
                                  postId: savedPost.id,
                                  isLiked: savedPost.isLiked,
                                  isReposted: savedPost.isReposted,
                                  isSaved: savedPost.isSaved,
                                ),
                              );
                            },
                          )
                        : Center(child: CircularProgressIndicator()),
                    isLikedPostsLoaded
                        ? ListView.builder(
                            itemCount: likedPosts!.posts.length,
                            itemBuilder: (context, index) {
                              final likedPost = likedPosts!.posts[index];
                              return GestureDetector(
                                onTap: () {},
                                child: PostCard(
                                  dividerColor: dividerColor,
                                  iconColor: iconColor,
                                  authorName: likedPost.author.fullName,
                                  authorHandle: likedPost.author.username,
                                  imageUrl: likedPost.author.profileImage,
                                  postTime: likedPost.createdAt,
                                  likes: likedPost.count.likes,
                                  comments: likedPost.count.comments,
                                  reposts: likedPost.count.reposts,
                                  bookmarks: likedPost.count.saves,
                                  content: likedPost.content,
                                  pictures: likedPost.media,
                                  currentUser: user!,
                                  postId: likedPost.id,
                                  isLiked: likedPost.isLiked,
                                  isReposted: likedPost.isReposted,
                                  isSaved: likedPost.isSaved,
                                ),
                              );
                            },
                          )
                        : Center(child: CircularProgressIndicator()),
                  ],
                ),
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }

  Container _buildHeader(Color iconColor) {
    return Container(
      height: getProportionateScreenHeight(152),
      padding: EdgeInsets.only(
        top: getProportionateScreenHeight(16),
        left: getProportionateScreenWidth(30),
        right: getProportionateScreenWidth(14.5),
      ),
      alignment: Alignment.topCenter,
      width: double.infinity,
      decoration: user!.bannerImage != null
          ? BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(user!.bannerImage),
                fit: BoxFit.cover,
              ),
            )
          : null,
      child: Row(
        children: [
          if (!widget.isFromNav)
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: SvgPicture.asset(
                "assets/icons/back_button.svg",
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                width: getProportionateScreenWidth(24),
                height: getProportionateScreenHeight(24),
              ),
            ),
          Spacer(),
          InkWell(
            onTap: () {},
            child: SvgPicture.asset(
              "assets/icons/search.svg",
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              width: getProportionateScreenWidth(24),
              height: getProportionateScreenHeight(24),
            ),
          ),
          SizedBox(width: getProportionateScreenWidth(10)),
          InkWell(
            onTap: user!.isOwnProfile ? _onMyMoreButtonTap : _onMoreButtonTap,
            child: SvgPicture.asset(
              "assets/icons/more-vertical.svg",
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              width: getProportionateScreenWidth(24),
              height: getProportionateScreenHeight(24),
            ),
          ),
        ],
      ),
    );
  }

  void _onMyMoreButtonTap() async {
    final selected = await showMenu<String>(
      context: context,
      color: Theme.of(context).scaffoldBackgroundColor,
      position: RelativeRect.fromLTRB(
        getProportionateScreenWidth(1000),
        getProportionateScreenHeight(80),
        getProportionateScreenWidth(10),
        getProportionateScreenHeight(100),
      ),
      items: [
        PopupMenuItem<String>(
          value: 'Settings',
          child: Text(
            'Settings',
            style: TextStyle(
              fontSize: getProportionateScreenWidth(15),
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'Account',
          child: Text(
            'Account',
            style: TextStyle(
              fontSize: getProportionateScreenWidth(15),
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ],
    );

    if (selected == 'Settings' && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SettingsScreen()),
      );
    }
  }

  void _onMoreButtonTap() async {
    final selected = await showMenu<String>(
      context: context,
      color: Theme.of(context).scaffoldBackgroundColor,
      position: RelativeRect.fromLTRB(
        getProportionateScreenWidth(1000),
        getProportionateScreenHeight(80),
        getProportionateScreenWidth(10),
        getProportionateScreenHeight(100),
      ),
      items: [
        if (user!.isFollowing)
          PopupMenuItem<String>(
            value: 'Unfollow',
            child: Text(
              'Unfollow',
              style: TextStyle(
                fontSize: getProportionateScreenWidth(15),
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        PopupMenuItem<String>(
          value: 'Mute',
          child: Text(
            'Mute',
            style: TextStyle(
              fontSize: getProportionateScreenWidth(15),
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'Block',
          child: Text(
            'Block',
            style: TextStyle(
              fontSize: getProportionateScreenWidth(15),
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ],
    );
    if (selected == 'Unfollow' && mounted) {}
  }

  Future<void> _followUser() async {
    final token = await AuthManager.getToken();

    final response = await http.post(
      Uri.parse("$baseUrl/api/v1/user/follow"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"userId": user!.id}),
    );

    if (response.statusCode == 200) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ProfileScreen(
              isVerified: true,
              userName: user!.username,
              currentUser: widget.currentUser,
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to follow user. Please try again.")),
      );
    }
  }

  Future<void> _unfollowUser() async {
    final token = await AuthManager.getToken();

    final response = await http.delete(
      Uri.parse("$baseUrl/api/v1/user/unfollow"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"userId": user!.id}),
    );

    if (response.statusCode == 200) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ProfileScreen(
              isVerified: true,
              userName: user!.username,
              currentUser: widget.currentUser,
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to unfollow user. Please try again.")),
      );
    }
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

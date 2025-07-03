import 'dart:convert';

import 'package:app/features/home/data/models/post_response_model.dart';
import 'package:app/features/home/domain/entities/post_response_entity.dart';
import 'package:app/features/home/presentation/pages/create_post_screen.dart';
import 'package:app/features/home/presentation/widgets/reply_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:app/constants.dart';
import 'package:app/size_config.dart';
import 'package:http/http.dart' as http;

import '../../../../services/auth_manager.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../widgets/notification_tile.dart';
import '../widgets/post_Card.dart';

// ignore: must_be_immutable
class HomeScreen extends StatefulWidget {
  HomeScreen({super.key, this.onHomeButtonPressed, required this.currentUser});
  VoidCallback? onHomeButtonPressed;
  final UserEntity? currentUser;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController controller;
  PostResponseEntity? recommendedPostResponse;
  PostResponseEntity? followingPostResponse;
  bool isRecommendedLoaded = false;
  bool isFollowingLoaded = false;

  bool isHome = true;
  bool isNotifications = false;
  Post? selectedPost;
  String dropDownValue = "Most Liked";

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
    widget.onHomeButtonPressed = resetHome;
    _getFolowingPosts();
    _getRecommendedPosts();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _toggleHome() {
    setState(() {
      isHome = !isHome;
    });
  }

  void _toggleNotifications() {
    setState(() {
      isNotifications = !isNotifications;
    });
  }

  void resetHome() {
    if (!isHome) {
      if (mounted) {
        setState(() {
          isHome = true;
          isNotifications = false;
        });
      }
    }
  }

  Future<void> _getFolowingPosts() async {
    final token = await AuthManager.getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/api/v1/posts/feed/timeline"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200) {
      followingPostResponse = PostResponseModel.fromJson(
        jsonDecode(response.body),
      );
      setState(() {
        isFollowingLoaded = true;
      });
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

  Future<void> _getRecommendedPosts() async {
    final token = await AuthManager.getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/api/v1/posts/feed/recommended"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200) {
      recommendedPostResponse = PostResponseModel.fromJson(
        jsonDecode(response.body),
      );
      setState(() {
        isRecommendedLoaded = true;
      });
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
    final dividerColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kGreyInputFillDark
        : kGreyInputBorder;
    final iconColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kWhite
        : kBlack;
    return Scaffold(
      body: isHome
          ? _buildHomeView(context, dividerColor, iconColor)
          : isNotifications
          ? _buildNotificationsView(context)
          : _buildPostDetailsView(dividerColor, iconColor),
      floatingActionButton: isHome
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreatePostScreen(),
                  ),
                );
              },
              shape: const CircleBorder(),
              mini: false,
              elevation: 0,
              highlightElevation: 0,
              backgroundColor: kLightPurple,
              child: Icon(Icons.add),
            )
          : null,
    );
  }

  Scaffold _buildPostDetailsView(Color dividerColor, Color iconColor) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(getProportionateScreenHeight(70)),
        child: SafeArea(
          child: AppBar(
            title: Text(
              "Post",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: getProportionateScreenHeight(20),
              ),
            ),
            centerTitle: false,
            shape: Border(bottom: BorderSide(color: dividerColor, width: 1)),
            leading: InkWell(
              onTap: () {
                _toggleHome();
              },
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: getProportionateScreenHeight(12),
                  vertical: getProportionateScreenHeight(12),
                ),
                child: SvgPicture.asset(
                  "assets/icons/back_button.svg",
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                ),
              ),
            ),
            scrolledUnderElevation: 0.0,
            surfaceTintColor: Colors.transparent,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: getProportionateScreenHeight(8)),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PostCard(
                dividerColor: dividerColor,
                iconColor: iconColor,
                authorName: selectedPost!.author.fullName,
                authorHandle: selectedPost!.author.username,
                imageUrl: selectedPost!.author.profileImage,
                postTime: selectedPost!.createdAt,
                likes: selectedPost!.count.likes,
                comments: selectedPost!.count.comments,
                reposts: selectedPost!.count.reposts,
                bookmarks: selectedPost!.count.saves,
                content: selectedPost!.content,
                pictures: selectedPost!.media,
              ),
              SizedBox(height: getProportionateScreenHeight(11.09)),
              Container(
                padding: EdgeInsets.only(left: getProportionateScreenWidth(21)),
                child: DropdownButton<String>(
                  value: dropDownValue,
                  icon: null,
                  onChanged: (String? newValue) {
                    setState(() {
                      dropDownValue = newValue!;
                    });
                  },
                  underline: Container(),
                  items: <String>['Most Liked', 'Most Recent'].map((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: getProportionateScreenHeight(14),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: mockReplies.length,
                itemBuilder: (context, index) {
                  return ReplyCard(
                    dividerColor: dividerColor,
                    iconColor: iconColor,
                    replyerName: mockReplies[index]["userName"],
                    replyerHandle: mockReplies[index]["handle"],
                    imageUrl: mockReplies[index]["userImage"],
                    postTime: DateTime.now(),
                    likes: mockReplies[index]["likes"],
                    comments: mockReplies[index]["comments"],
                    reposts: mockReplies[index]["reposts"],
                    bookmarks: mockReplies[index]["bookmarks"],
                    content: mockReplies[index]["content"],
                    pictures: mockReplies[index]["pictures"],
                    authorHandle: mockReplies[index]["handle"],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Scaffold _buildHomeView(
    BuildContext context,
    Color dividerColor,
    Color iconColor,
  ) {
    return Scaffold(
      appBar: _homeAppBar(context),
      body: TabBarView(
        controller: controller,
        children: [
          isRecommendedLoaded
              ? ListView.builder(
                  itemCount: recommendedPostResponse!.posts.length,
                  itemBuilder: (context, index) {
                    final post = recommendedPostResponse!.posts[index];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedPost = post;
                        });
                        _toggleHome();
                      },
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
                      ),
                    );
                  },
                )
              : Center(child: CircularProgressIndicator()),
          isFollowingLoaded
              ? ListView.builder(
                  itemCount: followingPostResponse!.posts.length,
                  itemBuilder: (context, index) {
                    final post = followingPostResponse!.posts[index];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedPost = post;
                        });
                        _toggleHome();
                      },
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
                      ),
                    );
                  },
                )
              : Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  PreferredSize _homeAppBar(BuildContext context) {
    final dividerColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kGreyInputFillDark
        : kGreyInputBorder;
    final iconColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kWhite
        : kBlack;
    return PreferredSize(
      preferredSize: Size.fromHeight(getProportionateScreenHeight(100)),
      child: SafeArea(
        child: AppBar(
          leading: Padding(
            padding: EdgeInsets.only(left: getProportionateScreenWidth(16)),
            child: Container(
              height: getProportionateScreenHeight(34),
              width: getProportionateScreenWidth(34),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(widget.currentUser!.profileImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          bottom: TabBar(
            controller: controller,
            indicatorColor: kLightPurple,
            dividerColor: dividerColor,
            labelStyle: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w500),
            unselectedLabelStyle: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w500),
            tabs: [
              Tab(
                child: SizedBox(
                  width: getProportionateScreenWidth(143),
                  child: Center(child: Text("Recomended")),
                ),
              ),
              Tab(
                child: SizedBox(
                  width: getProportionateScreenWidth(143),
                  child: Center(child: Text("Following")),
                ),
              ),
            ],
            indicatorSize: TabBarIndicatorSize.label,
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: getProportionateScreenWidth(22)),
              child: SizedBox(
                height: getProportionateScreenHeight(24),
                width: getProportionateScreenWidth(24),
                child: InkWell(
                  onTap: () {
                    _toggleHome();
                    _toggleNotifications();
                  },
                  child: SvgPicture.asset(
                    "assets/icons/bell.svg",
                    colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  ),
                ),
              ),
            ),
          ],
          scrolledUnderElevation: 0.0,
          surfaceTintColor: Colors.transparent,
        ),
      ),
    );
  }

  Scaffold _buildNotificationsView(BuildContext context) {
    final dividerColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kGreyInputFillDark
        : kGreyInputBorder;
    final iconColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kWhite
        : kBlack;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: getProportionateScreenHeight(84)),
            Padding(
              padding: EdgeInsets.only(left: getProportionateScreenWidth(36)),
              child: Text(
                "Notifications",
                style: Theme.of(context).textTheme.displayMedium!.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: getProportionateScreenWidth(24),
                ),
              ),
            ),
            SizedBox(height: getProportionateScreenHeight(10)),
            Divider(thickness: 1, color: dividerColor),
            SizedBox(height: getProportionateScreenHeight(32)),
            Padding(
              padding: EdgeInsets.only(
                left: getProportionateScreenWidth(20),
                right: getProportionateScreenWidth(16),
              ),
              child: Column(
                children: List.generate(mockNotifications.length, (index) {
                  return Column(
                    children: [
                      NotificationTile(
                        iconColor: iconColor,
                        username: mockNotifications[index]["userName"],
                        action: mockNotifications[index]["action"],
                        time: mockNotifications[index]["time"],
                        image: mockNotifications[index]["userImg"],
                        isClickable: mockNotifications[index]["isClickable"],
                        buttonText: mockNotifications[index]["buttonText"],
                      ),
                      SizedBox(height: getProportionateScreenHeight(25)),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

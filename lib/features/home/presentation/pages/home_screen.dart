import 'dart:convert';

import 'package:app/features/home/data/models/post_response_model.dart';
import 'package:app/features/home/domain/entities/post_response_entity.dart';
import 'package:app/features/home/presentation/pages/create_post_screen.dart';
import 'package:app/features/home/presentation/pages/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:app/constants.dart';
import 'package:app/size_config.dart';
import 'package:http/http.dart' as http;

import '../../../../services/auth_manager.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../widgets/post_Card.dart';

// ignore: must_be_immutable
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.currentUser});
  final UserEntity currentUser;

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
  Post? selectedPost;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
    if (mounted) {
      _getFolowingPosts();
      _getRecommendedPosts();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
      body: _buildHomeView(context, dividerColor, iconColor),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreatePostScreen(
                profileImage: widget.currentUser.profileImage,
              ),
            ),
          );
        },
        shape: const CircleBorder(),
        mini: false,
        elevation: 0,
        highlightElevation: 0,
        backgroundColor: kLightPurple,
        child: Icon(Icons.add),
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
                    return PostCard(
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
                      currentUser: widget.currentUser,
                    );
                  },
                )
              : Center(child: CircularProgressIndicator()),
          isFollowingLoaded
              ? ListView.builder(
                  itemCount: followingPostResponse!.posts.length,
                  itemBuilder: (context, index) {
                    final post = followingPostResponse!.posts[index];
                    return PostCard(
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
                      currentUser: widget.currentUser,
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
                  image: NetworkImage(widget.currentUser.profileImage),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsScreen(),
                      ),
                    );
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
}

import 'dart:convert';

import 'package:app/features/home/data/models/post_response_model.dart';
import 'package:app/features/home/domain/entities/post_response_entity.dart'
    hide User;
import 'package:app/features/home/presentation/pages/create_post_screen.dart';
import 'package:app/features/home/presentation/pages/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:app/constants.dart';
import 'package:app/size_config.dart';
import 'package:http/http.dart' as http;
import 'package:stream_video_flutter/stream_video_flutter.dart';

import '../../../../services/auth_manager.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../chat/presentation/pages/live_stream_screen.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
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

  // FAB expansion state
  bool _isFabExpanded = false;

  // Recommended posts pagination
  List<Post> recommendedPosts = [];
  bool isRecommendedLoaded = false;
  bool isLoadingMoreRecommended = false;
  bool hasMoreRecommended = true;
  int recommendedPage = 1;
  final int recommendedLimit = 10;

  // Following posts pagination
  List<Post> followingPosts = [];
  bool isFollowingLoaded = false;
  bool isLoadingMoreFollowing = false;
  bool hasMoreFollowing = true;
  int followingPage = 1;
  final int followingLimit = 10;

  // Scroll controllers
  late ScrollController recommendedScrollController;
  late ScrollController followingScrollController;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);

    // Initialize scroll controllers
    recommendedScrollController = ScrollController();
    followingScrollController = ScrollController();

    // Add scroll listeners
    recommendedScrollController.addListener(_onRecommendedScroll);
    followingScrollController.addListener(_onFollowingScroll);

    if (mounted) {
      _getFollowingPosts();
      _getRecommendedPosts();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    recommendedScrollController.dispose();
    followingScrollController.dispose();
    super.dispose();
  }

  void _onRecommendedScroll() {
    if (recommendedScrollController.position.pixels ==
        recommendedScrollController.position.maxScrollExtent) {
      _loadMoreRecommendedPosts();
    }
  }

  void _onFollowingScroll() {
    if (followingScrollController.position.pixels ==
        followingScrollController.position.maxScrollExtent) {
      _loadMoreFollowingPosts();
    }
  }

  Future<void> _getFollowingPosts({bool isRefresh = false}) async {
    if (isRefresh) {
      followingPage = 1;
      followingPosts.clear();
      hasMoreFollowing = true;
    }

    final token = await AuthManager.getToken();
    final response = await http.get(
      Uri.parse(
        "$baseUrl/api/v1/posts/feed/timeline?page=$followingPage&limit=$followingLimit",
      ),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final postResponse = PostResponseModel.fromJson(
        jsonDecode(response.body),
      );

      setState(() {
        if (isRefresh) {
          followingPosts = postResponse.posts;
        } else {
          followingPosts.addAll(postResponse.posts);
        }
        isFollowingLoaded = true;
        hasMoreFollowing = postResponse.posts.length == followingLimit;
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

  Future<void> _getRecommendedPosts({bool isRefresh = false}) async {
    if (isRefresh) {
      recommendedPage = 1;
      recommendedPosts.clear();
      hasMoreRecommended = true;
    }

    final token = await AuthManager.getToken();
    final response = await http.get(
      Uri.parse(
        "$baseUrl/api/v1/posts/feed/recommended?page=$recommendedPage&limit=$recommendedLimit",
      ),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final postResponse = PostResponseModel.fromJson(
        jsonDecode(response.body),
      );

      setState(() {
        if (isRefresh) {
          recommendedPosts = postResponse.posts;
        } else {
          recommendedPosts.addAll(postResponse.posts);
        }
        isRecommendedLoaded = true;
        hasMoreRecommended = postResponse.posts.length == recommendedLimit;
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

  Future<void> _loadMoreRecommendedPosts() async {
    if (isLoadingMoreRecommended || !hasMoreRecommended) return;

    setState(() {
      isLoadingMoreRecommended = true;
    });

    recommendedPage++;

    final token = await AuthManager.getToken();
    final response = await http.get(
      Uri.parse(
        "$baseUrl/api/v1/posts/feed/recommended?page=$recommendedPage&limit=$recommendedLimit",
      ),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final postResponse = PostResponseModel.fromJson(
        jsonDecode(response.body),
      );

      setState(() {
        recommendedPosts.addAll(postResponse.posts);
        hasMoreRecommended = postResponse.posts.length == recommendedLimit;
        isLoadingMoreRecommended = false;
      });
    } else {
      setState(() {
        isLoadingMoreRecommended = false;
        recommendedPage--; // Revert page increment on error
      });
    }
  }

  Future<void> _loadMoreFollowingPosts() async {
    if (isLoadingMoreFollowing || !hasMoreFollowing) return;

    setState(() {
      isLoadingMoreFollowing = true;
    });

    followingPage++;

    final token = await AuthManager.getToken();
    final response = await http.get(
      Uri.parse(
        "$baseUrl/api/v1/posts/feed/timeline?page=$followingPage&limit=$followingLimit",
      ),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final postResponse = PostResponseModel.fromJson(
        jsonDecode(response.body),
      );

      setState(() {
        followingPosts.addAll(postResponse.posts);
        hasMoreFollowing = postResponse.posts.length == followingLimit;
        isLoadingMoreFollowing = false;
      });
    } else {
      setState(() {
        isLoadingMoreFollowing = false;
        followingPage--; // Revert page increment on error
      });
    }
  }

  void _toggleFabExpansion() {
    setState(() {
      _isFabExpanded = !_isFabExpanded;
    });
  }

  void _navigateToCreatePost() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CreatePostScreen(profileImage: widget.currentUser.profileImage),
      ),
    );
    // Close the expansion after navigation
    setState(() {
      _isFabExpanded = false;
    });
  }

  Future<void> _handleLivestream() async {
    final token = await AuthManager.getToken();
    String callToken;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/calls/live-stream'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        callToken = jsonDecode(response.body)['token'];
        StreamVideo.reset();
        StreamVideo(
          getStreamKey,
          user: User(
            info: UserInfo(
              name: widget.currentUser.fullName,
              id: widget.currentUser.id,
            ),
          ),
          userToken: callToken,
        );
        String roomId = jsonDecode(response.body)['liveStream']['roomId'];
        var call = StreamVideo.instance.makeCall(
          callType: StreamCallType.liveStream(),
          id: roomId,
        );
        final result = await call.getOrCreate(
          members: [
            MemberRequest(
              userId: StreamVideo.instance.currentUser.id,
              role: 'host',
            ),
          ],
        );
        if (result.isFailure) {
          debugPrint('Not able to create a call.');
          return;
        }

        // final updateResult = await call.update(
        //   startsAt: DateTime.now().toUtc().add(const Duration(seconds: 120)),
        //   backstage: const StreamBackstageSettings(
        //     enabled: true,
        //     joinAheadTimeSeconds: 120,
        //   ),
        // );

        // if (updateResult.isFailure) {
        //   debugPrint('Not able to update the call.');
        //   debugPrint(updateResult.getErrorOrNull().toString());
        //   return;
        // }

        final connectOptions = CallConnectOptions(
          camera: TrackOption.enabled(),
          microphone: TrackOption.enabled(),
        );

        await call.join(connectOptions: connectOptions);

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LiveStreamScreen(livestreamCall: call),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error joining or creating call: $e');
      debugPrint(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Error joining or creating call: $e',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    setState(() {
      _isFabExpanded = false;
    });
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
      floatingActionButton: _buildExpandableFab(),
    );
  }

  Widget _buildExpandableFab() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Livestream button
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: _isFabExpanded ? 56 : 0,
          child: AnimatedOpacity(
            duration: Duration(milliseconds: 300),
            opacity: _isFabExpanded ? 1.0 : 0.0,
            child: _isFabExpanded
                ? Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: FloatingActionButton(
                      onPressed: _handleLivestream,
                      heroTag: "livestream",
                      shape: const CircleBorder(),
                      mini: true,
                      elevation: 4,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.live_tv, color: Colors.black, size: 20),
                    ),
                  )
                : SizedBox.shrink(),
          ),
        ),
        // Post button
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: _isFabExpanded ? 56 : 0,
          child: AnimatedOpacity(
            duration: Duration(milliseconds: 300),
            opacity: _isFabExpanded ? 1.0 : 0.0,
            child: _isFabExpanded
                ? Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: FloatingActionButton(
                      onPressed: _navigateToCreatePost,
                      heroTag: "post",
                      shape: const CircleBorder(),
                      mini: true,
                      elevation: 4,
                      backgroundColor: kLightPurple,
                      child: Icon(Icons.edit, color: Colors.black, size: 20),
                    ),
                  )
                : SizedBox.shrink(),
          ),
        ),
        // Main FAB
        FloatingActionButton(
          onPressed: _toggleFabExpansion,
          heroTag: "main",
          shape: const CircleBorder(),
          mini: false,
          elevation: 4,
          backgroundColor: kLightPurple,
          child: AnimatedRotation(
            turns: _isFabExpanded ? 0.125 : 0, // 45 degrees rotation for X
            duration: Duration(milliseconds: 300),
            child: Icon(
              _isFabExpanded ? Icons.close : Icons.add,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPostsList({
    required List<Post> posts,
    required bool isLoaded,
    required bool isLoadingMore,
    required ScrollController scrollController,
    required Color dividerColor,
    required Color iconColor,
    required VoidCallback onRefresh,
  }) {
    if (!isLoaded) {
      return Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () async {
        onRefresh();
      },
      child: ListView.builder(
        controller: scrollController,
        itemCount: posts.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == posts.length) {
            return Container(
              padding: EdgeInsets.all(16),
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            );
          }

          final post = posts[index];
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
            postId: post.id,
            isLiked: post.isLiked,
            isReposted: post.isReposted,
            isSaved: post.isSaved,
          );
        },
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
          _buildPostsList(
            posts: recommendedPosts,
            isLoaded: isRecommendedLoaded,
            isLoadingMore: isLoadingMoreRecommended,
            scrollController: recommendedScrollController,
            dividerColor: dividerColor,
            iconColor: iconColor,
            onRefresh: () => _getRecommendedPosts(isRefresh: true),
          ),
          _buildPostsList(
            posts: followingPosts,
            isLoaded: isFollowingLoaded,
            isLoadingMore: isLoadingMoreFollowing,
            scrollController: followingScrollController,
            dividerColor: dividerColor,
            iconColor: iconColor,
            onRefresh: () => _getFollowingPosts(isRefresh: true),
          ),
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
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                      currentUser: widget.currentUser,
                      isVerified: true,
                      userName: widget.currentUser.username,
                    ),
                  ),
                );
              },
              child: Container(
                height: getProportionateScreenHeight(34),
                width: getProportionateScreenWidth(34),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(
                      widget.currentUser.profileImage.isEmpty
                          ? defaultAvatar
                          : widget.currentUser.profileImage,
                    ),
                    fit: BoxFit.cover,
                  ),
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
                  child: Center(child: Text("Recommended")),
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
                        builder: (context) => NotificationsScreen(
                          currentUser: widget.currentUser,
                        ),
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

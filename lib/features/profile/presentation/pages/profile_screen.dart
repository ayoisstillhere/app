import 'dart:convert';

import 'package:app/features/profile/presentation/pages/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:app/components/social_text.dart';
import 'package:app/features/auth/data/models/user_model.dart';
import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:app/features/profile/presentation/pages/settings_screen.dart';
import 'package:app/size_config.dart';

import '../../../../constants.dart';
import '../../../../services/auth_manager.dart';
import '../../../chat/data/models/get_messages_response_model.dart'
    hide UserModel;
import '../../../chat/domain/entities/get_messages_response_entity.dart';
import '../../../chat/presentation/pages/chat_screen.dart';
import '../../../chat/presentation/pages/secret_chat_screen.dart';
import '../../../home/data/models/post_response_model.dart';
import '../../../home/presentation/widgets/post_Card.dart';
import 'followers_and_following_screen.dart';

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

  // Pagination data structures
  final Map<int, List<dynamic>> _tabPosts = {};
  final Map<int, bool> _tabHasMore = {};
  final Map<int, bool> _tabIsLoading = {};
  final Map<int, bool> _tabIsInitialLoading = {};
  final Map<int, int> _tabCurrentPage = {};
  final Map<int, ScrollController> _tabScrollControllers = {};

  // Tab endpoints
  final List<String> _tabEndpoints = [
    'posts',
    'reposts',
    'posts', // Media tab uses posts endpoint but filters for media
    'comments',
    'saves',
    'likes',
  ];

  bool isUserLoaded = false;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 6, vsync: this);

    // Initialize pagination data for each tab
    for (int i = 0; i < 6; i++) {
      _tabPosts[i] = [];
      _tabHasMore[i] = true;
      _tabIsLoading[i] = false;
      _tabIsInitialLoading[i] = true;
      _tabCurrentPage[i] = 1;
      _tabScrollControllers[i] = ScrollController();

      // Add scroll listener for pagination
      _tabScrollControllers[i]!.addListener(() => _onScroll(i));
    }

    controller.addListener(_onTabChanged);

    if (mounted) {
      _fetchUser();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    for (int i = 0; i < 6; i++) {
      _tabScrollControllers[i]?.dispose();
    }
    super.dispose();
  }

  Future<void> _createChat(
    List selectedUsers,
    String name,
    String image,
    String handle,
  ) async {
    final url = Uri.parse('$baseUrl/api/v1/chat/conversations');
    final token = await AuthManager.getToken();

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "participantUserIds": selectedUsers,
      "type": "DIRECT",
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (jsonDecode(response.body)['isSecret']) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SecretChatScreen(
                chatId: jsonDecode(response.body)['id'],
                name: name,
                imageUrl: image,
                currentUser: widget.currentUser,
                chatHandle: handle,
                isGroup: false,
                participants: List<Participant>.from(
                  (jsonDecode(response.body)['participants'] as List)
                      .map((e) => ParticipantModel.fromJson(e))
                      .toList(),
                ),
                isConversationMuted: jsonDecode(
                  response.body,
                )['isConversationMutedForMe'],
                isConversationBlockedForMe: jsonDecode(
                  response.body,
                )['isConversationBlockedForMe'],
              ),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                chatId: jsonDecode(response.body)['id'],
                name: name,
                imageUrl: image,
                currentUser: widget.currentUser,
                encryptionKey: jsonDecode(response.body)['encryptionKey'],
                chatHandle: handle,
                isGroup: false,
                participants: List<Participant>.from(
                  (jsonDecode(response.body)['participants'] as List)
                      .map((e) => ParticipantModel.fromJson(e))
                      .toList(),
                ),
                isConversationMuted: jsonDecode(
                  response.body,
                )['isConversationMutedForMe'],
                isConversationBlockedForMe: jsonDecode(
                  response.body,
                )['isConversationBlockedForMe'],
              ),
            ),
          );
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            jsonDecode(
              "$e",
            )['message'].toString().replaceAll(RegExp(r'\[|\]'), ''),
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  void _onTabChanged() {
    final currentIndex = controller.index;
    if (_tabPosts[currentIndex]!.isEmpty && _tabHasMore[currentIndex]!) {
      _loadTabData(currentIndex);
    }
  }

  void _onScroll(int tabIndex) {
    if (_tabScrollControllers[tabIndex]!.position.pixels ==
        _tabScrollControllers[tabIndex]!.position.maxScrollExtent) {
      _loadTabData(tabIndex);
    }
  }

  Future<void> _loadTabData(int tabIndex) async {
    if (_tabIsLoading[tabIndex]! || !_tabHasMore[tabIndex]!) return;

    setState(() {
      _tabIsLoading[tabIndex] = true;
    });

    try {
      final token = await AuthManager.getToken();
      final endpoint = _tabEndpoints[tabIndex];
      final page = _tabCurrentPage[tabIndex]!;

      final response = await http.get(
        Uri.parse(
          "$baseUrl/api/v1/posts/user/${user!.id}/$endpoint?page=$page&limit=10",
        ),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final responseData = PostResponseModel.fromJson(
          jsonDecode(response.body),
        );

        List<dynamic> newPosts = responseData.posts;

        // For media tab, filter posts with media
        if (tabIndex == 2) {
          newPosts = newPosts.where((post) => post.media.isNotEmpty).toList();
        }

        if (mounted) {
          setState(() {
            _tabPosts[tabIndex]!.addAll(newPosts);
            _tabCurrentPage[tabIndex] = page + 1;
            _tabHasMore[tabIndex] = responseData.pagination.hasMore;
            _tabIsLoading[tabIndex] = false;
            _tabIsInitialLoading[tabIndex] = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _tabIsLoading[tabIndex] = false;
            _tabIsInitialLoading[tabIndex] = false;
          });
          _showErrorSnackBar(response.body);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _tabIsLoading[tabIndex] = false;
          _tabIsInitialLoading[tabIndex] = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Error loading data: $e'),
          ),
        );
      }
    }
  }

  void _showErrorSnackBar(String responseBody) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          jsonDecode(
            responseBody,
          )['message'].toString().replaceAll(RegExp(r'\[|\]'), ''),
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
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
          isUserLoaded = true;
          if (!user!.isOwnProfile && (user!.isFollowing || user!.followsYou)) {
            canMessage = true;
          }
        });

        // Load initial tab data
        _loadTabData(0); // Load posts tab initially
      }
    } else {
      _showErrorSnackBar(response.body);
    }
  }

  Widget _buildTabContent(int tabIndex) {
    if (_tabIsInitialLoading[tabIndex]!) {
      return Center(child: CircularProgressIndicator());
    }

    if (_tabPosts[tabIndex]!.isEmpty && !_tabHasMore[tabIndex]!) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No posts yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _tabScrollControllers[tabIndex],
      itemCount: _tabPosts[tabIndex]!.length + (_tabHasMore[tabIndex]! ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _tabPosts[tabIndex]!.length) {
          // Loading indicator at the bottom
          return _tabIsLoading[tabIndex]!
              ? Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              : SizedBox.shrink();
        }

        final post = _tabPosts[tabIndex]![index];
        return GestureDetector(
          onTap: () {},
          child: PostCard(
            dividerColor:
                MediaQuery.of(context).platformBrightness == Brightness.dark
                ? kGreyInputFillDark
                : kGreyInputBorder,
            iconColor:
                MediaQuery.of(context).platformBrightness == Brightness.dark
                ? kWhite
                : kBlack,
            authorName: post.author.fullName,
            authorHandle: post.author.username,
            imageUrl: post.author.profileImage,
            postTime: post.createdAt,
            likes: post.count.likes,
            comments: tabIndex == 3 ? 0 : post.count.comments, // Comments tab
            reposts: tabIndex == 3 ? 0 : post.count.reposts, // Comments tab
            bookmarks: tabIndex == 3 ? 0 : post.count.saves, // Comments tab
            content: post.content,
            pictures: post.media,
            currentUser: user!,
            postId: post.id,
            isLiked: post.isLiked,
            isReposted: post.isReposted,
            isSaved: post.isSaved,
            isReply: tabIndex == 3 ? post.isReply : false,
            replyingToHandle: tabIndex == 3 && post.isReply
                ? post.parentPost?.author.username
                : null,
          ),
        );
      },
    );
  }

  // Method to refresh a specific tab
  Future<void> _refreshTab(int tabIndex) async {
    setState(() {
      _tabPosts[tabIndex] = [];
      _tabHasMore[tabIndex] = true;
      _tabIsLoading[tabIndex] = false;
      _tabIsInitialLoading[tabIndex] = true;
      _tabCurrentPage[tabIndex] = 1;
    });

    await _loadTabData(tabIndex);
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
                          _buildProfileInfo(),
                          SizedBox(height: getProportionateScreenHeight(18)),
                          _buildUserDetails(),
                          SizedBox(height: getProportionateScreenHeight(18)),
                          _buildActionButtons(),
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
                  children: List.generate(
                    6,
                    (index) => RefreshIndicator(
                      onRefresh: () => _refreshTab(index),
                      child: _buildTabContent(index),
                    ),
                  ),
                ),
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }

  // Extract profile info widget to reduce build method complexity
  Widget _buildProfileInfo() {
    return Padding(
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
                image: user!.profileImage.isEmpty
                    ? NetworkImage(defaultAvatar)
                    : NetworkImage(user!.profileImage),
                fit: BoxFit.cover,
              ),
              border: Border.all(width: 1, color: kPrimPurple),
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
                      fontSize: getProportionateScreenHeight(16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.isVerified)
                    SvgPicture.asset(
                      "assets/icons/verified.svg",
                      height: getProportionateScreenHeight(19.14),
                      width: getProportionateScreenWidth(19.14),
                    ),
                ],
              ),
              Text(
                "@${user!.username}",
                style: TextStyle(
                  fontSize: getProportionateScreenHeight(13),
                  color: kProfileText,
                ),
              ),
            ],
          ),
          Spacer(),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FollowersAndFollowingScreen(
                    index: 0,
                    userName: user!.username,
                  ),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  NumberFormat.compact().format(user!.followerCount),
                  style: TextStyle(
                    fontSize: getProportionateScreenHeight(16),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "Followers",
                  style: TextStyle(
                    fontSize: getProportionateScreenHeight(12),
                    fontWeight: FontWeight.w500,
                    color: kProfileText,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: getProportionateScreenWidth(10)),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FollowersAndFollowingScreen(
                    index: 1,
                    userName: user!.username,
                  ),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  NumberFormat.compact().format(user!.followingCount),
                  style: TextStyle(
                    fontSize: getProportionateScreenHeight(16),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "Following",
                  style: TextStyle(
                    fontSize: getProportionateScreenHeight(12),
                    fontWeight: FontWeight.w500,
                    color: kProfileText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserDetails() {
    return Padding(
      padding: EdgeInsets.only(left: getProportionateScreenWidth(30)),
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
              SizedBox(width: getProportionateScreenWidth(10)),
              Text(
                user!.location,
                style: TextStyle(
                  fontSize: getProportionateScreenHeight(12),
                  fontWeight: FontWeight.w500,
                  color: kProfileText,
                ),
              ),
              SizedBox(width: getProportionateScreenWidth(35)),
              SvgPicture.asset(
                "assets/icons/calendar.svg",
                height: getProportionateScreenHeight(18),
                width: getProportionateScreenWidth(18),
              ),
              SizedBox(width: getProportionateScreenWidth(10)),
              Text(
                'Since ${DateFormat('MMMM yyyy').format(user!.dateJoined)}',
                style: TextStyle(
                  fontSize: getProportionateScreenHeight(12),
                  fontWeight: FontWeight.w500,
                  color: kProfileText,
                ),
              ),
            ],
          ),
          SizedBox(height: getProportionateScreenHeight(9)),
          SocialText(
            text: user!.bio,
            baseStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontSize: getProportionateScreenHeight(12),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: canMessage
          ? EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(20))
          : EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(30)),
      child: Row(
        children: [
          // Edit Profile / Follow buttons
          if (user!.isOwnProfile)
            _buildActionButton("Edit Profile", null, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return EditProfileScreen();
                  },
                ),
              );
            }),
          if (!user!.isOwnProfile && !user!.isFollowing && !user!.followsYou)
            _buildActionButton("Follow", kAccentColor, _followUser),
          if (!user!.isOwnProfile && user!.isFollowing)
            _buildActionButton("Unfollow", null, _unfollowUser),
          if (!user!.isOwnProfile && user!.followsYou && !user!.isFollowing)
            _buildActionButton("Follow Back", kAccentColor, _followUser),

          Spacer(),

          // Share Profile button
          _buildActionButton("Share Profile", null, () {}),

          // Message button
          if (canMessage) ...[
            Spacer(),
            InkWell(
              onTap: () {
                _createChat(
                  [user!.id, widget.currentUser.id],
                  user!.fullName,
                  user!.profileImage,
                  user!.username,
                );
              },
              child: SvgPicture.asset(
                "assets/icons/mail.svg",
                height: getProportionateScreenHeight(24),
                width: getProportionateScreenWidth(24),
                colorFilter: ColorFilter.mode(kProfileText, BlendMode.srcIn),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    Color? backgroundColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: getProportionateScreenHeight(27),
        width: canMessage
            ? getProportionateScreenWidth(158.5)
            : getProportionateScreenWidth(163.5),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: backgroundColor == null
              ? Border.all(width: 1, color: kProfileText)
              : null,
          borderRadius: BorderRadius.circular(getProportionateScreenWidth(10)),
        ),
        child: Center(child: Text(text)),
      ),
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
              onTap: () => Navigator.pop(context),
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
    if (selected == 'Unfollow' && mounted) {
      await _unfollowUser();
    }
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
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}

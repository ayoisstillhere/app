import 'dart:convert';

import 'package:app/features/profile/data/models/followers_response_model.dart';
import 'package:app/features/profile/data/models/following_response_model.dart';
import 'package:app/features/profile/presentation/pages/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../../constants.dart';
import '../../../../services/auth_manager.dart';
import '../../../../size_config.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../chat/data/models/get_messages_response_model.dart';
import '../../../chat/domain/entities/get_messages_response_entity.dart';
import '../../../chat/presentation/pages/chat_screen.dart';
import '../../../chat/presentation/pages/secret_chat_screen.dart';

class FollowersAndFollowingScreen extends StatefulWidget {
  const FollowersAndFollowingScreen({
    super.key,
    required this.index,
    required this.userName,
    required this.userId,
  });
  final int index;
  final String userName;
  final String userId;

  @override
  State<FollowersAndFollowingScreen> createState() =>
      _FollowersAndFollowingScreenState();
}

class _FollowersAndFollowingScreenState
    extends State<FollowersAndFollowingScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController controller;
  bool userDataLoaded = false;
  late final UserEntity currentUser;

  // Followers data
  int followersPage = 1;
  List<Follower> followers = [];
  List<Follower> filteredFollowers = [];
  bool hasMoreFollowers = true;
  final int followersLimit = 10;
  bool isFollowersLoaded = false;

  // Following data
  int followingPage = 1;
  List<Following> following = [];
  List<Following> filteredFollowing = [];
  bool hasMoreFollowing = true;
  final int followingLimit = 10;
  bool isFollowingLoaded = false;

  // Search query
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    controller = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.index,
    );
    getCurrentUser();
    _searchController.addListener(_onSearchChanged);
    if (mounted) {
      _getFollowers();
      _getFollowing();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    controller.dispose();
    super.dispose();
  }

  Future<void> _getFollowers({bool isRefresh = false}) async {
    if (isRefresh) {
      followersPage = 1;
      followers.clear();
      hasMoreFollowers = true;
    }

    final token = await AuthManager.getToken();
    final response = await http.get(
      Uri.parse(
        "$baseUrl/api/v1/user/${widget.userId}/followers?page=$followersPage&limit=$followersLimit",
      ),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final followerResponse = FollowersResponse.fromJson(
        jsonDecode(response.body),
      );

      setState(() {
        if (isRefresh) {
          followers = followerResponse.followers;
        } else {
          followers.addAll(followerResponse.followers);
        }
        isFollowersLoaded = true;
        hasMoreFollowers = followerResponse.followers.length == followersLimit;
        followersPage++;
        _filterFollowers();
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

  Future<void> _getFollowing({bool isRefresh = false}) async {
    if (isRefresh) {
      followingPage = 1;
      following.clear();
      hasMoreFollowing = true;
    }

    final token = await AuthManager.getToken();
    final response = await http.get(
      Uri.parse(
        "$baseUrl/api/v1/user/${widget.userId}/following?page=$followingPage&limit=$followingLimit",
      ),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final followingResponse = FollowingResponse.fromJson(
        jsonDecode(response.body),
      );

      setState(() {
        if (isRefresh) {
          following = followingResponse.following;
        } else {
          following.addAll(followingResponse.following);
        }
        isFollowingLoaded = true;
        hasMoreFollowing = followingResponse.following.length == followingLimit;
        followingPage++;
        _filterFollowing();
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

  Future<void> getCurrentUser() async {
    UserEntity? user = await AuthManager.getCurrentUser();
    if (mounted) {
      setState(() {
        currentUser = user!;
        userDataLoaded = true;
      });
    }
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _searchController.text.toLowerCase();
      _filterFollowers();
      _filterFollowing();
    });
  }

  void _filterFollowers() {
    filteredFollowers = followers.where((follower) {
      final name = follower.fullName?.toLowerCase();
      final username = follower.username.toLowerCase();
      return name != null && name.contains(searchQuery) || username.contains(searchQuery);
    }).toList();
  }

  void _filterFollowing() {
    filteredFollowing = following.where((followingUser) {
      final name = followingUser.fullName?.toLowerCase() ?? '';
      final username = followingUser.username.toLowerCase();
      return name.contains(searchQuery) || username.contains(searchQuery);
    }).toList();
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      // Search functionality is handled by _onSearchChanged
    }
  }

  Widget _buildFollowerCard(Follower follower) {
    List selectedUsers = [];
    selectedUsers.add(follower.id);
    selectedUsers.add(currentUser.id);
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(
              isVerified: true,
              userName: follower.username,
              currentUser: currentUser,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: getProportionateScreenHeight(24)),
        child: Row(
          children: [
            Container(
              width: getProportionateScreenWidth(25),
              height: getProportionateScreenHeight(25),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: follower.profileImage != null
                      ? NetworkImage(follower.profileImage!)
                      : AssetImage('assets/images/avatar.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: getProportionateScreenWidth(10)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(follower.fullName ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('@${follower.username}'),
              ],
            ),
            Spacer(),
            (follower.followsYou && !follower.youFollow)
                ? InkWell(
                    onTap: () async {
                      final token = await AuthManager.getToken();
                      final response = await http.post(
                        Uri.parse("$baseUrl/api/v1/user/follow"),
                        headers: {
                          "Authorization": "Bearer $token",
                          "Content-Type": "application/json",
                        },
                        body: jsonEncode({"userId": follower.id}),
                      );

                      if (response.statusCode == 200) {
                        if (mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => ProfileScreen(
                                isVerified: true,
                                userName: follower.username,
                                currentUser: currentUser,
                              ),
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(
                              "Failed to follow user. Please try again.",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: getProportionateScreenWidth(90),
                      height: getProportionateScreenHeight(37),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: kAccentColor,
                      ),
                      child: Center(
                        child: Text(
                          'Follow Back',
                          style: TextStyle(
                            color: kBlack,
                            fontWeight: FontWeight.w500,
                            fontSize: getProportionateScreenHeight(12),
                          ),
                        ),
                      ),
                    ),
                  )
                : InkWell(
                    onTap: () {
                      _goToMessage(
                        selectedUsers,
                        follower.fullName ?? '',
                        follower.profileImage ?? '',
                        follower.username,
                      );
                    },
                    child: Container(
                      width: getProportionateScreenWidth(90),
                      height: getProportionateScreenHeight(37),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: kFollowerAndFollowingBorder),
                        color: kFollowerAndFollowingFill,
                      ),
                      child: Center(
                        child: Text(
                          'Message',
                          style: TextStyle(
                            color: kWhite,
                            fontWeight: FontWeight.w500,
                            fontSize: getProportionateScreenHeight(12),
                          ),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowingCard(Following followingUser) {
    List selectedUsers = [];
    selectedUsers.add(followingUser.id);
    selectedUsers.add(currentUser.id);
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(
              isVerified: true,
              userName: followingUser.username,
              currentUser: currentUser,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: getProportionateScreenHeight(24)),
        child: Row(
          children: [
            Container(
              width: getProportionateScreenWidth(25),
              height: getProportionateScreenHeight(25),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: followingUser.profileImage != null
                      ? NetworkImage(followingUser.profileImage!)
                      : AssetImage('assets/images/avatar.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: getProportionateScreenWidth(10)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(followingUser.fullName ?? ''),
                Text('@${followingUser.username}'),
              ],
            ),
            Spacer(),
            InkWell(
              onTap: () {
                _goToMessage(
                  selectedUsers,
                  followingUser.fullName ?? '',
                  followingUser.profileImage ?? '',
                  followingUser.username,
                );
              },
              child: Container(
                width: getProportionateScreenWidth(90),
                height: getProportionateScreenHeight(37),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kFollowerAndFollowingBorder),
                  color: kFollowerAndFollowingFill,
                ),
                child: Center(
                  child: Text(
                    'Message',
                    style: TextStyle(
                      color: kWhite,
                      fontWeight: FontWeight.w500,
                      fontSize: getProportionateScreenHeight(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowersTab() {
    return RefreshIndicator(
      onRefresh: () => _getFollowers(isRefresh: true),
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: getProportionateScreenWidth(16),
          ),
          child: Column(
            children: [
              SizedBox(height: getProportionateScreenHeight(25)),
              TextFormField(
                controller: _searchController,
                onFieldSubmitted: _onSearchSubmitted,
                decoration:
                    _buildFollowersAndFollowingSearchFieldInputDecoration(
                      context,
                    ),
              ),
              SizedBox(height: getProportionateScreenHeight(24)),
              if (!isFollowersLoaded)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(getProportionateScreenHeight(48)),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (filteredFollowers.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(getProportionateScreenHeight(48)),
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off,
                          size: getProportionateScreenWidth(48),
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: getProportionateScreenHeight(16)),
                        Text(
                          searchQuery.isEmpty
                              ? 'No followers found'
                              : 'No followers match your search',
                          style: TextStyle(
                            fontSize: getProportionateScreenHeight(16),
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount:
                      filteredFollowers.length + (hasMoreFollowers ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == filteredFollowers.length) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(
                            getProportionateScreenHeight(16),
                          ),
                          child: ElevatedButton(
                            onPressed: () => _getFollowers(),
                            child: Text('Load More'),
                          ),
                        ),
                      );
                    }
                    return _buildFollowerCard(filteredFollowers[index]);
                  },
                ),
              SizedBox(height: getProportionateScreenHeight(24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFollowingTab() {
    return RefreshIndicator(
      onRefresh: () => _getFollowing(isRefresh: true),
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: getProportionateScreenWidth(16),
          ),
          child: Column(
            children: [
              SizedBox(height: getProportionateScreenHeight(25)),
              TextFormField(
                controller: _searchController,
                onFieldSubmitted: _onSearchSubmitted,
                decoration:
                    _buildFollowersAndFollowingSearchFieldInputDecoration(
                      context,
                    ),
              ),
              SizedBox(height: getProportionateScreenHeight(24)),
              if (!isFollowingLoaded)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(getProportionateScreenHeight(48)),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (filteredFollowing.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(getProportionateScreenHeight(48)),
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off,
                          size: getProportionateScreenWidth(48),
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: getProportionateScreenHeight(16)),
                        Text(
                          searchQuery.isEmpty
                              ? 'No following found'
                              : 'No following match your search',
                          style: TextStyle(
                            fontSize: getProportionateScreenHeight(16),
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount:
                      filteredFollowing.length + (hasMoreFollowing ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == filteredFollowing.length) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(
                            getProportionateScreenHeight(16),
                          ),
                          child: ElevatedButton(
                            onPressed: () => _getFollowing(),
                            child: Text('Load More'),
                          ),
                        ),
                      );
                    }
                    return _buildFollowingCard(filteredFollowing[index]);
                  },
                ),
              SizedBox(height: getProportionateScreenHeight(24)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleFollowUnfollow(String userId) async {
    // Implement follow/unfollow logic here
    // You'll need to call your API endpoint for following/unfollowing
    final token = await AuthManager.getToken();
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/v1/user/$userId/follow"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        // Handle success - maybe refresh the lists
        _getFollowers(isRefresh: true);
        _getFollowing(isRefresh: true);
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Failed to follow/unfollow user',
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
            'An error occurred',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  Future<void> _handleUnfollow(String userId) async {
    // Implement unfollow logic here
    final token = await AuthManager.getToken();
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/api/v1/user/$userId/follow"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        // Handle success - maybe refresh the lists
        _getFollowers(isRefresh: true);
        _getFollowing(isRefresh: true);
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Failed to unfollow user',
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
            'An error occurred',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return userDataLoaded
        ? Scaffold(
            appBar: _buildAppBar(),
            body: TabBarView(
              controller: controller,
              children: [_buildFollowersTab(), _buildFollowingTab()],
            ),
          )
        : const Center(child: CircularProgressIndicator());
  }

  PreferredSizeWidget _buildAppBar() {
    final dividerColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kGreyInputFillDark
        : kGreyInputBorder;
    return PreferredSize(
      preferredSize: Size.fromHeight(getProportionateScreenHeight(120)),
      child: AppBar(
        title: Text(
          widget.userName,
          style: TextStyle(
            fontSize: getProportionateScreenHeight(24),
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
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
                child: Center(
                  child: Text(
                    currentUser.followerCount == 1
                        ? "1 follower"
                        : "${NumberFormat.compact().format(currentUser.followerCount)} followers",
                  ),
                ),
              ),
            ),
            Tab(
              child: SizedBox(
                width: getProportionateScreenWidth(143),
                child: Center(
                  child: Text(
                    "${NumberFormat.compact().format(currentUser.followingCount)} following",
                  ),
                ),
              ),
            ),
          ],
          indicatorSize: TabBarIndicatorSize.label,
        ),
      ),
    );
  }

  InputDecoration _buildFollowersAndFollowingSearchFieldInputDecoration(
    BuildContext context,
  ) {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(getProportionateScreenWidth(30)),
        borderSide: BorderSide(
          color: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? kGreyDarkInputBorder
              : kGreyInputBorder,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(getProportionateScreenWidth(30)),
        borderSide: BorderSide(
          color: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? kGreyDarkInputBorder
              : kGreyInputBorder,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(getProportionateScreenWidth(30)),
        borderSide: BorderSide(
          color: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? kGreyDarkInputBorder
              : kGreyInputBorder,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(getProportionateScreenWidth(30)),
        borderSide: BorderSide(
          color: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? kGreyDarkInputBorder
              : kGreyInputBorder,
        ),
      ),
      fillColor: MediaQuery.of(context).platformBrightness == Brightness.dark
          ? kGreySearchInput
          : null,
      filled: MediaQuery.of(context).platformBrightness == Brightness.dark,
      prefixIcon: Padding(
        padding: EdgeInsets.all(getProportionateScreenHeight(14)),
        child: SvgPicture.asset(
          "assets/icons/search.svg",
          colorFilter: ColorFilter.mode(
            MediaQuery.of(context).platformBrightness == Brightness.dark
                ? kGreyDarkInputBorder
                : kGreyInputBorder,
            BlendMode.srcIn,
          ),
          width: getProportionateScreenWidth(14),
          height: getProportionateScreenHeight(14),
        ),
      ),
      hintText: "Search",
    );
  }

  Future<void> _goToMessage(
    List selectedUsers,
    String name,
    String image,
    String handle,
  ) async {
    final url = Uri.parse('$baseUrl/api/v1/chat/conversations');
    final token = await AuthManager.getToken();

    // Create multipart request
    final request = http.MultipartRequest('POST', url);

    // Add headers
    request.headers['Authorization'] = 'Bearer $token';

    // Add form fields
    request.fields['participantUserIds'] = jsonEncode(selectedUsers);
    request.fields['type'] = 'DIRECT';

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (jsonDecode(response.body)['isSecret']) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SecretChatScreen(
                chatId: jsonDecode(response.body)['id'],
                name: name,
                imageUrl: image,
                currentUser: currentUser,
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
                currentUser: currentUser,
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
            'Error: ${e.toString()}',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }
}

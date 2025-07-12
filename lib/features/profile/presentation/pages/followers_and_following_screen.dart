import 'dart:convert';

import 'package:app/features/profile/data/models/followers_response_model.dart';
import 'package:app/features/profile/data/models/following_response_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../../constants.dart';
import '../../../../services/auth_manager.dart';
import '../../../../size_config.dart';
import '../../../auth/domain/entities/user_entity.dart';

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
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;
  int followersPage = 1;
  List<Follower> followers = [];
  bool hasMoreFollowers = true;
  final int followersLimit = 10;
  bool isFollowersLoaded = false;
  int followingPage = 1;
  List<Following> following = [];
  bool hasMoreFollowing = true;
  final int followingLimit = 10;
  bool isFollowingLoaded = false;

  @override
  void initState() {
    super.initState();
    controller = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.index,
    );
    getCurrentUser();
    _searchFocusNode.addListener(_onSearchFocusChange);
    if (mounted) {
      _getFollowers();
      _getFollowing();
    }
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
        isFollowingLoaded = true;
        hasMoreFollowers = followerResponse.followers.length == followersLimit;
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
        currentUser = user!; // This line causes the error if called twice
        userDataLoaded = true;
      });
    }
  }

  void _onSearchFocusChange() {
    setState(() {
      _isSearchFocused = _searchFocusNode.hasFocus;
    });
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {}
  }

  @override
  Widget build(BuildContext context) {
    return userDataLoaded
        ? Scaffold(
            appBar: _buildAppBar(),
            body: TabBarView(
              controller: controller,
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: getProportionateScreenWidth(16),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: getProportionateScreenHeight(25)),
                        TextFormField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          onFieldSubmitted: _onSearchSubmitted,
                          decoration:
                              _buildFollowersAndFollowingSearchFieldInputDecoration(
                                context,
                              ),
                        ),
                        SizedBox(height: getProportionateScreenHeight(48)),
                      ],
                    ),
                  ),
                ),
                const Center(child: Text("Following")),
              ],
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
}

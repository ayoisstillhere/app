import 'dart:convert';

import 'package:app/features/chat/data/models/following_response_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;

import 'package:app/features/chat/domain/entities/following_response_entity.dart';

import '../../../../constants.dart';
import '../../../../services/auth_manager.dart';
import '../../../../size_config.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../widgets/chat_suggestion_tile.dart';
import 'group_chat_screen.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key, required this.currentUser});
  final UserEntity currentUser;

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  List<Following> allFollowing = []; // Store all following users
  bool isLoading = false;
  bool hasMore = true;
  int currentPage = 1;
  final int pageSize = 20; // Adjust based on your API
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _getFollowing();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!isLoading && hasMore) {
        _loadMore();
      }
    }
  }

  Future<void> _getFollowing() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final token = await AuthManager.getToken();
      final response = await http.get(
        Uri.parse(
          "$baseUrl/api/v1/user/${widget.currentUser.id}/following?page=$currentPage&limit=$pageSize",
        ),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final followingResponse = FollowingResponseModel.fromJson(
          jsonDecode(response.body),
        );

        setState(() {
          if (currentPage == 1) {
            allFollowing = followingResponse.following;
          } else {
            allFollowing.addAll(followingResponse.following);
          }

          // Check if there are more pages
          // Adjust this logic based on your API response structure
          hasMore = followingResponse.following.length == pageSize;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showErrorSnackBar(response.body);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('{"message": "Network error occurred"}');
    }
  }

  Future<void> _loadMore() async {
    currentPage++;
    await _getFollowing();
  }

  Future<void> _refreshData() async {
    currentPage = 1;
    hasMore = true;
    allFollowing.clear();
    await _getFollowing();
  }

  void _showErrorSnackBar(String responseBody) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          jsonDecode(
            responseBody,
          )['message'].toString().replaceAll(RegExp(r'\[|\]'), ''),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final iconColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kWhite
        : kBlack;
    final circleColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kGreyInputFillDark
        : Colors.transparent;
    final circleBorder =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kGreySearchInput
        : kGreyInputBorder;
    final dividerColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kGreyInputFillDark
        : kGreyInputBorder;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Messages",
          style: TextStyle(
            fontSize: getProportionateScreenHeight(24),
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: getProportionateScreenWidth(22)),
            child: SizedBox(
              height: getProportionateScreenHeight(24),
              width: getProportionateScreenWidth(24),
              child: InkWell(
                onTap: () {},
                child: SvgPicture.asset(
                  "assets/icons/edit.svg",
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  width: getProportionateScreenWidth(24),
                  height: getProportionateScreenHeight(24),
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: allFollowing.isEmpty && isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: getProportionateScreenHeight(30)),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: getProportionateScreenWidth(16),
                      ),
                      child: TextFormField(
                        decoration: _buildChatSearchFieldDecoration(context),
                      ),
                    ),
                    SizedBox(height: getProportionateScreenHeight(36)),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroupChatScreen(
                              followingResponse: FollowingResponse(
                                following: allFollowing,
                                pagination: Pagination(
                                  page: 0,
                                  limit: 0,
                                  totalCount: 0,
                                  totalPages: 0,
                                  hasMore: hasMore,
                                ),
                              ),
                              currentUser: widget.currentUser,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: getProportionateScreenWidth(30),
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: getProportionateScreenHeight(64),
                              width: getProportionateScreenWidth(64),
                              padding: EdgeInsets.symmetric(
                                horizontal: getProportionateScreenWidth(20),
                                vertical: getProportionateScreenHeight(20),
                              ),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: circleColor,
                                border: Border.all(
                                  color: circleBorder,
                                  width: 1.0,
                                ),
                              ),
                              child: SvgPicture.asset(
                                "assets/icons/users-round.svg",
                                colorFilter: ColorFilter.mode(
                                  iconColor,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            SizedBox(width: getProportionateScreenWidth(14)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Group Chat",
                                  style: TextStyle(
                                    fontSize: getProportionateScreenHeight(15),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  "Add multiple people",
                                  style: TextStyle(
                                    fontSize: getProportionateScreenHeight(12),
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: getProportionateScreenHeight(47)),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: getProportionateScreenWidth(18),
                      ),
                      child: Text(
                        "Suggested",
                        style: TextStyle(
                          fontSize: getProportionateScreenHeight(12),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: getProportionateScreenHeight(27)),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: allFollowing.length + (hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == allFollowing.length) {
                          // Show loading indicator at the bottom
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: getProportionateScreenWidth(18),
                          ),
                          child: ChatSuggestionTile(
                            dividerColor: dividerColor,
                            image: allFollowing[index].profileImage,
                            name: allFollowing[index].fullName,
                            handle: allFollowing[index].username,
                            isSelected: false,
                            currentUser: widget.currentUser,
                            userId: allFollowing[index].id,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  InputDecoration _buildChatSearchFieldDecoration(BuildContext context) {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(getProportionateScreenWidth(30)),
        borderSide: BorderSide(
          color: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? kGreySearchInput
              : kGreyInputBorder,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(getProportionateScreenWidth(30)),
        borderSide: BorderSide(
          color: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? kGreySearchInput
              : kGreyInputBorder,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(getProportionateScreenWidth(30)),
        borderSide: BorderSide(
          color: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? kGreySearchInput
              : kGreyInputBorder,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(getProportionateScreenWidth(30)),
        borderSide: BorderSide(
          color: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? kGreySearchInput
              : kGreyInputBorder,
        ),
      ),
      fillColor: MediaQuery.of(context).platformBrightness == Brightness.dark
          ? kGreySearchInput
          : null,
      filled: MediaQuery.of(context).platformBrightness == Brightness.dark,
      prefixIcon: Padding(
        padding: EdgeInsets.all(getProportionateScreenHeight(14)),
        child: Text(
          "To:",
          style: TextStyle(
            fontSize: getProportionateScreenHeight(12),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      hintText: "Search ",
      hintStyle: TextStyle(
        fontSize: getProportionateScreenHeight(13),
        fontWeight: FontWeight.w500,
        color: kGreyDarkInputBorder,
      ),
    );
  }
}

import 'dart:convert';

import 'package:app/features/home/presentation/widgets/post_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;

import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:app/features/home/data/models/post_response_model.dart';
import 'package:app/features/home/domain/entities/post_response_entity.dart';

import '../../../../constants.dart';
import '../../../../services/auth_manager.dart';
import '../../../../size_config.dart';

class PostDetailsScreen extends StatefulWidget {
  const PostDetailsScreen({
    super.key,
    required this.postId,
    required this.currentUser,
  });
  final String postId;
  final UserEntity currentUser;

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  Post? post;
  List<Comment> comments = []; // Changed to List to accumulate comments
  bool isPostLoaded = false;
  bool isLoadingComments = false;
  bool hasMoreComments = true;
  int currentPage = 1;
  String dropDownValue = "Most Liked";
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _getPost();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!isLoadingComments && hasMoreComments) {
        _loadMoreComments();
      }
    }
  }

  Future<void> _getPost() async {
    final token = await AuthManager.getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/api/v1/posts/${widget.postId}"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200) {
      post = PostModel.fromJson(jsonDecode(response.body)["post"]);
      await _getComments(); // Load first page of comments
      setState(() {
        isPostLoaded = true;
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

  Future<void> _getComments({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        comments.clear();
        currentPage = 1;
        hasMoreComments = true;
        isLoadingComments = true;
      });
    } else {
      setState(() {
        isLoadingComments = true;
      });
    }

    final token = await AuthManager.getToken();
    final response = await http.get(
      Uri.parse(
        "$baseUrl/api/v1/posts/${widget.postId}/comments?page=$currentPage&limit=10",
      ),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final commentsResponse = CommentsResponseModel.fromJson(responseData);

      setState(() {
        if (isRefresh) {
          comments = commentsResponse.comments;
        } else {
          comments.addAll(commentsResponse.comments);
        }

        // Check if there are more comments to load
        // Adjust this logic based on your API response structure
        hasMoreComments =
            commentsResponse.comments.length == 10; // Assuming 10 is the limit
        // Or if your API returns pagination info:
        // hasMoreComments = responseData['hasNextPage'] ?? false;
        // Or check total count vs current loaded count:
        // hasMoreComments = comments.length < (responseData['totalCount'] ?? 0);

        isLoadingComments = false;
      });
    } else {
      setState(() {
        isLoadingComments = false;
      });
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

  Future<void> _loadMoreComments() async {
    if (!hasMoreComments || isLoadingComments) return;

    currentPage++;
    await _getComments();
  }

  Future<void> _refreshComments() async {
    await _getComments(isRefresh: true);
  }

  void _onSortChanged(String? newValue) {
    if (newValue != null && newValue != dropDownValue) {
      setState(() {
        dropDownValue = newValue;
      });
      // Reset pagination and reload comments with new sorting
      _refreshComments();
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
                Navigator.pop(context);
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
      body: isPostLoaded
          ? RefreshIndicator(
              onRefresh: _refreshComments,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: getProportionateScreenHeight(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PostCard(
                        dividerColor: dividerColor,
                        iconColor: iconColor,
                        authorName: post!.author.fullName,
                        authorHandle: post!.author.username,
                        imageUrl: post!.author.profileImage,
                        postTime: post!.createdAt,
                        likes: post!.count.likes,
                        comments: post!.count.comments,
                        reposts: post!.count.reposts,
                        bookmarks: post!.count.saves,
                        content: post!.content,
                        pictures: post!.media,
                        currentUser: widget.currentUser,
                        postId: post!.id,
                        notClickable: true,
                        isLiked: post!.isLiked,
                        isReposted: post!.isReposted,
                        isSaved: post!.isSaved,
                      ),
                      SizedBox(height: getProportionateScreenHeight(11.09)),
                      Container(
                        padding: EdgeInsets.only(
                          left: getProportionateScreenWidth(21),
                        ),
                        child: DropdownButton<String>(
                          value: dropDownValue,
                          icon: null,
                          onChanged: _onSortChanged,
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
                        itemCount: comments.length + (hasMoreComments ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == comments.length) {
                            // Show loading indicator at the end
                            return Padding(
                              padding: EdgeInsets.all(
                                getProportionateScreenHeight(16),
                              ),
                              child: Center(
                                child: isLoadingComments
                                    ? CircularProgressIndicator()
                                    : SizedBox.shrink(),
                              ),
                            );
                          }

                          return PostCard(
                            dividerColor: dividerColor,
                            iconColor: iconColor,
                            imageUrl: comments[index].post.author.profileImage,
                            postTime: comments[index].post.createdAt,
                            likes: comments[index].post.count.likes,
                            comments: comments[index].post.count.comments,
                            reposts: comments[index].post.count.reposts,
                            bookmarks: comments[index].post.count.saves,
                            content: comments[index].post.content,
                            pictures: comments[index].post.media,
                            authorHandle: comments[index].post.author.username,
                            isReply: comments[index].post.isReply,
                            replyingToHandle: post!.author.username,
                            authorName: comments[index].post.author.fullName,
                            currentUser: widget.currentUser,
                            postId: comments[index].post.id,
                            isLiked: comments[index].isLiked,
                            isReposted: comments[index].isReposted,
                            isSaved: comments[index].isSaved,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

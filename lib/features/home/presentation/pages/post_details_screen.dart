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
  CommentsResponseEntity? comments;
  bool isPostLoaded = false;
  String dropDownValue = "Most Liked";

  @override
  void initState() {
    super.initState();
    _getPost();
  }

  Future<void> _getPost() async {
    final token = await AuthManager.getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/api/v1/posts/${widget.postId}"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200) {
      post = PostModel.fromJson(jsonDecode(response.body)["post"]);
      await _getComments();
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

  Future<void> _getComments() async {
    final token = await AuthManager.getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/api/v1/posts/${widget.postId}/comments"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200) {
      comments = CommentsResponseModel.fromJson(jsonDecode(response.body));
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
          ? Padding(
              padding: EdgeInsets.only(top: getProportionateScreenHeight(8)),
              child: SingleChildScrollView(
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
                      itemCount: comments!.comments.length,
                      itemBuilder: (context, index) {
                        return PostCard(
                          dividerColor: dividerColor,
                          iconColor: iconColor,
                          imageUrl: comments!
                              .comments[index]
                              .post
                              .author
                              .profileImage,
                          postTime: comments!.comments[index].post.createdAt,
                          likes: comments!.comments[index].post.count.likes,
                          comments:
                              comments!.comments[index].post.count.comments,
                          reposts: comments!.comments[index].post.count.reposts,
                          bookmarks: comments!.comments[index].post.count.saves,
                          content: comments!.comments[index].post.content,
                          pictures: comments!.comments[index].post.media,
                          authorHandle:
                              comments!.comments[index].post.author.username,
                          isReply: comments!.comments[index].post.isReply,
                          replyingToHandle: post!.author.username,
                          authorName:
                              comments!.comments[index].post.author.fullName,
                          currentUser: widget.currentUser,
                          postId: comments!.comments[index].post.id,
                          isLiked: comments!.comments[index].isLiked,
                          isReposted: comments!.comments[index].isReposted,
                          isSaved: comments!.comments[index].isSaved,
                        );
                      },
                    ),
                  ],
                ),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

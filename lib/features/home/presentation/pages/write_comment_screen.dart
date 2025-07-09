import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:app/components/social_text.dart';
import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:app/size_config.dart';

import '../../../../constants.dart';
import '../../../../services/auth_manager.dart';

class WriteCommentScreen extends StatefulWidget {
  const WriteCommentScreen({
    super.key,
    required this.currentUser,
    required this.postId,
    required this.authorProfileImage,
    required this.authorName,
    required this.media,
    required this.content,
    required this.createdAt,
  });
  final UserEntity currentUser;
  final String postId;
  final String authorProfileImage;
  final String authorName;
  final List<String> media;
  final String content;
  final DateTime createdAt;

  @override
  State<WriteCommentScreen> createState() => _WriteCommentScreenState();
}

class _WriteCommentScreenState extends State<WriteCommentScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Comment cannot be empty",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final token = await AuthManager.getToken();
      final response = await http.post(
        Uri.parse("$baseUrl/api/v1/posts/${widget.postId}/comment"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "content": _commentController.text.trim(),
          "parentId": widget.postId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          Navigator.pop(context, true); // Return true to indicate success
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text(
                "Comment posted successfully!",
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                jsonDecode(
                      response.body,
                    )['message']?.toString().replaceAll(RegExp(r'\[|\]'), '') ??
                    "Failed to post comment",
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "An error occurred. Please try again.",
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            "assets/icons/back_button.svg",
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            width: getProportionateScreenWidth(24),
            height: getProportionateScreenHeight(24),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Reply",
          style: TextStyle(
            fontSize: getProportionateScreenHeight(18),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: getProportionateScreenWidth(16)),
            child: TextButton(
              onPressed: _isLoading ? null : _submitComment,
              style: TextButton.styleFrom(
                backgroundColor: kAccentColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: getProportionateScreenWidth(16),
                  vertical: getProportionateScreenHeight(8),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    getProportionateScreenWidth(20),
                  ),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: getProportionateScreenWidth(16),
                      height: getProportionateScreenHeight(16),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      "Reply",
                      style: TextStyle(
                        fontSize: getProportionateScreenHeight(14),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Original Post
          Container(
            padding: EdgeInsets.all(getProportionateScreenWidth(16)),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: dividerColor, width: 1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Image
                Container(
                  height: getProportionateScreenHeight(40),
                  width: getProportionateScreenWidth(40),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: widget.authorProfileImage.isEmpty
                          ? NetworkImage(defaultAvatar)
                          : NetworkImage(widget.authorProfileImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: getProportionateScreenWidth(12)),
                // Post Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Author Info
                      Row(
                        children: [
                          Text(
                            widget.authorName,
                            style: TextStyle(
                              fontSize: getProportionateScreenHeight(14),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: getProportionateScreenWidth(4)),
                          Text(
                            "@${widget.authorName}",
                            style: TextStyle(
                              fontSize: getProportionateScreenHeight(12),
                              color: kProfileText,
                            ),
                          ),
                          SizedBox(width: getProportionateScreenWidth(4)),
                          Text(
                            "·",
                            style: TextStyle(
                              fontSize: getProportionateScreenHeight(12),
                              color: kProfileText,
                            ),
                          ),
                          SizedBox(width: getProportionateScreenWidth(4)),
                          Text(
                            _formatTime(widget.createdAt),
                            style: TextStyle(
                              fontSize: getProportionateScreenHeight(12),
                              color: kProfileText,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: getProportionateScreenHeight(8)),
                      // Post Content
                      SocialText(
                        text: widget.content,
                        baseStyle: Theme.of(context).textTheme.bodyMedium!
                            .copyWith(
                              fontSize: getProportionateScreenHeight(14),
                              fontWeight: FontWeight.w400,
                            ),
                      ),
                      SizedBox(height: getProportionateScreenHeight(8)),
                      // Media if exists
                      if (widget.media.isNotEmpty)
                        Container(
                          height: getProportionateScreenHeight(200),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              getProportionateScreenWidth(12),
                            ),
                            image: DecorationImage(
                              image: widget.media.first.isEmpty
                                  ? NetworkImage(defaultAvatar)
                                  : NetworkImage(widget.media.first),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Reply Section
          Expanded(
            child: Container(
              padding: EdgeInsets.all(getProportionateScreenWidth(16)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current User Profile Image
                  Container(
                    height: getProportionateScreenHeight(40),
                    width: getProportionateScreenWidth(40),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: widget.currentUser.profileImage.isEmpty
                            ? NetworkImage(defaultAvatar)
                            : NetworkImage(widget.currentUser.profileImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: getProportionateScreenWidth(12)),
                  // Comment Input
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Replying to @${widget.authorName}",
                          style: TextStyle(
                            fontSize: getProportionateScreenHeight(12),
                            color: kProfileText,
                          ),
                        ),
                        SizedBox(height: getProportionateScreenHeight(8)),
                        TextField(
                          controller: _commentController,
                          maxLines: null,
                          autofocus: true,
                          style: TextStyle(
                            fontSize: getProportionateScreenHeight(16),
                          ),
                          decoration: InputDecoration(
                            hintText: "Post your reply",
                            hintStyle: TextStyle(
                              fontSize: getProportionateScreenHeight(16),
                              color: kProfileText,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            fillColor: Colors.transparent,
                            filled: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return DateFormat('MMM d').format(dateTime);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}

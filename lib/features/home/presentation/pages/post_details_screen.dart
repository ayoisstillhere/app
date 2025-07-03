import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:app/features/home/domain/entities/post_response_entity.dart';

import '../../../../constants.dart';
import '../../../../size_config.dart';
import '../widgets/post_card.dart';
import '../widgets/reply_card.dart';

class PostDetailsScreen extends StatefulWidget {
  const PostDetailsScreen({
    super.key,
    required this.post,
    required this.currentUser,
  });
  final Post post;
  final UserEntity currentUser;

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  String dropDownValue = "Most Liked";
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
      body: Padding(
        padding: EdgeInsets.only(top: getProportionateScreenHeight(8)),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PostCard(
                dividerColor: dividerColor,
                iconColor: iconColor,
                authorName: widget.post.author.fullName,
                authorHandle: widget.post.author.username,
                imageUrl: widget.post.author.profileImage,
                postTime: widget.post.createdAt,
                likes: widget.post.count.likes,
                comments: widget.post.count.comments,
                reposts: widget.post.count.reposts,
                bookmarks: widget.post.count.saves,
                content: widget.post.content,
                pictures: widget.post.media,
                currentUser: widget.currentUser,
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
}

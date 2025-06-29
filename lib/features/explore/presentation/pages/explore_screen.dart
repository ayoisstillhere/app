import 'package:app/features/home/presentation/widgets/reply_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../constants.dart';
import '../../../../size_config.dart';
import '../widgets/follow_suggestions_list.dart';
import '../widgets/trending_topic.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: getProportionateScreenHeight(35)),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: getProportionateScreenWidth(16),
                ),
                child: Text(
                  "Explore",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: getProportionateScreenHeight(20),
                  ),
                ),
              ),
              SizedBox(height: getProportionateScreenHeight(16)),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: getProportionateScreenWidth(16),
                ),
                child: TextFormField(
                  decoration: _buildExploreSearchFieldInputDecoration(context),
                ),
              ),
              SizedBox(height: getProportionateScreenHeight(24)),
              FollowSuggestionsList(),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: getProportionateScreenWidth(16),
                ),
                child: Text(
                  "Trending",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: getProportionateScreenHeight(16),
                  ),
                ),
              ),
              SizedBox(height: getProportionateScreenHeight(23)),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var image in trendingImages)
                      Container(
                        width: getProportionateScreenWidth(159),
                        height: getProportionateScreenHeight(161),
                        margin: EdgeInsets.only(
                          right: getProportionateScreenWidth(10),
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            getProportionateScreenWidth(10),
                          ),
                          image: DecorationImage(
                            image: NetworkImage(image),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: getProportionateScreenHeight(52)),
              ReplyCard(
                dividerColor: dividerColor,
                iconColor: iconColor,
                replyerName: mockReplies.first["userName"],
                replyerHandle: mockReplies.first["handle"],
                imageUrl: mockReplies.first["userImage"],
                postTime: mockReplies.first["replyTime"],
                likes: mockReplies.first["likes"],
                comments: mockReplies.first["comments"],
                reposts: mockReplies.first["reposts"],
                bookmarks: mockReplies.first["bookmarks"],
                content: mockReplies.first["content"],
                authorHandle: mockReplies.first["parentPostId"],
              ),
              SizedBox(height: getProportionateScreenHeight(54)),
              Padding(
                padding: EdgeInsets.only(left: getProportionateScreenWidth(19)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    mockTrendingTopics.length,
                    (index) => Column(
                      children: [
                        TrendingTopic(
                          topic: mockTrendingTopics[index]["topic"],
                          postNumber: mockTrendingTopics[index]["postNumber"],
                        ),
                        SizedBox(height: getProportionateScreenWidth(16)),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: getProportionateScreenHeight(87)),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildExploreSearchFieldInputDecoration(
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

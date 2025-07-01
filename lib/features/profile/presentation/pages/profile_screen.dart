import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:app/features/profile/presentation/pages/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import 'package:app/components/social_text.dart';
import 'package:app/size_config.dart';

import '../../../../constants.dart';
import '../../../home/presentation/widgets/post_Card.dart';
import '../../../home/presentation/widgets/reply_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.iAmFollowing,
    required this.followsMe,
    required this.isVerified,
    this.isFromNav = false,
    required this.currentUser,
  });
  // final bool isMe;
  final bool iAmFollowing;
  final bool followsMe;
  final bool isVerified;
  final bool isFromNav;
  final UserEntity? currentUser;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController controller;
  bool canMessage = false;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
    if (!widget.currentUser!.isOwnProfile &&
        (widget.iAmFollowing || widget.followsMe)) {
      setState(() {
        canMessage = true;
      });
    }
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildHeader(iconColor),
                    SizedBox(height: getProportionateScreenHeight(8)),
                    Padding(
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
                                image: NetworkImage(
                                  widget.currentUser!.profileImage,
                                ),
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
                                    widget.currentUser!.fullName,
                                    style: TextStyle(
                                      fontSize: getProportionateScreenHeight(
                                        16,
                                      ),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (widget.isVerified)
                                    SvgPicture.asset(
                                      "assets/icons/verified.svg",
                                      height: getProportionateScreenHeight(
                                        19.14,
                                      ),
                                      width: getProportionateScreenWidth(19.14),
                                    ),
                                ],
                              ),
                              Text(
                                "@${widget.currentUser!.username}",
                                style: TextStyle(
                                  fontSize: getProportionateScreenHeight(13),
                                  color: kProfileText,
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                NumberFormat.compact().format(
                                  widget.currentUser!.followerCount,
                                ),
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
                          SizedBox(width: getProportionateScreenWidth(10)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                NumberFormat.compact().format(
                                  widget.currentUser!.followingCount,
                                ),
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
                        ],
                      ),
                    ),
                    SizedBox(height: getProportionateScreenHeight(18)),
                    Padding(
                      padding: EdgeInsets.only(
                        left: getProportionateScreenWidth(30),
                      ),
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
                                mockUsers[0]["location"],
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
                                'Since ${DateFormat('MMMM yyyy').format(widget.currentUser!.dateJoined)}',
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
                            text: widget.currentUser!.bio,
                            baseStyle: Theme.of(context).textTheme.bodyLarge!
                                .copyWith(
                                  fontSize: getProportionateScreenHeight(12),
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: getProportionateScreenHeight(18)),
                    Padding(
                      padding: canMessage
                          ? EdgeInsets.symmetric(
                              horizontal: getProportionateScreenWidth(20),
                            )
                          : EdgeInsets.symmetric(
                              horizontal: getProportionateScreenWidth(30),
                            ),
                      child: Row(
                        children: [
                          if (widget.currentUser!.isOwnProfile)
                            InkWell(
                              onTap: () {},
                              child: Container(
                                height: getProportionateScreenHeight(27),
                                width: canMessage
                                    ? getProportionateScreenWidth(158.5)
                                    : getProportionateScreenWidth(163.5),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1,
                                    color: kProfileText,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    getProportionateScreenWidth(10),
                                  ),
                                ),
                                child: Center(child: Text("Edit Profile")),
                              ),
                            ),
                          if (!widget.currentUser!.isOwnProfile &&
                              !widget.iAmFollowing &&
                              !widget.followsMe)
                            InkWell(
                              onTap: () {},
                              child: Container(
                                height: getProportionateScreenHeight(27),
                                width: canMessage
                                    ? getProportionateScreenWidth(158.5)
                                    : getProportionateScreenWidth(163.5),
                                decoration: BoxDecoration(
                                  color: kAccentColor,
                                  borderRadius: BorderRadius.circular(
                                    getProportionateScreenWidth(10),
                                  ),
                                ),
                                child: Center(child: Text("Follow")),
                              ),
                            ),
                          if (!widget.currentUser!.isOwnProfile &&
                              widget.iAmFollowing)
                            InkWell(
                              onTap: () {},
                              child: Container(
                                height: getProportionateScreenHeight(27),
                                width: canMessage
                                    ? getProportionateScreenWidth(158.5)
                                    : getProportionateScreenWidth(163.5),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1,
                                    color: kProfileText,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    getProportionateScreenWidth(10),
                                  ),
                                ),
                                child: Center(child: Text("Unfollow")),
                              ),
                            ),
                          if (!widget.currentUser!.isOwnProfile &&
                              widget.followsMe &&
                              !widget.iAmFollowing)
                            InkWell(
                              onTap: () {},
                              child: Container(
                                height: getProportionateScreenHeight(27),
                                width: canMessage
                                    ? getProportionateScreenWidth(158.5)
                                    : getProportionateScreenWidth(163.5),
                                decoration: BoxDecoration(
                                  color: kAccentColor,
                                  borderRadius: BorderRadius.circular(
                                    getProportionateScreenWidth(10),
                                  ),
                                ),
                                child: Center(child: Text("Follow Back")),
                              ),
                            ),
                          Spacer(),
                          InkWell(
                            onTap: () {},
                            child: Container(
                              height: getProportionateScreenHeight(27),
                              width: canMessage
                                  ? getProportionateScreenWidth(158.5)
                                  : getProportionateScreenWidth(163.5),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: kProfileText,
                                ),
                                borderRadius: BorderRadius.circular(
                                  getProportionateScreenWidth(10),
                                ),
                              ),
                              child: Center(child: Text("Share Profile")),
                            ),
                          ),
                          if (!widget.currentUser!.isOwnProfile &&
                              (widget.iAmFollowing || widget.followsMe))
                            Spacer(),
                          if (canMessage)
                            InkWell(
                              onTap: () {},
                              child: SvgPicture.asset(
                                "assets/icons/mail.svg",
                                height: getProportionateScreenHeight(24),
                                width: getProportionateScreenWidth(24),
                                colorFilter: ColorFilter.mode(
                                  kProfileText,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
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
            children: [
              ListView.builder(
                itemCount: mockReplies.length,
                itemBuilder: (context, index) {
                  final post = mockReplies[index];
                  return GestureDetector(
                    onTap: () {},
                    child: PostCard(
                      dividerColor: dividerColor,
                      iconColor: iconColor,
                      authorName: post["userName"],
                      authorHandle: post["handle"],
                      imageUrl: post["userImage"],
                      postTime: DateTime.now(),
                      likes: post["likes"],
                      comments: post["comments"],
                      reposts: post["reposts"],
                      bookmarks: post["bookmarks"],
                      content: post["content"],
                      pictures: post["pictures"],
                    ),
                  );
                },
              ),
              ListView.builder(
                itemCount: mockReplies.length,
                itemBuilder: (context, index) {
                  final reply = mockReplies[index];

                  return GestureDetector(
                    onTap: () {},
                    child: ReplyCard(
                      dividerColor: dividerColor,
                      iconColor: iconColor,
                      authorHandle: reply["parentPostId"],
                      imageUrl: reply["userImage"],
                      postTime: reply["replyTime"],
                      likes: reply["likes"],
                      comments: reply["comments"],
                      reposts: reply["reposts"],
                      bookmarks: reply["bookmarks"],
                      content: reply["content"],
                      pictures: reply["pictures"],
                      replyerName: reply["userName"],
                      replyerHandle: reply["handle"],
                    ),
                  );
                },
              ),
              Center(child: Text("Media")),
              ListView.builder(
                itemCount: mockReplies.length,
                itemBuilder: (context, index) {
                  final reply = mockReplies[index];

                  return GestureDetector(
                    onTap: () {},
                    child: ReplyCard(
                      dividerColor: dividerColor,
                      iconColor: iconColor,
                      authorHandle: reply["parentPostId"],
                      imageUrl: reply["userImage"],
                      postTime: reply["replyTime"],
                      likes: reply["likes"],
                      comments: reply["comments"],
                      reposts: reply["reposts"],
                      bookmarks: reply["bookmarks"],
                      content: reply["content"],
                      pictures: reply["pictures"],
                      replyerName: reply["userName"],
                      replyerHandle: reply["handle"],
                    ),
                  );
                },
              ),
              Center(child: Text("Saved")),
              Center(child: Text("Liked")),
            ],
          ),
        ),
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
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
            "https://static1.colliderimages.com/wordpress/wp-content/uploads/2022/08/Jujutsu-Kaisen.jpg",
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Row(
        children: [
          if (!widget.isFromNav)
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
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
            onTap: widget.currentUser!.isOwnProfile
                ? _onMyMoreButtonTap
                : _onMoreButtonTap,
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
        if (widget.iAmFollowing)
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
    if (selected == 'Unfollow' && mounted) {}
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
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../constants.dart';
import '../../../../size_config.dart';

class ChatDetailsScreen extends StatefulWidget {
  const ChatDetailsScreen({super.key});

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chat Details",
          style: TextStyle(
            fontSize: getProportionateScreenHeight(20),
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: getProportionateScreenWidth(16)),
            child: SizedBox(
              height: getProportionateScreenHeight(24),
              width: getProportionateScreenWidth(24),
              child: InkWell(
                onTap: () {},
                child: SvgPicture.asset(
                  "assets/icons/chat_phone.svg",
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  width: getProportionateScreenWidth(24),
                  height: getProportionateScreenHeight(24),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: getProportionateScreenWidth(16)),
            child: SizedBox(
              height: getProportionateScreenHeight(24),
              width: getProportionateScreenWidth(24),
              child: InkWell(
                onTap: () {},
                child: SvgPicture.asset(
                  "assets/icons/chat_video.svg",
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  width: getProportionateScreenWidth(24),
                  height: getProportionateScreenHeight(24),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: getProportionateScreenWidth(16)),
            child: SizedBox(
              height: getProportionateScreenHeight(24),
              width: getProportionateScreenWidth(24),
              child: InkWell(
                onTap: () {},
                child: SvgPicture.asset(
                  "assets/icons/chat_more-vertical.svg",
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  width: getProportionateScreenWidth(24),
                  height: getProportionateScreenHeight(24),
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(getProportionateScreenHeight(20)),
          child: Container(
            width: double.infinity,
            height: 1,
            color: dividerColor,
          ),
        ),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Center(
                child: Column(
                  children: [
                    SizedBox(height: getProportionateScreenHeight(32)),
                    Container(
                      height: getProportionateScreenHeight(60),
                      width: getProportionateScreenWidth(60),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(
                            "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=3000&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: getProportionateScreenHeight(19.5)),
                    Text(
                      "Ayodele",
                      style: TextStyle(
                        fontSize: getProportionateScreenHeight(24),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: getProportionateScreenHeight(22.5)),
                    Container(
                      height: getProportionateScreenHeight(58.98),
                      width: getProportionateScreenWidth(302),
                      padding: EdgeInsets.symmetric(
                        horizontal: getProportionateScreenWidth(37),
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: dividerColor),
                        color:
                            MediaQuery.of(context).platformBrightness ==
                                Brightness.dark
                            ? kBlackBg
                            : Colors.transparent,
                        boxShadow: [
                          BoxShadow(
                            color: kWhite.withValues(alpha: 0.05),
                            spreadRadius: 0,
                            blurRadius: 20,
                            offset: Offset(0, 8),
                            blurStyle: BlurStyle.normal,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                "assets/icons/chat_details_user-round.svg",
                                colorFilter: ColorFilter.mode(
                                  iconColor,
                                  BlendMode.srcIn,
                                ),
                                width: getProportionateScreenWidth(18.38),
                                height: getProportionateScreenHeight(18.38),
                              ),
                              SizedBox(
                                height: getProportionateScreenHeight(4.6),
                              ),
                              Text(
                                "Profile",
                                style: TextStyle(
                                  fontSize: getProportionateScreenHeight(11.49),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                "assets/icons/chat_details_bell.svg",
                                colorFilter: ColorFilter.mode(
                                  iconColor,
                                  BlendMode.srcIn,
                                ),
                                width: getProportionateScreenWidth(18.38),
                                height: getProportionateScreenHeight(18.38),
                              ),
                              SizedBox(
                                height: getProportionateScreenHeight(4.6),
                              ),
                              Text(
                                "Mute",
                                style: TextStyle(
                                  fontSize: getProportionateScreenHeight(11.49),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                "assets/icons/chat_block.svg",
                                colorFilter: ColorFilter.mode(
                                  iconColor,
                                  BlendMode.srcIn,
                                ),
                                width: getProportionateScreenWidth(18.38),
                                height: getProportionateScreenHeight(18.38),
                              ),
                              SizedBox(
                                height: getProportionateScreenHeight(4.6),
                              ),
                              Text(
                                "Block",
                                style: TextStyle(
                                  fontSize: getProportionateScreenHeight(11.49),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                "assets/icons/chat_report.svg",
                                colorFilter: ColorFilter.mode(
                                  iconColor,
                                  BlendMode.srcIn,
                                ),
                                width: getProportionateScreenWidth(18.38),
                                height: getProportionateScreenHeight(18.38),
                              ),
                              SizedBox(
                                height: getProportionateScreenHeight(4.6),
                              ),
                              Text(
                                "Report",
                                style: TextStyle(
                                  fontSize: getProportionateScreenHeight(11.49),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: getProportionateScreenHeight(35.02)),
                    Padding(
                      padding: EdgeInsetsGeometry.symmetric(
                        horizontal: getProportionateScreenWidth(27),
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: getProportionateScreenHeight(20),
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: dividerColor, width: 1.0),
                            bottom: BorderSide(color: dividerColor, width: 1.0),
                          ),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Theme",
                              style: TextStyle(
                                fontSize: getProportionateScreenHeight(15),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: getProportionateScreenHeight(26)),
                            Text(
                              "Dissapearing Messages",
                              style: TextStyle(
                                fontSize: getProportionateScreenHeight(15),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "Off",
                              style: TextStyle(
                                fontSize: getProportionateScreenHeight(13),
                                fontWeight: FontWeight.normal,
                                color: kProfileText,
                              ),
                            ),
                            SizedBox(height: getProportionateScreenHeight(26)),
                            Text(
                              "Move Chat",
                              style: TextStyle(
                                fontSize: getProportionateScreenHeight(15),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: getProportionateScreenHeight(37)),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  indicatorPadding: EdgeInsets.zero,
                  indicatorWeight: 3,
                  indicatorColor: kLightPurple,
                  controller: controller,
                  dividerColor: dividerColor,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w500),
                  unselectedLabelStyle: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w500),
                  tabs: [
                    Tab(
                      child: Text(
                        "Media",
                        style: TextStyle(
                          fontSize: getProportionateScreenHeight(15),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Tab(
                      child: Text(
                        "Files",
                        style: TextStyle(
                          fontSize: getProportionateScreenHeight(15),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Tab(
                      child: Text(
                        "Voice",
                        style: TextStyle(
                          fontSize: getProportionateScreenHeight(15),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: controller,
          children: [
            Center(child: Text("Media")),
            Center(child: Text("Files")),
            Center(child: Text("Voice")),
          ],
        ),
      ),
    );
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

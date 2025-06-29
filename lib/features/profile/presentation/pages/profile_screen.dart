import 'package:app/components/social_text.dart';
import 'package:app/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../../../../constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController controller;

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
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
                            "https://butwhytho.net/wp-content/uploads/2023/09/Gojo-Jujutsu-Kaisen-But-Why-Tho-2.jpg",
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
                              "Kenny Da Engine",
                              style: TextStyle(
                                fontSize: getProportionateScreenHeight(16),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SvgPicture.asset(
                              "assets/icons/verified.svg",
                              height: getProportionateScreenHeight(19.14),
                              width: getProportionateScreenWidth(19.14),
                            ),
                          ],
                        ),
                        Text(
                          "@kennydaengine",
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
                            mockUsers[0]["followers"],
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
                            mockUsers[0]["following"],
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
                padding: EdgeInsetsGeometry.only(
                  left: getProportionateScreenWidth(30),
                ),
                child: Column(
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
                          'Since ${mockUsers[0]["dateJoined"]}',
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
                      text: mockUsers[0]["bio"],
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
                padding: EdgeInsets.symmetric(
                  horizontal: getProportionateScreenWidth(30),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {},
                      child: Container(
                        height: getProportionateScreenHeight(27),
                        width: getProportionateScreenWidth(163.5),
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: kProfileText),
                          borderRadius: BorderRadius.circular(
                            getProportionateScreenWidth(10),
                          ),
                        ),
                        child: Center(child: Text("Edit Profile")),
                      ),
                    ),
                    Spacer(),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        height: getProportionateScreenHeight(27),
                        width: getProportionateScreenWidth(163.5),
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: kProfileText),
                          borderRadius: BorderRadius.circular(
                            getProportionateScreenWidth(10),
                          ),
                        ),
                        child: Center(child: Text("Share Profile")),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: getProportionateScreenHeight(18)),
              TabBar(
                controller: controller,
                tabAlignment: TabAlignment.start,
                isScrollable: true,
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
          InkWell(
            onTap: () {},
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
            onTap: () {},
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
}

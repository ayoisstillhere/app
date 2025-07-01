import 'dart:convert';

import 'package:app/features/auth/data/models/user_model.dart';
import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:app/features/chat/presentation/pages/chat_list_screen.dart';
import 'package:app/features/home/presentation/pages/home_screen.dart';
import 'package:app/features/profile/presentation/pages/profile_screen.dart';
import 'package:app/features/explore/presentation/pages/explore_screen.dart';
import 'package:app/services/auth_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../constants.dart';
import '../size_config.dart';
import 'package:http/http.dart' as http;

class NavPage extends StatefulWidget {
  const NavPage({super.key});

  @override
  State<NavPage> createState() => _NavPageState();
}

class _NavPageState extends State<NavPage> {
  int _page = 0;
  late PageController pageController;
  List<Widget> navPages = [
    HomeScreen(),
    ExploreScreen(),
    ChatListScreen(),
    ProfileScreen(
      isMe: true,
      iAmFollowing: false,
      followsMe: false,
      isVerified: true,
      isFromNav: true,
    ),
  ];
  late UserEntity currentUser;

  @override
  void initState() {
    pageController = PageController();
    super.initState();
    _getProfile();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void navigationTapped(int page) {
    if (page == 0) {
      final homeScreen = navPages[0] as HomeScreen;
      homeScreen.onHomeButtonPressed?.call();
    } else if (page == 1) {
      final exploreScreen = navPages[1] as ExploreScreen;
      exploreScreen.onExploreButtonPressed?.call();
    }
    pageController.jumpToPage(page);
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  Future<void> _getProfile() async {
    final token = await AuthManager.getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/api/v1/user/profile"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200) {
      currentUser = UserModel.fromJson(jsonDecode(response.body));
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
    return Scaffold(body: _navBody(context));
  }

  Scaffold _navBody(BuildContext context) {
    final dividerColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kGreyInputFillDark
        : kGreyInputBorder;
    final iconColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kWhite
        : kBlack;
    final bgColor = MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kBlackBg
        : kWhite;

    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        onPageChanged: onPageChanged,
        children: navPages,
      ),
      bottomNavigationBar: CupertinoTabBar(
        border: Border(top: BorderSide(color: dividerColor, width: 1)),
        activeColor: kLightPurple,
        // inactiveColor: ,
        currentIndex: _page,
        backgroundColor: bgColor,
        height: getProportionateScreenHeight(60),
        iconSize: getProportionateScreenHeight(24),
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/icons/home.svg",
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              width: getProportionateScreenWidth(24),
              height: getProportionateScreenHeight(24),
            ),
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/icons/search.svg",
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              width: getProportionateScreenWidth(24),
              height: getProportionateScreenHeight(24),
            ),
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/icons/message_icon.svg",
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              width: getProportionateScreenWidth(24),
              height: getProportionateScreenHeight(24),
            ),
          ),
          BottomNavigationBarItem(
            icon: Container(
              height: getProportionateScreenHeight(34),
              width: getProportionateScreenWidth(34),
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
          ),
        ],
        onTap: navigationTapped,
      ),
    );
  }
}

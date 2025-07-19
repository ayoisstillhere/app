import 'dart:convert';

import 'package:app/features/auth/data/models/user_model.dart';
import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:app/features/chat/presentation/pages/chat_list_screen.dart';
import 'package:app/features/chat/presentation/pages/incoming_call_screen.dart';
import 'package:app/features/chat/presentation/pages/incoming_livestream_screen.dart';
import 'package:app/features/home/presentation/pages/home_screen.dart';
import 'package:app/features/profile/presentation/pages/profile_screen.dart';
import 'package:app/features/explore/presentation/pages/explore_screen.dart';
import 'package:app/services/auth_manager.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../constants.dart';
import '../features/onboarding/presentation/pages/onboarding_screen.dart'
    show OnboardingScreen;
import '../services/secret_chat_encryption_service.dart';
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
  bool isUserLoaded = false;
  List<Widget> navPages = [];
  UserEntity? currentUser;

  @override
  void initState() {
    pageController = PageController();
    super.initState();
    _getProfile();
    navPages = [];
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message?.data['type'] == 'CALL_NOTIFICATION') {
        debugPrint('Got a call notification');
        _navigateToCallScreen(message!.data);
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data['type'] == 'CALL_NOTIFICATION') {
        debugPrint('Got a call notification');
        _navigateToCallScreen(message.data);
      }
      if (message.data['type'] == 'LIVE_STREAM_NOTIFICATION') {
        debugPrint('Got a live stream notification');
        _navigateToLiveStreamScreen(message.data);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data['type'] == 'CALL_NOTIFICATION') {
        debugPrint('Got a call notification');
        _navigateToCallScreen(message.data);
      }
    });
  }

  void _navigateToCallScreen(Map<String, dynamic> data) async {
    final UserEntity? user = await AuthManager.getCurrentUser();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IncomingCallScreen(
          callerName: data['initiatorName'],
          roomId: data['callId'],
          currentUser: user!,
          imageUrl: data['initiatorImage'],
        ),
      ),
    );
  }

  void _navigateToLiveStreamScreen(Map<String, dynamic> data) async {
    final UserEntity? user = await AuthManager.getCurrentUser();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IncomingLivestreamScreen(
          streamerName: data['initiatorFullName'],
          streamTitle: "${data['initiatorName']} Live Stream",
          roomId: data['liveStreamId'],
          currentUser: user!,
          imageUrl: data['initiatorProfileImage'],
        ),
      ),
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void navigationTapped(int page) {
    if (page == 1) {
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
      final UserEntity user = UserModel.fromJson(jsonDecode(response.body));
      navPages = [
        HomeScreen(currentUser: user),
        ExploreScreen(currentUser: user),
        ChatListScreen(currentUser: user),
        ProfileScreen(
          isVerified: true,
          isFromNav: true,
          userName: user.username,
          currentUser: user,
        ),
      ];
      setState(() {
        isUserLoaded = true;
        currentUser = user;
      });
      await SecretChatEncryptionService.storeCurrentUser(user);
    } else {
      if (response.statusCode == 401) {
        await AuthManager.logout();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const OnboardingScreen(
              title: "Connect Freely",
              subtitle:
                  "Share your thoughts, ideas, and moments — without limits",
              bgImage: "assets/images/Onboarding1.png",
              currentPage: 0,
            ),
          ),
          (route) => false,
        );
        return;
      }
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
    return Scaffold(
      body: isUserLoaded
          ? _navBody(context)
          : Center(child: CircularProgressIndicator()),
    );
  }

  Scaffold _navBody(BuildContext context) {
    final dividerColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kGreyInputFillDark
        : kGreyInputBorder;
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
            icon: _page == 0
                ? SvgPicture.asset(
                    "assets/icons/home_new.svg",
                    width: getProportionateScreenWidth(24),
                    height: getProportionateScreenHeight(24),
                  )
                : SvgPicture.asset(
                    "assets/icons/home_new_white.svg",
                    width: getProportionateScreenWidth(24),
                    height: getProportionateScreenHeight(24),
                  ),
          ),
          BottomNavigationBarItem(
            icon: _page == 1
                ? SvgPicture.asset(
                    "assets/icons/explore_new.svg",
                    width: getProportionateScreenWidth(24),
                    height: getProportionateScreenHeight(24),
                  )
                : SvgPicture.asset(
                    "assets/icons/explore_new_white.svg",
                    width: getProportionateScreenWidth(24),
                    height: getProportionateScreenHeight(24),
                  ),
          ),
          BottomNavigationBarItem(
            icon: _page == 2
                ? SvgPicture.asset(
                    "assets/icons/chat_new.svg",
                    width: getProportionateScreenWidth(24),
                    height: getProportionateScreenHeight(24),
                  )
                : SvgPicture.asset(
                    "assets/icons/chat_new_white.svg",
                    width: getProportionateScreenWidth(24),
                    height: getProportionateScreenHeight(24),
                  ),
          ),
          BottomNavigationBarItem(
            icon: Opacity(
              opacity: _page == 3 ? 1.0 : 0.5,
              child: Container(
                height: getProportionateScreenHeight(34),
                width: getProportionateScreenWidth(34),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: currentUser!.profileImage.isEmpty
                        ? NetworkImage(defaultAvatar)
                        : NetworkImage(currentUser!.profileImage),
                    fit: BoxFit.cover,
                  ),
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

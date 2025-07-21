import 'dart:async';
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
import 'package:stream_video_flutter/stream_video_flutter.dart';

import '../constants.dart';
import '../features/home/presentation/pages/post_details_screen.dart';
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
    _setupNotificationHandling();
  }

  void _setupNotificationHandling() {
    // Handle notification when app is launched from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleInitialMessage(message);
      }
    });

    // Handle notifications when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleForegroundMessage(message);
    });

    // Handle notifications when app is opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleBackgroundMessage(message);
    });
  }

  void _handleInitialMessage(RemoteMessage message) {
    debugPrint(
      'App opened from terminated state with message: ${message.data}',
    );

    final type = message.data['type'];

    switch (type) {
      case 'CALL_NOTIFICATION':
        // Always show call screen immediately for calls, even from terminated state
        _navigateToCallScreen(message.data);
        break;
      case 'LIVE_STREAM_NOTIFICATION':
        _navigateToLiveStreamScreen(message.data);
        break;
      case 'CHAT_NOTIFICATION':
        _navigateToChatScreen(message.data);
        break;
      case 'GENERAL_NOTIFICATION':
        _handleGeneralNotification(message.data);
        break;
      default:
        debugPrint('Unknown notification type: $type');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message received: ${message.data}');

    final type = message.data['type'];

    switch (type) {
      case 'CALL_NOTIFICATION':
        // Show incoming call UI immediately when app is open
        _navigateToCallScreen(message.data);
        break;
      case 'LIVE_STREAM_NOTIFICATION':
      case 'CHAT_NOTIFICATION':
      case 'GENERAL_NOTIFICATION':
        // Show custom in-app notification banner
        _showCustomNotificationBanner(message);
        break;
      default:
        debugPrint('Unknown notification type: $type');
    }
  }

  void _showCustomNotificationBanner(RemoteMessage message) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 10,
        right: 10,
        child: Dismissible(
          key: Key('notification_${DateTime.now().millisecondsSinceEpoch}'),
          direction: DismissDirection.up,
          onDismissed: (direction) {
            overlayEntry.remove();
          },
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kBlackBg,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: InkWell(
                onTap: () {
                  overlayEntry.remove();
                  // Navigate based on notification type
                  final type = message.data['type'];
                  switch (type) {
                    case 'LIVE_STREAM_NOTIFICATION':
                      _navigateToLiveStreamScreen(message.data);
                      break;
                    case 'CHAT_NOTIFICATION':
                      _navigateToChatScreen(message.data);
                      break;
                    case 'GENERAL_NOTIFICATION':
                      _handleGeneralNotification(message.data);
                      break;
                  }
                },
                child: Row(
                  children: [
                    Icon(Icons.notifications, color: kLightPurple),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            message.data['notificationMessage'] ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.white,
                      ),
                      onPressed: () => overlayEntry.remove(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Auto-remove after 5 seconds
    Timer(const Duration(seconds: 5), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    debugPrint('App opened from background with message: ${message.data}');

    final type = message.data['type'];

    switch (type) {
      case 'CALL_NOTIFICATION':
        _navigateToCallScreen(message.data);
        break;
      case 'LIVE_STREAM_NOTIFICATION':
        _navigateToLiveStreamScreen(message.data);
        break;
      case 'CHAT_NOTIFICATION':
        _navigateToChatScreen(message.data);
        break;
      case 'GENERAL_NOTIFICATION':
        _handleGeneralNotification(message.data);
        break;
      default:
        debugPrint('Unknown notification type: $type');
    }
  }

  void _handleGeneralNotification(Map<String, dynamic> data) async {
    final notificationTypeStr = data['notificationType'];
    if (notificationTypeStr == null) {
      debugPrint('General notification missing notificationType');
      return;
    }

    try {
      final notificationType = NotificationType.values.firstWhere(
        (e) => e.name == notificationTypeStr,
      );

      switch (notificationType) {
        case NotificationType.LIKE:
        case NotificationType.COMMENT:
        case NotificationType.REPLY:
        case NotificationType.REPOST:
        case NotificationType.MENTION:
          // Navigate to the specific post
          await _navigateToPost(data);
          break;
        case NotificationType.FOLLOW:
          // Navigate to the follower's profile
          _navigateToProfile(data);
          break;
        case NotificationType.LIVE:
          // Navigate to live stream
          _navigateToLiveStreamScreen(data);
          break;
      }
    } catch (e) {
      debugPrint('Unknown notification type: $notificationTypeStr');
    }
  }

  void _navigateToCallScreen(Map<String, dynamic> data) async {
    final UserEntity? user = await AuthManager.getCurrentUser();
    if (user == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IncomingCallScreen(
          callerName: data['initiatorName'] ?? data['callerName'] ?? 'Unknown',
          callId: data['callId'] ?? '',
          currentUser: user,
          imageUrl: data['initiatorImage'] ?? data['callerImage'] ?? '',
          callType: data['callType'] ?? "AUDIO",
        ),
      ),
    );
  }

  void _navigateToLiveStreamScreen(Map<String, dynamic> data) async {
    final UserEntity? user = await AuthManager.getCurrentUser();
    if (user == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IncomingLivestreamScreen(
          streamerName: data['initiatorFullName'] ?? 'Unknown',
          streamTitle:
              data['streamTitle'] ??
              "${data['initiatorFullName'] ?? 'Unknown'}'s Live Stream",
          liveStreamId: data['liveStreamId'] ?? data['streamId'] ?? '',
          currentUser: user,
          imageUrl:
              data['initiatorProfileImage'] ?? data['streamerImage'] ?? '',
          streamerUsername: data['initiatorUsername'] ?? '',
          isScreenshotAllowed: data['isScreenshotAllowed'] ?? true,
        ),
      ),
    );
  }

  void _navigateToChatScreen(Map<String, dynamic> data) async {
    final UserEntity? user = await AuthManager.getCurrentUser();
    if (user == null) return;

    // Navigate to specific chat or chat list
    final conversationId = data['conversationId'];
    final senderId = data['senderId'];

    if (conversationId != null && senderId != null) {
      // Navigate to specific chat - you'll need to implement this screen
      // For now, navigate to chat list
      _navigateToChatList();
    } else {
      _navigateToChatList();
    }
  }

  void _navigateToChatList() {
    // Navigate to chat tab
    setState(() {
      _page = 2;
    });
    pageController.jumpToPage(2);
  }

  Future<void> _navigateToPost(Map<String, dynamic> data) async {
    final postId = data['postId'];
    if (postId == null) {
      debugPrint('Post ID missing in notification data');
      return;
    }
    UserEntity? user = await AuthManager.getCurrentUser();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PostDetailsScreen(postId: postId!, currentUser: user!),
      ),
    );
  }

  void _navigateToProfile(Map<String, dynamic> data) {
    final userId = data['userId'];
    final userName = data['userName'];

    if (userId == null && userName == null) {
      debugPrint('User information missing in notification data');
      return;
    }

    // Navigate to the follower's profile
    // You'll need to implement profile navigation with user ID/username
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(
          isVerified: false,
          isFromNav: false,
          userName: userName ?? '',
          currentUser: currentUser!,
          // Add userId parameter if your ProfileScreen supports it
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

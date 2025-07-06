import 'package:flutter/material.dart';

// Color Constants
const kLightPurple = Color(0xFFAB9FF2);
const kDarkPurple = Color(0xFFAB9FF2);
// const kDarkPurple = Color(0xFF9500FF);
const kAccentColor = Color(0xFF6366F1);
const kWhite = Color(0xFFFFFFFF);
const kBlack = Color(0xFF000000);
const kBlackBg = Color(0xFF0A0A0A);
const kGreyInputBorder = Color(0xFFD5D7DA);
const kGreyFormSubtitle = Color(0xFF535862);
const kGreyFormLabel = Color(0xFF414651);
const kGreyFormHint = Color(0xFF717680);
const kGreyDarkInputBorder = Color(0xFF5B5B5B);
const kGreyInputFillDark = Color(0xFF2C2C2C);
const kGreyText = Color(0xFFD7D7D7);
const kGreenAccent = Color(0xFF22C55E);
const kGreyHandleText = Color(0xFFAAAAAA);
const kGreyTimeText = Color(0xFF858585);
const kGreySearchInput = Color(0xFF1F1F1F);
const kPrimPurple = Color(0xFF9500FF);
const kProfileText = Color(0xFF727272);
const kChatBubble = Color(0xFF373737);
const kChatBubbleGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  stops: [0.0, 1.0],
  colors: [Color(0xFF6366F1), Color(0xFF9500FF)],
);

// UI Constants
List<Map<String, dynamic>> settingsDetails = [
  {
    "title": "Account",
    "icon": "assets/icons/settings_account.svg",
    "subItems": [
      "Email/Phome Number",
      "Password",
      "Username",
      "Notification Settings",
    ],
  },
  {
    "title": "Privacy & Security",
    "icon": "assets/icons/settings_privacy.svg",
    "subItems": [
      "Privacy Controls",
      "Two-Step Verification",
      "Blocked Users",
      "Start Secret Chat Defaults",
    ],
  },
  {
    "title": "App Preferences",
    "icon": "assets/icons/settings_preferences.svg",
    "subItems": ["Theme", "Language & Region", "Push Notifications"],
  },
  {
    "title": "Support & Feedback",
    "icon": "assets/icons/settings_support.svg",
    "subItems": ["Terms & Privacy Policy", "Report a Problem", "Rate Us"],
  },
];

// API Constants
const String baseUrl = 'https://api.hiraofficial.com';
// ignore: constant_identifier_names
enum MessageType { TEXT, AUDIO, VIDEO, IMAGE, FILE }

// Test Constants
List<Map<String, dynamic>> mockNotifications = [
  {
    "userName": "John Doe",
    "action": "started following you",
    "time": "2h",
    "userImg":
        "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "isClickable": true,
    "buttonText": "Follow Back",
  },
  {
    "userName": "Jane Smith",
    "action": "liked your post",
    "time": "5h",
    "userImg":
        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "isClickable": true,
    "buttonText": "View Post",
  },
  {
    "userName": "Jane Smith",
    "action": "liked your post",
    "time": "5h",
    "userImg":
        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "isClickable": false,
  },
  {
    "userName": "Bob Johnson",
    "action": "commented on your post",
    "time": "12h",
    "userImg":
        "https://images.unsplash.com/photo-1519244703995-f4e0f30006d5?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "isClickable": true,
    "buttonText": "Join Live",
  },
  {
    "userName": "Bob Johnson",
    "action": "commented on your post",
    "time": "12h",
    "userImg":
        "https://images.unsplash.com/photo-1519244703995-f4e0f30006d5?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "isClickable": true,
    "buttonText": "Join Live",
  },
  {
    "userName": "Alice Brown",
    "action": "mentioned you in a post",
    "time": "1d",
    "userImg":
        "https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "isClickable": true,
    "buttonText": "View Post",
  },
  {
    "userName": "John Doe",
    "action": "started following you",
    "time": "2h",
    "userImg":
        "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "isClickable": false,
  },
  {
    "userName": "John Doe",
    "action": "started following you",
    "time": "2h",
    "userImg":
        "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "isClickable": true,
    "buttonText": "Follow Back",
  },
  {
    "userName": "Jane Smith",
    "action": "liked your post",
    "time": "5h",
    "userImg":
        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "isClickable": true,
    "buttonText": "View Post",
  },
  {
    "userName": "Jane Smith",
    "action": "liked your post",
    "time": "5h",
    "userImg":
        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "isClickable": false,
  },
  {
    "userName": "Bob Johnson",
    "action": "commented on your post",
    "time": "12h",
    "userImg":
        "https://images.unsplash.com/photo-1519244703995-f4e0f30006d5?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "isClickable": true,
    "buttonText": "Join Live",
  },
  {
    "userName": "Bob Johnson",
    "action": "commented on your post",
    "time": "12h",
    "userImg":
        "https://images.unsplash.com/photo-1519244703995-f4e0f30006d5?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "isClickable": true,
    "buttonText": "Join Live",
  },
  {
    "userName": "Alice Brown",
    "action": "mentioned you in a post",
    "time": "1d",
    "userImg":
        "https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "isClickable": true,
    "buttonText": "View Post",
  },
  {
    "userName": "John Doe",
    "action": "started following you",
    "time": "2h",
    "userImg":
        "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "isClickable": false,
  },
];

String formatDuration(DateTime from, DateTime to) {
  Duration diff = to.difference(from).abs();

  int hours = diff.inHours;
  int minutes = diff.inMinutes.remainder(60);
  int seconds = diff.inSeconds.remainder(60);

  List<String> parts = [];
  if (hours > 0) parts.add('${hours}h');
  if (minutes > 0) parts.add('${minutes}m');
  if (seconds > 0 || parts.isEmpty) parts.add('${seconds}s');

  return parts.join(' ');
}

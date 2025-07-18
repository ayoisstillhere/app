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
const kFollowerAndFollowingBorder = Color(0xFF939393);
const kFollowerAndFollowingFill = Color(0xFF1F1F1F);
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

const String defaultAvatar =
    "https://static.vecteezy.com/system/resources/previews/009/292/244/non_2x/default-avatar-icon-of-social-media-user-vector.jpg";

// API Constants
const String baseUrl = 'https://api.hiraofficial.com';

// ignore: constant_identifier_names
enum MessageType { TEXT, AUDIO, VIDEO, IMAGE, FILE }

// Enum to define field types
enum FieldType { name, email, bio, username, location }

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

// API keys
const String getStreamKey = "q25hn6c2zjg3";
const String getStreamSecret =
    "dsj4r4dcddeeakzqgnrdj8sdnsuqjz3c5m594ub9qugeekq7wbr8tr965qb7fbsp";


// ayodelefagbami@Ayodeles-MacBook-Air android % ./gradlew --stop           

// Stopping Daemon(s)
// 1 Daemon stopped
// ayodelefagbami@Ayodeles-MacBook-Air android % rm -rf android/.gradle     

// ayodelefagbami@Ayodeles-MacBook-Air android % rm -rf ~/.gradle/caches/  
// 8461
import 'package:flutter/material.dart';

import 'features/chat/data/models/chat_message_model.dart';

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

List<Map<String, dynamic>> mockListTile = [
  {
    "image":
        "https://static1.colliderimages.com/wordpress/wp-content/uploads/2022/08/Jujutsu-Kaisen.jpg",
    "name": "Frank Ocean",
    "handle": "frankocean",
    "lastMessage":
        "Hey, what's up? I saw your post on the new coffee shop downtown and I was wondering if you wanted to grab a cup of coffee together.",
    "unreadMessages": 3,
    "time": "2h",
  },
  {
    "image":
        "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "name": "John Doe",
    "handle": "johndoe",
    "lastMessage":
        "Hey, what's up? I saw your post on the new coffee shop downtown and I was wondering if you wanted to grab a cup of coffee together.",
    "unreadMessages": 1,
    "time": "30m",
  },
  {
    "image":
        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "name": "Jane Smith",
    "handle": "janesmith",
    "lastMessage":
        "Hey, I saw your post on the new coffee shop downtown and I was wondering if you wanted to grab a cup of coffee together.",
    "unreadMessages": 0,
    "time": "1h",
  },
  {
    "image":
        "https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "name": "Bob Johnson",
    "handle": "bobjohnson",
    "lastMessage":
        "Hey, I saw your post on the new coffee shop downtown and I was wondering if you wanted to grab a cup of coffee together.",
    "unreadMessages": 1,
    "time": "45m",
  },
  {
    "image":
        "https://static1.colliderimages.com/wordpress/wp-content/uploads/2022/08/Jujutsu-Kaisen.jpg",
    "name": "Frank Ocean",
    "handle": "frankocean",
    "lastMessage":
        "Hey, what's up? I saw your post on the new coffee shop downtown and I was wondering if you wanted to grab a cup of coffee together.",
    "unreadMessages": 3,
    "time": "2h",
  },
  {
    "image":
        "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "name": "John Doe",
    "handle": "johndoe",
    "lastMessage":
        "Hey, what's up? I saw your post on the new coffee shop downtown and I was wondering if you wanted to grab a cup of coffee together.",
    "unreadMessages": 1,
    "time": "30m",
  },
  {
    "image":
        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "name": "Jane Smith",
    "handle": "janesmith",
    "lastMessage":
        "Hey, I saw your post on the new coffee shop downtown and I was wondering if you wanted to grab a cup of coffee together.",
    "unreadMessages": 0,
    "time": "1h",
  },
  {
    "image":
        "https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "name": "Bob Johnson",
    "handle": "bobjohnson",
    "lastMessage":
        "Hey, I saw your post on the new coffee shop downtown and I was wondering if you wanted to grab a cup of coffee together.",
    "unreadMessages": 1,
    "time": "45m",
  },
];

List<ChatMessage> messages = [
  ChatMessage(
    id: '1',
    text: 'Hey! How are you doing?',
    isMe: false,
    timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    isRead: true,
  ),
  ChatMessage(
    id: '2',
    text: 'I\'m doing great! Just finished my workout 💪',
    isMe: true,
    timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
    isRead: true,
  ),
  ChatMessage(
    id: '3',
    text: 'That\'s awesome! What kind of workout did you do?',
    isMe: false,
    timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
    isRead: true,
  ),
  ChatMessage(
    id: '4',
    text:
        'Just some cardio and weight training. Been trying to stay consistent with it',
    isMe: true,
    timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
    isRead: true,
  ),
  ChatMessage(
    id: '5',
    text: 'Good for you! Consistency is key 🔥',
    isMe: false,
    timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
    isRead: true,
  ),
  ChatMessage(
    id: '1',
    text: 'Hey! How are you doing?',
    isMe: false,
    timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    isRead: true,
  ),
  ChatMessage(
    id: '2',
    text: 'I\'m doing great! Just finished my workout 💪',
    isMe: true,
    timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
    isRead: true,
  ),
  ChatMessage(
    id: '3',
    text: 'That\'s awesome! What kind of workout did you do?',
    isMe: false,
    timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
    isRead: true,
  ),
  ChatMessage(
    id: '4',
    text:
        'Just some cardio and weight training. Been trying to stay consistent with it',
    isMe: true,
    timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
    isRead: true,
  ),
  ChatMessage(
    id: '5',
    text: 'Good for you! Consistency is key 🔥',
    isMe: false,
    timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
    isRead: true,
  ),
  ChatMessage(
    id: '1',
    text: 'Hey! How are you doing?',
    isMe: false,
    timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    isRead: true,
  ),
  ChatMessage(
    id: '2',
    text: 'I\'m doing great! Just finished my workout 💪',
    isMe: true,
    timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
    isRead: true,
  ),
  ChatMessage(
    id: '3',
    text: 'That\'s awesome! What kind of workout did you do?',
    isMe: false,
    timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
    isRead: true,
  ),
  ChatMessage(
    id: '4',
    text:
        'Just some cardio and weight training. Been trying to stay consistent with it',
    isMe: true,
    timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
    isRead: true,
  ),
  ChatMessage(
    id: '5',
    text: 'Good for you! Consistency is key 🔥',
    isMe: false,
    timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
    isRead: true,
  ),
  ChatMessage(
    id: '2',
    text: 'I\'m doing great! Just finished my workout 💪',
    isMe: true,
    timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
    isRead: true,
  ),
  ChatMessage(
    id: '3',
    text: 'That\'s awesome! What kind of workout did you do?',
    isMe: false,
    timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
    isRead: true,
  ),
  ChatMessage(
    id: '4',
    text:
        'Just some cardio and weight training. Been trying to stay consistent with it',
    isMe: true,
    timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
    isRead: true,
  ),
  ChatMessage(
    id: '5',
    text: 'Good for you! Consistency is key 🔥',
    isMe: false,
    timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
    isRead: true,
  ),
];

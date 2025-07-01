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

// Test Constants
List<Map<String, dynamic>> mockPosts = [
  {
    "handle": "user1",
    "userName": "John Doe",
    "userImage":
        "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "postTime": "10m",
    "likes": 10,
    "comments": 5,
    "reposts": 2,
    "bookmarks": 1,
    "content":
        "Just tried the new café downtown with @themachine, and their caramel macchiato is a game changer! ☕️✨ #CoffeeLover",
    "pictures": [],
  },
  {
    "handle": "user2",
    "userName": "Jane Smith",
    "userImage":
        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "postTime": "1h",
    "likes": 8,
    "comments": 2,
    "reposts": 1,
    "bookmarks": 0,
    "content": "This is another sample post",
    "pictures": [
      "https://images.unsplash.com/photo-1471922694854-ff1b63b20054?q=80&w=1744&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    ],
  },
  {
    "handle": "user3",
    "userName": "Bob Johnson",
    "userImage":
        "https://plus.unsplash.com/premium_photo-1690407617542-2f210cf20d7e?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "postTime": "2h",
    "likes": 5,
    "comments": 1,
    "reposts": 0,
    "bookmarks": 2,
    "content":
        "Just visited the new bakery on Elm Street with @sweettooth, and their chocolate croissant is to die for! 🥐❤️ #PastryLover",
    "pictures": [
      "https://images.unsplash.com/photo-1471922694854-ff1b63b20054?q=80&w=1744&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      "https://images.unsplash.com/photo-1519046904884-53103b34b206?q=80&w=1740&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    ],
  },
  {
    "handle": "ayoisstillhere",
    "userName": "Ayodele Fagbami",
    "userImage":
        "https://plus.unsplash.com/premium_photo-1690407617542-2f210cf20d7e?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "postTime": "2h",
    "likes": 5,
    "comments": 1,
    "reposts": 0,
    "bookmarks": 2,
    "content":
        "Just visited the new bakery on Elm Street with @sweettooth, and their chocolate croissant is to die for! 🥐❤️ #PastryLover",
    "pictures": [
      "https://images.unsplash.com/photo-1471922694854-ff1b63b20054?q=80&w=1744&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      "https://images.unsplash.com/photo-1519046904884-53103b34b206?q=80&w=1740&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      "https://plus.unsplash.com/premium_photo-1690407617542-2f210cf20d7e?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    ],
  },
  {
    "handle": "user1",
    "userName": "John Doe",
    "userImage":
        "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "postTime": "10m",
    "likes": 10,
    "comments": 5,
    "reposts": 2,
    "bookmarks": 1,
    "content":
        "Just tried the new café downtown with @themachine, and their caramel macchiato is a game changer! ☕️✨ #CoffeeLover",
    "pictures": [],
  },
  {
    "handle": "user2",
    "userName": "Jane Smith",
    "userImage":
        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "postTime": "1h",
    "likes": 8,
    "comments": 2,
    "reposts": 1,
    "bookmarks": 0,
    "content": "This is another sample post",
    "pictures": [
      "https://images.unsplash.com/photo-1471922694854-ff1b63b20054?q=80&w=1744&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    ],
  },
  {
    "handle": "user3",
    "userName": "Bob Johnson",
    "userImage":
        "https://plus.unsplash.com/premium_photo-1690407617542-2f210cf20d7e?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "postTime": "2h",
    "likes": 5,
    "comments": 1,
    "reposts": 0,
    "bookmarks": 2,
    "content":
        "Just visited the new bakery on Elm Street with @sweettooth, and their chocolate croissant is to die for! 🥐❤️ #PastryLover",
    "pictures": [
      "https://images.unsplash.com/photo-1471922694854-ff1b63b20054?q=80&w=1744&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      "https://images.unsplash.com/photo-1519046904884-53103b34b206?q=80&w=1740&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    ],
  },
  {
    "handle": "ayoisstillhere",
    "userName": "Ayodele Fagbami",
    "userImage":
        "https://plus.unsplash.com/premium_photo-1690407617542-2f210cf20d7e?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "postTime": "2h",
    "likes": 5,
    "comments": 1,
    "reposts": 0,
    "bookmarks": 2,
    "content":
        "Just visited the new bakery on Elm Street with @sweettooth, and their chocolate croissant is to die for! 🥐❤️ #PastryLover",
    "pictures": [
      "https://images.unsplash.com/photo-1471922694854-ff1b63b20054?q=80&w=1744&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      "https://images.unsplash.com/photo-1519046904884-53103b34b206?q=80&w=1740&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      "https://plus.unsplash.com/premium_photo-1690407617542-2f210cf20d7e?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    ],
  },
  {
    "handle": "user1",
    "userName": "John Doe",
    "userImage":
        "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "postTime": "10m",
    "likes": 10,
    "comments": 5,
    "reposts": 2,
    "bookmarks": 1,
    "content":
        "Just tried the new café downtown with @themachine, and their caramel macchiato is a game changer! ☕️✨ #CoffeeLover",
    "pictures": [],
  },
  {
    "handle": "user2",
    "userName": "Jane Smith",
    "userImage":
        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "postTime": "1h",
    "likes": 8,
    "comments": 2,
    "reposts": 1,
    "bookmarks": 0,
    "content": "This is another sample post",
    "pictures": [
      "https://images.unsplash.com/photo-1471922694854-ff1b63b20054?q=80&w=1744&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    ],
  },
  {
    "handle": "user3",
    "userName": "Bob Johnson",
    "userImage":
        "https://plus.unsplash.com/premium_photo-1690407617542-2f210cf20d7e?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "postTime": "2h",
    "likes": 5,
    "comments": 1,
    "reposts": 0,
    "bookmarks": 2,
    "content":
        "Just visited the new bakery on Elm Street with @sweettooth, and their chocolate croissant is to die for! 🥐❤️ #PastryLover",
    "pictures": [
      "https://images.unsplash.com/photo-1471922694854-ff1b63b20054?q=80&w=1744&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      "https://images.unsplash.com/photo-1519046904884-53103b34b206?q=80&w=1740&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    ],
  },
];

List<Map<String, dynamic>> mockReplies = [
  {
    "handle": "neighborhood_guy",
    "userName": "Tom Williams",
    "userImage":
        "https://images.unsplash.com/photo-1519244703995-f4e0f30006d5?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "replyTime": "3h",
    "likes": 1,
    "comments": 1,
    "reposts": 0,
    "bookmarks": 0,
    "content":
        "Absolutely! Sci-fi has a way of transporting us to incredible worlds. Just finished \"Galactic Odyssey\" and I can't stop thinking about it! 🚀✨ #SciFiFan",
    "parentPostId": "JordanLee",
    "pictures": [],
  },
  {
    "handle": "coffeelover23",
    "userName": "Sarah Wilson",
    "userImage":
        "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "replyTime": "5m",
    "likes": 2,
    "comments": 1,
    "reposts": 0,
    "bookmarks": 0,
    "content":
        "Totally agree! Their barista knows how to make the perfect foam art too ☕️",
    "parentPostId": "user1_post_1",
    "pictures": [],
  },
  {
    "handle": "downtown_foodie",
    "userName": "Mike Chen",
    "userImage":
        "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "replyTime": "8m",
    "likes": 4,
    "comments": 2,
    "reposts": 0,
    "bookmarks": 0,
    "content":
        "I've been meaning to check that place out! Is their wifi good for working?",
    "parentPostId": "user1_post_1",
    "pictures": [],
  },
  {
    "handle": "themachine",
    "userName": "Alex Rodriguez",
    "userImage":
        "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "replyTime": "12m",
    "likes": 6,
    "comments": 2,
    "reposts": 0,
    "bookmarks": 0,
    "content":
        "Thanks for dragging me there! Already planning our next coffee adventure 😄",
    "parentPostId": "user1_post_1",
    "pictures": [],
  },
  {
    "handle": "naturelover88",
    "userName": "Emma Thompson",
    "userImage":
        "https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "replyTime": "45m",
    "likes": 1,
    "comments": 1,
    "reposts": 0,
    "bookmarks": 0,
    "content": "Beautiful shot! Where was this taken?",
    "parentPostId": "user2_post_1",
    "pictures": [],
  },
  {
    "handle": "photographer_pro",
    "userName": "David Kim",
    "userImage":
        "https://images.unsplash.com/photo-1507591064344-4c6ce005b128?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "replyTime": "50m",
    "likes": 3,
    "comments": 1,
    "reposts": 0,
    "bookmarks": 0,
    "content":
        "The lighting in this is perfect! What camera settings did you use?",
    "parentPostId": "user2_post_1",
    "pictures": [],
  },
  {
    "handle": "sweettooth",
    "userName": "Lisa Park",
    "userImage":
        "https://images.unsplash.com/photo-1489424731084-a5d8b219a5bb?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "replyTime": "1h",
    "likes": 8,
    "comments": 1,
    "reposts": 0,
    "bookmarks": 0,
    "content":
        "I'm still dreaming about that croissant! We need to go back tomorrow 🥐✨",
    "parentPostId": "user3_post_1",
    "pictures": [],
  },
  {
    "handle": "bakerybuff",
    "userName": "Carlos Martinez",
    "userImage":
        "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "replyTime": "1h",
    "likes": 2,
    "comments": 1,
    "reposts": 0,
    "bookmarks": 0,
    "content":
        "Elm Street bakery is amazing! Try their almond danish next time",
    "parentPostId": "user3_post_1",
    "pictures": [],
  },
  {
    "handle": "localfoodie",
    "userName": "Rachel Green",
    "userImage":
        "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "replyTime": "2h",
    "likes": 5,
    "comments": 1,
    "reposts": 0,
    "bookmarks": 0,
    "content":
        "Just added this to my weekend plans! Thanks for the recommendation 🙌",
    "parentPostId": "ayoisstillhere_post_1",
    "pictures": [],
  },
  {
    "handle": "pastry_chef_anna",
    "userName": "Anna Kowalski",
    "userImage":
        "https://images.unsplash.com/photo-1517841905240-472988babdf9?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "replyTime": "2h",
    "likes": 12,
    "comments": 1,
    "reposts": 0,
    "bookmarks": 0,
    "content":
        "As a pastry chef, I can confirm their technique is spot on! The lamination on those croissants is *chef's kiss* 👌",
    "parentPostId": "ayoisstillhere_post_1",
    "pictures": [
      "https://images.unsplash.com/photo-1471922694854-ff1b63b20054?q=80&w=1744&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    ],
  },
  {
    "handle": "neighborhood_guy",
    "userName": "Tom Williams",
    "userImage":
        "https://images.unsplash.com/photo-1519244703995-f4e0f30006d5?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "replyTime": "3h",
    "likes": 1,
    "comments": 1,
    "reposts": 0,
    "bookmarks": 0,
    "content": "Thanks for the recommendation! I'll definitely check it out",
    "parentPostId": "ayoisstillhere_post_1",
    "pictures": [],
  },
];

List<Map<String, dynamic>> mockFollowerSuggestions = [
  {
    "handle": "user1",
    "userName": "John Doe",
    "followers": 100,
    "bio": "Problem Solver, UI desinger. Tech boy",
    "userImage":
        "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
  },
  {
    "handle": "user2",
    "userName": "Jane Smith",
    "followers": 1000,
    "bio": "Web Developer, UI desinger. Tech girl",
    "userImage":
        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
  },
  {
    "handle": "user3",
    "userName": "Alice Johnson",
    "followers": 15000000,
    "bio": "",
    "userImage":
        "https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
  },
];

List trendingImages = [
  "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
  "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
  "https://images.unsplash.com/photo-1519244703995-f4e0f30006d5?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
  "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
  "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
  "https://images.unsplash.com/photo-1519244703995-f4e0f30006d5?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
  "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
  "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
  "https://images.unsplash.com/photo-1519244703995-f4e0f30006d5?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
];

List<Map<String, dynamic>> mockTrendingTopics = [
  {"topic": "Cristiano Ronaldo", "postNumber": 4000},
  {"topic": "Barcelona", "postNumber": 3000},
  {"topic": "Messi", "postNumber": 2000},
  {"topic": "Neymar", "postNumber": 1500},
  {"topic": "Manchester United", "postNumber": 1000},
];

List<String> mockRecentSearches = [
  "Flutter development",
  "Dart programming",
  "Mobile app design",
  "Firebase integration",
  "State management",
];

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

List<Map<String, dynamic>> mockUsers = [
  {
    "name": "Ayodele Fagbami",
    "handle": "ayoisstillhere",
    "followers": 15000,
    "following": 50,
    "isVerified": true,
    "profilePic":
        "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "profileBanner":
        "https://images.unsplash.com/photo-1519125323398-675f0ddb6638?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&w=1000&q=80",
    "bio":
        "Afrobeat in my viens. The machine has come | Follow other acccount @kedndaeng2_",
    "location": "Lagos, NG",
    "dateJoined": "May 2020",
  },
  {
    "name": "John Doe",
    "handle": "johndoe",
    "followers": 100,
    "following": 50,
    "isVerified": true,
    "profilePic":
        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "profileBanner":
        "https://images.unsplash.com/photo-1519046904835-819e6f3a52ec?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&w=1000&q=80",
    "bio": "Web Developer, UI desinger. Tech girl",
    "location": "New York, USA",
    "dateJoined": "December 2019",
  },
  {
    "name": "Jane Smith",
    "handle": "janesmith",
    "followers": 150,
    "following": 75,
    "isVerified": false,
    "profilePic":
        "https://images.unsplash.com/photo-1519244703995-f4e0f30006d5?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "profileBanner":
        "https://images.unsplash.com/photo-1519046904835-819e6f3a52ec?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&w=1000&q=80",
    "bio": "Software Engineer, UI desinger. Tech girl",
    "location": "London, UK",
    "dateJoined": "January 2020",
  },
  {
    "name": "Bob Johnson",
    "handle": "bobjohnson",
    "followers": 200,
    "following": 100,
    "isVerified": true,
    "profilePic":
        "https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "profileBanner":
        "https://images.unsplash.com/photo-1519125323398-675f0ddb6638?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&w=1000&q=80",
    "bio": "Data Scientist, UI desinger. Tech boy",
    "location": "San Francisco, USA",
    "dateJoined": "February 2019",
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

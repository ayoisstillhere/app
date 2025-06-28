import 'package:app/constants.dart';
import 'package:app/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../widgets/bottom_nav_bar.dart';
import '../widgets/post_Card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

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
];

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dividerColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kGreyInputFillDark
        : kGreyInputBorder;
    final iconColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kWhite
        : kBlack;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(getProportionateScreenHeight(100)),
        child: SafeArea(
          child: AppBar(
            leading: Padding(
              padding: EdgeInsets.only(left: getProportionateScreenWidth(16)),
              child: Container(
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
            bottom: TabBar(
              controller: controller,
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
                    width: getProportionateScreenWidth(143),
                    child: Center(child: Text("Recomended")),
                  ),
                ),
                Tab(
                  child: SizedBox(
                    width: getProportionateScreenWidth(143),
                    child: Center(child: Text("Following")),
                  ),
                ),
              ],
              indicatorSize: TabBarIndicatorSize.label,
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(
                  right: getProportionateScreenWidth(22),
                ),
                child: SizedBox(
                  height: getProportionateScreenHeight(24),
                  width: getProportionateScreenWidth(24),
                  child: InkWell(
                    onTap: () {},
                    child: SvgPicture.asset(
                      "assets/icons/bell.svg",
                      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: controller,
        children: [
          ListView.builder(
            itemCount: mockPosts.length,
            itemBuilder: (context, index) {
              final post = mockPosts[index];

              return PostCard(
                dividerColor: dividerColor,
                iconColor: iconColor,
                authorName: post["userName"],
                authorHandle: post["handle"],
                imageUrl: post["userImage"],
                postTime: post["postTime"],
                likes: post["likes"],
                comments: post["comments"],
                reposts: post["reposts"],
                bookmarks: post["bookmarks"],
                content: post["content"],
                pictures: post["pictures"],
              );
            },
          ),
          ListView.builder(
            itemCount: mockPosts.length,
            itemBuilder: (context, index) {
              final post = mockPosts[index];

              return PostCard(
                dividerColor: dividerColor,
                iconColor: iconColor,
                authorName: post["userName"],
                authorHandle: post["handle"],
                imageUrl: post["userImage"],
                postTime: post["postTime"],
                likes: post["likes"],
                comments: post["comments"],
                reposts: post["reposts"],
                bookmarks: post["bookmarks"],
                content: post["content"],
                pictures: post["pictures"],
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        shape: const CircleBorder(),
        mini: false,
        elevation: 0,
        highlightElevation: 0,
        backgroundColor: kLightPurple,
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavBar(
        dividerColor: dividerColor,
        iconColor: iconColor,
      ),
    );
  }
}

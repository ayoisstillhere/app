import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:app/constants.dart';
import 'package:app/size_config.dart';

import '../widgets/post_Card.dart';

// ignore: must_be_immutable
class HomeScreen extends StatefulWidget {
  HomeScreen({super.key, this.onHomeButtonPressed});
  VoidCallback? onHomeButtonPressed;

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

  bool isHome = true;
  Map<String, dynamic> selectedPost = {};
  String dropDownValue = "Most Liked";

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
    widget.onHomeButtonPressed = resetHome;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _toggleHome() {
    setState(() {
      isHome = !isHome;
    });
  }

  void resetHome() {
    if (!isHome) {
      setState(() {
        isHome = true;
      });
    }
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
      body: isHome
          ? Scaffold(
              appBar: _homeAppBar(context),
              body: TabBarView(
                controller: controller,
                children: [
                  ListView.builder(
                    itemCount: mockPosts.length,
                    itemBuilder: (context, index) {
                      final post = mockPosts[index];

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedPost = post;
                          });
                          _toggleHome();
                        },
                        child: PostCard(
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
                        ),
                      );
                    },
                  ),
                  ListView.builder(
                    itemCount: mockPosts.length,
                    itemBuilder: (context, index) {
                      final post = mockPosts[index];

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedPost = post;
                          });
                          _toggleHome();
                        },
                        child: PostCard(
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
                        ),
                      );
                    },
                  ),
                ],
              ),
            )
          : Scaffold(
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(
                  getProportionateScreenHeight(70),
                ),
                child: SafeArea(
                  child: AppBar(
                    title: Text(
                      "Post",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: getProportionateScreenHeight(20),
                      ),
                    ),
                    centerTitle: false,
                    shape: Border(
                      bottom: BorderSide(color: dividerColor, width: 1),
                    ),
                    leading: InkWell(
                      onTap: () {
                        _toggleHome();
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: getProportionateScreenHeight(12),
                          vertical: getProportionateScreenHeight(12),
                        ),
                        child: SvgPicture.asset(
                          "assets/icons/back_button.svg",
                          colorFilter: ColorFilter.mode(
                            iconColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              body: Padding(
                padding: EdgeInsets.only(top: getProportionateScreenHeight(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PostCard(
                      dividerColor: dividerColor,
                      iconColor: iconColor,
                      authorName: selectedPost["userName"],
                      authorHandle: selectedPost["handle"],
                      imageUrl: selectedPost["userImage"],
                      postTime: selectedPost["postTime"],
                      likes: selectedPost["likes"],
                      comments: selectedPost["comments"],
                      reposts: selectedPost["reposts"],
                      bookmarks: selectedPost["bookmarks"],
                      content: selectedPost["content"],
                      pictures: selectedPost["pictures"],
                    ),
                    SizedBox(height: getProportionateScreenHeight(11.09)),
                    Container(
                      padding: EdgeInsets.only(
                        left: getProportionateScreenWidth(21),
                      ),
                      child: DropdownButton<String>(
                        value: dropDownValue,
                        icon: null,
                        onChanged: (String? newValue) {
                          setState(() {
                            dropDownValue = newValue!;
                          });
                        },
                        underline: Container(),
                        items: <String>['Most Liked', 'Most Recent'].map((
                          String value,
                        ) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                fontSize: getProportionateScreenHeight(14),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
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
    );
  }

  PreferredSize _homeAppBar(BuildContext context) {
    final dividerColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kGreyInputFillDark
        : kGreyInputBorder;
    final iconColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kWhite
        : kBlack;
    return PreferredSize(
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
              padding: EdgeInsets.only(right: getProportionateScreenWidth(22)),
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
    );
  }
}

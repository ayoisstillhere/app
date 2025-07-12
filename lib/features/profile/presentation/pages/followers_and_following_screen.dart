import 'package:flutter/material.dart';

import '../../../../constants.dart';
import '../../../../services/auth_manager.dart';
import '../../../../size_config.dart';
import '../../../auth/domain/entities/user_entity.dart';

class FollowersAndFollowingScreen extends StatefulWidget {
  const FollowersAndFollowingScreen({super.key, required this.index});
  final int index;

  @override
  State<FollowersAndFollowingScreen> createState() =>
      _FollowersAndFollowingScreenState();
}

class _FollowersAndFollowingScreenState
    extends State<FollowersAndFollowingScreen>
    with SingleTickerProviderStateMixin {
  late TabController controller;
  bool userDataLoaded = false;
  late final UserEntity currentUser;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
    getCurrentUser();
  }

  Future<void> getCurrentUser() async {
    UserEntity? user = await AuthManager.getCurrentUser();
    if (mounted) {
      setState(() {
        currentUser = user!; // This line causes the error if called twice
        userDataLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return userDataLoaded
        ? Scaffold(appBar: _buildAppBar())
        : const Center(child: CircularProgressIndicator());
  }

  PreferredSizeWidget _buildAppBar() {
    final dividerColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kGreyInputFillDark
        : kGreyInputBorder;
    return AppBar(
      title: Text(
        "Profile",
        style: TextStyle(
          fontSize: getProportionateScreenHeight(24),
          fontWeight: FontWeight.w500,
        ),
      ),
      centerTitle: false,
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
              child: Center(
                child: Text("${currentUser.followerCount} followers"),
              ),
            ),
          ),
          Tab(
            child: SizedBox(
              width: getProportionateScreenWidth(143),
              child: Center(
                child: Text("${currentUser.followingCount} following"),
              ),
            ),
          ),
        ],
        indicatorSize: TabBarIndicatorSize.label,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../constants.dart';
import '../../../../services/auth_manager.dart';
import '../../../../size_config.dart';
import '../../../onboarding/presentation/pages/onboarding_screen.dart';
import '../widgets/settings_tile.dart';
import 'edit_profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
      appBar: AppBar(
        title: Text(
          "Settings",
          style: TextStyle(
            fontSize: getProportionateScreenHeight(24),
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: getProportionateScreenHeight(30)),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(16),
              ),
              child: TextFormField(
                decoration: _buildChatSearchFieldDecoration(context),
              ),
            ),
            SizedBox(height: getProportionateScreenHeight(34)),
            ...List.generate(
              settingsDetails.length,
              (index) => Column(
                children: [
                  InkWell(
                    onTap: () {
                      if (index == 0) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return EditProfileScreen();
                            },
                          ),
                        );
                      } else if (index == 1) {
                      } else if (index == 2) {}
                    },
                    child: SettingsTile(
                      dividerColor: dividerColor,
                      iconColor: iconColor,
                      settings: settingsDetails[index],
                    ),
                  ),
                  SizedBox(height: getProportionateScreenHeight(16)),
                ],
              ),
            ),
            SizedBox(height: getProportionateScreenHeight(32)),
            InkWell(
              onTap: () {
                AuthManager.logout();
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
              },
              child: Padding(
                padding: EdgeInsets.only(left: getProportionateScreenWidth(21)),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      "assets/icons/settings_log-out.svg",
                      width: getProportionateScreenWidth(24),
                      height: getProportionateScreenHeight(24),
                      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                    ),
                    SizedBox(width: getProportionateScreenWidth(10)),
                    Text(
                      "Log out",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: getProportionateScreenHeight(15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: getProportionateScreenHeight(24)),
            Padding(
              padding: EdgeInsets.only(left: getProportionateScreenWidth(21)),
              child: Row(
                children: [
                  SvgPicture.asset(
                    "assets/icons/settings_delete.svg",
                    width: getProportionateScreenWidth(24),
                    height: getProportionateScreenHeight(24),
                  ),
                  SizedBox(width: getProportionateScreenWidth(10)),
                  Text(
                    "Delete account",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: getProportionateScreenHeight(15),
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: getProportionateScreenHeight(102)),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildChatSearchFieldDecoration(BuildContext context) {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(getProportionateScreenWidth(30)),
        borderSide: BorderSide(
          color: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? kGreySearchInput
              : kGreyInputBorder,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(getProportionateScreenWidth(30)),
        borderSide: BorderSide(
          color: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? kGreySearchInput
              : kGreyInputBorder,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(getProportionateScreenWidth(30)),
        borderSide: BorderSide(
          color: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? kGreySearchInput
              : kGreyInputBorder,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(getProportionateScreenWidth(30)),
        borderSide: BorderSide(
          color: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? kGreySearchInput
              : kGreyInputBorder,
        ),
      ),
      fillColor: MediaQuery.of(context).platformBrightness == Brightness.dark
          ? kGreySearchInput
          : null,
      filled: MediaQuery.of(context).platformBrightness == Brightness.dark,
      prefixIcon: Padding(
        padding: EdgeInsets.all(getProportionateScreenHeight(14)),
        child: SvgPicture.asset(
          "assets/icons/search.svg",
          colorFilter: ColorFilter.mode(
            MediaQuery.of(context).platformBrightness == Brightness.dark
                ? kGreyDarkInputBorder
                : kGreyInputBorder,
            BlendMode.srcIn,
          ),
          width: getProportionateScreenWidth(14),
          height: getProportionateScreenHeight(14),
        ),
      ),
      hintText: "Search ",
      hintStyle: TextStyle(
        fontSize: getProportionateScreenHeight(13),
        fontWeight: FontWeight.w500,
        color: kGreyDarkInputBorder,
      ),
    );
  }
}

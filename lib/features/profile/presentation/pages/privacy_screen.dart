import 'package:app/features/profile/presentation/pages/two_step_verification_screen.dart';
import 'package:flutter/material.dart';

import '../../../../constants.dart';
import '../../../../size_config.dart';
import 'blocked_users_screen.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _isPrivateAccount = false;
  final bool _isTwoStepVerification = false;

  @override
  Widget build(BuildContext context) {
    final dividerColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kGreyInputFillDark
        : kGreyInputBorder;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Privacy & Control",
          style: TextStyle(
            fontSize: getProportionateScreenHeight(24),
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(getProportionateScreenHeight(20)),
          child: Container(
            width: double.infinity,
            height: 1,
            color: dividerColor,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: getProportionateScreenWidth(25),
            ),
            child: Column(
              children: [
                SizedBox(height: getProportionateScreenHeight(23)),

                // Private Account Toggle
                _buildToggleItem(
                  title: "Private Account",
                  value: _isPrivateAccount,
                  onChanged: (value) {
                    setState(() {
                      _isPrivateAccount = value;
                    });
                  },
                ),

                SizedBox(height: getProportionateScreenHeight(8)),

                _buildMenuItem(
                  title: "Two-Step Verification",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TwoStepVerificationScreen(),
                      ),
                    );
                  },
                ),

                SizedBox(height: getProportionateScreenHeight(23)),

                // Blocked Users Menu Item
                _buildMenuItem(
                  title: "Blocked Users",
                  onTap: () {
                    // Navigate to blocked users screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlockedUsersScreen(),
                      ),
                    );
                  },
                ),

                SizedBox(height: getProportionateScreenHeight(23)),

                // Secret chat Defaults Menu Item
                _buildMenuItem(
                  title: "Secret chat Defaults",
                  onTap: () {
                    // Navigate to secret chat defaults screen
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => SecretChatDefaultsScreen()));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleItem({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final textColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: getProportionateScreenHeight(18),
            fontWeight: FontWeight.w400,
            color: textColor,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: kLightPurple,
          inactiveThumbColor: Colors.grey,
          inactiveTrackColor: Colors.grey.withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildMenuItem({required String title, required VoidCallback onTap}) {
    final textColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        child: Text(
          title,
          style: TextStyle(
            fontSize: getProportionateScreenHeight(18),
            fontWeight: FontWeight.w400,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

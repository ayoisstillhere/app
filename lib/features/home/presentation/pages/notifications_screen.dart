import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../constants.dart';
import '../../../../size_config.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: getProportionateScreenHeight(37)),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
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
                        width: getProportionateScreenWidth(24),
                        height: getProportionateScreenHeight(24),
                      ),
                    ),
                  ),
                  Text(
                    "Notifications",
                    style: Theme.of(context).textTheme.displayMedium!.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: getProportionateScreenWidth(24),
                    ),
                  ),
                ],
              ),
              SizedBox(height: getProportionateScreenHeight(10)),
              Divider(thickness: 1, color: dividerColor),
              SizedBox(height: getProportionateScreenHeight(32)),
              Padding(
                padding: EdgeInsets.only(
                  left: getProportionateScreenWidth(20),
                  right: getProportionateScreenWidth(16),
                ),
                child: Column(
                  children: List.generate(mockNotifications.length, (index) {
                    return Column(
                      children: [
                        NotificationTile(
                          iconColor: iconColor,
                          username: mockNotifications[index]["userName"],
                          action: mockNotifications[index]["action"],
                          time: mockNotifications[index]["time"],
                          image: mockNotifications[index]["userImg"],
                          isClickable: mockNotifications[index]["isClickable"],
                          buttonText: mockNotifications[index]["buttonText"],
                        ),
                        SizedBox(height: getProportionateScreenHeight(25)),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

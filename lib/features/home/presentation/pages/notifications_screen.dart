import 'dart:convert';

import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:app/features/home/domain/entities/notifications_response_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;

import '../../../../constants.dart';
import '../../../../services/auth_manager.dart';
import '../../../../size_config.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, required this.currentUser});
  final UserEntity currentUser;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool isNotificationsLoaded = false;
  NotificationsResponseEntity? notificationsResponseEntity;

  @override
  void initState() {
    super.initState();
    _getNotifications();
  }

  Future<void> _getNotifications() async {
    final token = await AuthManager.getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/api/v1/notifications"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      notificationsResponseEntity = NotificationsResponseEntity.fromJson(
        jsonDecode(response.body),
      );
      setState(() {
        isNotificationsLoaded = true;
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: isNotificationsLoaded
              ? Column(
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
                          style: Theme.of(context).textTheme.displayMedium!
                              .copyWith(
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
                        children: List.generate(
                          notificationsResponseEntity!.notifications.length,
                          (index) {
                            return Column(
                              children: [
                                NotificationTile(
                                  iconColor: iconColor,
                                  username: notificationsResponseEntity!
                                      .notifications[index]
                                      .sender
                                      .username,
                                  action: notificationsResponseEntity!
                                      .notifications[index]
                                      .message,
                                  time: notificationsResponseEntity!
                                      .notifications[index]
                                      .createdAt,
                                  image: notificationsResponseEntity!
                                      .notifications[index]
                                      .sender
                                      .profileImage,
                                  isClickable:
                                      notificationsResponseEntity!
                                          .notifications[index]
                                          .post !=
                                      null,
                                  buttonText: "View",
                                  currentUser: widget.currentUser,
                                  postId: notificationsResponseEntity!
                                      .notifications[index]
                                      .post
                                      ?.id,
                                ),
                                SizedBox(
                                  height: getProportionateScreenHeight(25),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                )
              : const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

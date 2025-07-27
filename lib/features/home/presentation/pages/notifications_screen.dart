import 'dart:convert';

import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:app/features/home/domain/entities/notifications_response_entity.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;

import '../../../../components/default_button.dart';
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
  bool isLoadingMore = false;
  bool hasMoreData = true;
  List<Notification> notifications = [];
  int currentPage = 1;
  final int pageSize = 20; // Adjust based on your API

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _getNotifications();
    _scrollController.addListener(_onScroll);
    _markAllNotificationsRead();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (hasMoreData && !isLoadingMore) {
        _loadMoreNotifications();
      }
    }
  }

  Future<void> _getNotifications({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        currentPage = 1;
        notifications.clear();
        hasMoreData = true;
        isNotificationsLoaded = false;
      });
    }

    final token = await AuthManager.getToken();
    final response = await http.get(
      Uri.parse(
        "$baseUrl/api/v1/notifications?page=$currentPage&limit=$pageSize",
      ),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final notificationsResponse = NotificationsResponseEntity.fromJson(
        responseData,
      );

      setState(() {
        if (refresh) {
          notifications = notificationsResponse.notifications;
        } else {
          notifications.addAll(notificationsResponse.notifications);
        }

        // Check if there are more pages
        // Adjust this logic based on your API response structure
        hasMoreData = notificationsResponse.notifications.length == pageSize;
        // Alternative: if your API returns total count or hasMore field:
        // hasMoreData = responseData['hasMore'] ?? false;
        // or: hasMoreData = notifications.length < responseData['total'];

        isNotificationsLoaded = true;
        isLoadingMore = false;
      });
    } else {
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMoreNotifications() async {
    if (isLoadingMore || !hasMoreData) return;

    setState(() {
      isLoadingMore = true;
      currentPage++;
    });

    await _getNotifications();
  }

  Future<void> _refreshNotifications() async {
    await _getNotifications(refresh: true);
  }

  Future<void> _markAllNotificationsRead() async {
    final token = await AuthManager.getToken();
    final uri = Uri.parse('$baseUrl/api/v1/notifications/read-all');

    final response = await http.put(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      // Successfully marked all notifications as read
    } else {}
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
        child: RefreshIndicator(
          onRefresh: _refreshNotifications,
          child: isNotificationsLoaded
              ? notifications.isEmpty
                    ? EmptyState(
                        message: 'No notifications yet!',
                        buttonText: 'Go back',
                        onPressed: () => Navigator.pop(context),
                      )
                    : Column(
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
                                    horizontal: getProportionateScreenHeight(
                                      12,
                                    ),
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
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium!
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
                          Expanded(
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: EdgeInsets.symmetric(
                                horizontal: getProportionateScreenWidth(20),
                              ),
                              itemCount:
                                  notifications.length + (hasMoreData ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == notifications.length) {
                                  return _buildLoadingIndicator();
                                }

                                return Column(
                                  children: [
                                    NotificationTile(
                                      iconColor: iconColor,
                                      username:
                                          notifications[index].sender?.username,
                                      action: notifications[index].message,
                                      time: notifications[index].createdAt,
                                      image: notifications[index]
                                          .sender
                                          ?.profileImage,
                                      isClickable:
                                          notifications[index].post != null,
                                      buttonText: "View",
                                      currentUser: widget.currentUser,
                                      postId: notifications[index].post?.id,
                                    ),
                                    SizedBox(
                                      height: getProportionateScreenHeight(25),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      )
              : const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: getProportionateScreenHeight(20)),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.message,
    required this.buttonText,
    required this.onPressed,
    super.key,
  });

  final String message;
  final String buttonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, style: Theme.of(context).textTheme.displayMedium),
          SizedBox(height: getProportionateScreenHeight(32)),
          Padding(
            padding: EdgeInsetsGeometry.symmetric(
              horizontal: getProportionateScreenWidth(20),
            ),
            child: DefaultButton(text: buttonText, press: onPressed),
          ),
        ],
      ),
    );
  }
}

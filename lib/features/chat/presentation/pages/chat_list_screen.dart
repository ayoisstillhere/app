import 'dart:convert';

import 'package:app/features/chat/data/models/get_messages_response_model.dart';
import 'package:app/features/chat/domain/entities/get_messages_response_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:app/features/chat/presentation/pages/new_chat_screen.dart';
import 'package:http/http.dart' as http;

import '../../../../constants.dart';
import '../../../../services/auth_manager.dart';
import '../../../../size_config.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../widgets/chat_tile.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key, required this.currentUser});
  final UserEntity currentUser;

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  String selectedChip = "All";
  final List<Map<String, dynamic>> filters = [
    {'label': 'All', 'count': 15},
    {'label': 'Groups', 'count': 2},
    {'label': 'Secret', 'count': 2},
    {'label': 'Archived', 'count': 2},
    {'label': 'Requests', 'count': 2},
  ];
  GetMessagesResponse? allMessagesResponse;
  GetMessagesResponse? secretMessagesResponse;
  GetMessagesResponse? groupMessagesResponse;
  bool isAllMessagesLoaded = false;
  bool isSecretMessagesLoaded = false;

  @override
  void initState() {
    super.initState();
    _fetchConversations(false);
    _fetchConversations(true);
  }

  Future<void> _fetchConversations(bool isSecret) async {
    final token = await AuthManager.getToken();
    String url =
        '$baseUrl/api/v1/chat/conversations?page=1&limit=20&isSecret=$isSecret';

    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      isSecret
          ? secretMessagesResponse = GetMessagesResponseModel.fromJson(
              jsonDecode(response.body),
            )
          : allMessagesResponse = GetMessagesResponseModel.fromJson(
              jsonDecode(response.body),
            );

      setState(() {
        isSecret ? isSecretMessagesLoaded = true : isAllMessagesLoaded = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            jsonDecode(
              response.body,
            )['message'].toString().replaceAll(RegExp(r'\[|\]'), ''),
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
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
    final selectedChipColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kGreyInputFillDark
        : kLightPurple;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Messages",
          style: TextStyle(
            fontSize: getProportionateScreenHeight(24),
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: Container(),
        centerTitle: false,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: getProportionateScreenWidth(22)),
            child: SizedBox(
              height: getProportionateScreenHeight(24),
              width: getProportionateScreenWidth(24),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          NewChatScreen(currentUser: widget.currentUser),
                    ),
                  );
                },
                child: SvgPicture.asset(
                  "assets/icons/edit.svg",
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  width: getProportionateScreenWidth(24),
                  height: getProportionateScreenHeight(24),
                ),
              ),
            ),
          ),
        ],
      ),
      body: isSecretMessagesLoaded && isAllMessagesLoaded
          ? SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: getProportionateScreenHeight(17)),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: getProportionateScreenWidth(16),
                    ),
                    child: TextFormField(
                      decoration: _buildChatSearchFieldDecoration(context),
                    ),
                  ),
                  SizedBox(height: getProportionateScreenHeight(34)),
                  Padding(
                    padding: EdgeInsets.only(
                      left: getProportionateScreenWidth(17),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            "assets/icons/sliders-horizontal.svg",
                            colorFilter: ColorFilter.mode(
                              iconColor,
                              BlendMode.srcIn,
                            ),
                            width: getProportionateScreenWidth(15),
                            height: getProportionateScreenHeight(15),
                          ),
                          SizedBox(width: getProportionateScreenWidth(11)),
                          ...filters.map((filter) {
                            final isSelected = selectedChip == filter['label'];
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: GestureDetector(
                                onTap: () => setState(
                                  () => selectedChip = filter['label'],
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? selectedChipColor
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: dividerColor,
                                      width: isSelected ? 0 : 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        filter['label'],
                                        style: TextStyle(
                                          fontSize:
                                              getProportionateScreenHeight(12),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        filter['count'].toString(),
                                        style: TextStyle(
                                          color: Colors.greenAccent,
                                          fontSize:
                                              getProportionateScreenHeight(12),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: getProportionateScreenHeight(34)),
                  selectedChip == "All"
                      ? _buildListTileList(dividerColor, allMessagesResponse!)
                      : selectedChip == "Secret"
                      ? _buildListTileList(
                          dividerColor,
                          secretMessagesResponse!,
                        )
                      : selectedChip == "Group"
                      ? _buildListTileList(dividerColor, groupMessagesResponse!)
                      : Container(),
                ],
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildListTileList(
    Color dividerColor,
    GetMessagesResponse messageResponse,
  ) {
    groupMessagesResponse = GetMessagesResponse(
      conversations: allMessagesResponse!.conversations
          .where((conversation) => conversation.type == 'group')
          .toList(),
      pagination: Pagination(
        hasMore: allMessagesResponse!.pagination.hasMore,
        page: allMessagesResponse!.pagination.page,
        limit: allMessagesResponse!.pagination.limit,
        totalCount: allMessagesResponse!.pagination.totalCount,
        totalPages: allMessagesResponse!.pagination.totalPages,
      ),
    );
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: getProportionateScreenWidth(18),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: messageResponse.conversations.length,
        itemBuilder: (context, index) {
          return ChatTile(
            dividerColor: dividerColor,
            image: messageResponse.conversations[index].participants
                .firstWhere(
                  (participant) =>
                      participant.user.username != widget.currentUser.username,
                )
                .user
                .profileImage,
            name: messageResponse.conversations[index].type == "group"
                ? messageResponse.conversations[index].name!
                : messageResponse.conversations[index].participants
                      .firstWhere(
                        (participant) =>
                            participant.user.username !=
                            widget.currentUser.username,
                      )
                      .user
                      .fullName,
            lastMessage:
                messageResponse.conversations[index].lastMessage?.content ??
                "No message Yet",
            time:
                messageResponse.conversations[index].lastMessage?.createdAt ??
                DateTime.now(),
            unreadMessages: messageResponse.conversations[index].unreadCount,
          );
        },
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
      hintText: "Search",
    );
  }
}

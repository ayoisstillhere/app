import 'dart:convert';

import 'package:app/components/nav_page.dart';
import 'package:app/features/chat/data/models/get_media_response_model.dart';
import 'package:app/features/chat/domain/entities/get_media_response_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;

import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:app/features/chat/domain/entities/get_messages_response_entity.dart';

import '../../../../constants.dart';
import '../../../../services/auth_manager.dart';
import '../../../../size_config.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
import '../widgets/file_widget.dart';
import '../widgets/media_widget.dart';
import '../widgets/voice_widget.dart';

class ChatDetailsScreen extends StatefulWidget {
  const ChatDetailsScreen({
    super.key,
    required this.chatId,
    required this.chatName,
    required this.chatImage,
    this.chatHandle,
    required this.currentUser,
    required this.isGroup,
    required this.participants,
    required this.isConversationMuted,
  });
  final String chatId;
  final String chatName;
  final String chatImage;
  final String? chatHandle;
  final UserEntity currentUser;
  final bool isGroup;
  final List<Participant> participants;
  final bool isConversationMuted;

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController controller;

  GetMediaResponse? mediaResponse;
  GetMediaResponse? filesResponse;
  GetMediaResponse? voiceResponse;

  bool isMediaLoaded = false;
  bool isFilesLoaded = false;
  bool isVoiceLoaded = false;

  Future<void> _fetchMedia() async {
    final token = await AuthManager.getToken();
    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/v1/chat/conversations/${widget.chatId}/media?&mediaType=image',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      mediaResponse = GetMediaResponseModel.fromJson(jsonDecode(response.body));
      setState(() {
        isMediaLoaded = true;
      });
    }
  }

  Future<void> _fetchFiles() async {
    final token = await AuthManager.getToken();
    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/v1/chat/conversations/${widget.chatId}/files?&mediaType=file',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      filesResponse = GetMediaResponseModel.fromJson(jsonDecode(response.body));
      setState(() {
        isFilesLoaded = true;
      });
    }
  }

  Future<void> _fetchVoice() async {
    final token = await AuthManager.getToken();
    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/v1/chat/conversations/${widget.chatId}/audio?&mediaType=audio',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      voiceResponse = GetMediaResponseModel.fromJson(jsonDecode(response.body));
      setState(() {
        isVoiceLoaded = true;
      });
    }
  }

  void _onMute() async {
    final token = await AuthManager.getToken();
    await http.put(
      Uri.parse('$baseUrl/api/v1/chat/conversations/${widget.chatId}/mute'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  void _onUnmute() async {
    final token = await AuthManager.getToken();
    await http.put(
      Uri.parse('$baseUrl/api/v1/chat/conversations/${widget.chatId}/unmute'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  void _onAddParticipants(String userId) async {
    final token = await AuthManager.getToken();
    await http.post(
      Uri.parse(
        '$baseUrl/api/v1/chat/conversations/${widget.chatId}/add-participant',
      ),
      headers: {'Authorization': 'Bearer $token'},
      body: {'userId': userId},
    );
  }

  void _onLeaveGroup() async {
    final token = await AuthManager.getToken();
    await http.put(
      Uri.parse('$baseUrl/api/v1/chat/conversations/${widget.chatId}/leave'),
      headers: {'Authorization': 'Bearer $token'},
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const NavPage()),
    );
  }

  void _onArchive() async {
    final token = await AuthManager.getToken();
    await http.put(
      Uri.parse('$baseUrl/api/v1/chat/conversations/${widget.chatId}/archive'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  void _unArchive() async {
    final token = await AuthManager.getToken();
    await http.put(
      Uri.parse(
        '$baseUrl/api/v1/chat/conversations/${widget.chatId}/unarchive',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  void _onDelete() async {
    final token = await AuthManager.getToken();
    await http.put(
      Uri.parse('$baseUrl/api/v1/chat/conversations/${widget.chatId}/delete'),
      headers: {'Authorization': 'Bearer $token'},
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const NavPage()),
    );
  }

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
    _fetchMedia();
    _fetchFiles();
    _fetchVoice();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kWhite
        : kBlack;
    final dividerColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kGreyInputFillDark
        : kGreyInputBorder;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chat Details",
          style: TextStyle(
            fontSize: getProportionateScreenHeight(20),
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: getProportionateScreenWidth(16)),
            child: SizedBox(
              height: getProportionateScreenHeight(24),
              width: getProportionateScreenWidth(24),
              child: InkWell(
                onTap: () {},
                child: SvgPicture.asset(
                  "assets/icons/chat_phone.svg",
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  width: getProportionateScreenWidth(24),
                  height: getProportionateScreenHeight(24),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: getProportionateScreenWidth(16)),
            child: SizedBox(
              height: getProportionateScreenHeight(24),
              width: getProportionateScreenWidth(24),
              child: InkWell(
                onTap: () {},
                child: SvgPicture.asset(
                  "assets/icons/chat_video.svg",
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  width: getProportionateScreenWidth(24),
                  height: getProportionateScreenHeight(24),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: getProportionateScreenWidth(16)),
            child: SizedBox(
              height: getProportionateScreenHeight(24),
              width: getProportionateScreenWidth(24),
              child: InkWell(
                onTap: () {},
                child: SvgPicture.asset(
                  "assets/icons/chat_more-vertical.svg",
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  width: getProportionateScreenWidth(24),
                  height: getProportionateScreenHeight(24),
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(getProportionateScreenHeight(20)),
          child: Container(
            width: double.infinity,
            height: 1,
            color: dividerColor,
          ),
        ),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Center(
                child: Column(
                  children: [
                    SizedBox(height: getProportionateScreenHeight(32)),
                    Container(
                      height: getProportionateScreenHeight(60),
                      width: getProportionateScreenWidth(60),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(widget.chatImage),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: getProportionateScreenHeight(19.5)),
                    Text(
                      widget.chatName,
                      style: TextStyle(
                        fontSize: getProportionateScreenHeight(24),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: getProportionateScreenHeight(22.5)),
                    Container(
                      height: getProportionateScreenHeight(58.98),
                      width: getProportionateScreenWidth(302),
                      padding: EdgeInsets.symmetric(
                        horizontal: getProportionateScreenWidth(37),
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: dividerColor),
                        color:
                            MediaQuery.of(context).platformBrightness ==
                                Brightness.dark
                            ? kBlackBg
                            : Colors.transparent,
                        boxShadow: [
                          BoxShadow(
                            color: kWhite.withValues(alpha: 0.05),
                            spreadRadius: 0,
                            blurRadius: 20,
                            offset: Offset(0, 8),
                            blurStyle: BlurStyle.normal,
                          ),
                        ],
                      ),
                      child: widget.isGroup
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProfileScreen(
                                          isVerified: true,
                                          userName: widget.chatHandle!,
                                          currentUser: widget.currentUser,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        "assets/icons/group_add.svg",
                                        colorFilter: ColorFilter.mode(
                                          iconColor,
                                          BlendMode.srcIn,
                                        ),
                                        width: getProportionateScreenWidth(
                                          18.38,
                                        ),
                                        height: getProportionateScreenHeight(
                                          18.38,
                                        ),
                                      ),
                                      SizedBox(
                                        height: getProportionateScreenHeight(
                                          4.6,
                                        ),
                                      ),
                                      Text(
                                        "Add",
                                        style: TextStyle(
                                          fontSize:
                                              getProportionateScreenHeight(
                                                11.49,
                                              ),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () {},
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        "assets/icons/group_search.svg",
                                        colorFilter: ColorFilter.mode(
                                          iconColor,
                                          BlendMode.srcIn,
                                        ),
                                        width: getProportionateScreenWidth(
                                          18.38,
                                        ),
                                        height: getProportionateScreenHeight(
                                          18.38,
                                        ),
                                      ),
                                      SizedBox(
                                        height: getProportionateScreenHeight(
                                          4.6,
                                        ),
                                      ),
                                      Text(
                                        "Search",
                                        style: TextStyle(
                                          fontSize:
                                              getProportionateScreenHeight(
                                                11.49,
                                              ),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text(
                                            "Block User",
                                            style: TextStyle(
                                              fontSize:
                                                  getProportionateScreenHeight(
                                                    18,
                                                  ),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          content: Text(
                                            "Are you sure you want to Block Ayodele?",
                                            style: TextStyle(
                                              fontSize:
                                                  getProportionateScreenHeight(
                                                    16,
                                                  ),
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                "Cancel",
                                                style: TextStyle(
                                                  fontSize:
                                                      getProportionateScreenHeight(
                                                        16,
                                                      ),
                                                  fontWeight: FontWeight.normal,
                                                  color: kAccentColor,
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                "Block",
                                                style: TextStyle(
                                                  fontSize:
                                                      getProportionateScreenHeight(
                                                        16,
                                                      ),
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: InkWell(
                                    onTap: () {
                                      widget.isConversationMuted
                                          ? _onUnmute()
                                          : _onMute();
                                    },
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          "assets/icons/group_mute.svg",
                                          colorFilter: ColorFilter.mode(
                                            iconColor,
                                            BlendMode.srcIn,
                                          ),
                                          width: getProportionateScreenWidth(
                                            18.38,
                                          ),
                                          height: getProportionateScreenHeight(
                                            18.38,
                                          ),
                                        ),
                                        SizedBox(
                                          height: getProportionateScreenHeight(
                                            4.6,
                                          ),
                                        ),
                                        widget.isConversationMuted
                                            ? Text(
                                                "Unmute",
                                                style: TextStyle(
                                                  fontSize:
                                                      getProportionateScreenHeight(
                                                        11.49,
                                                      ),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              )
                                            : Text(
                                                "Mute",
                                                style: TextStyle(
                                                  fontSize:
                                                      getProportionateScreenHeight(
                                                        11.49,
                                                      ),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: _onLeaveGroup,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        "assets/icons/group_leave.svg",
                                        colorFilter: ColorFilter.mode(
                                          iconColor,
                                          BlendMode.srcIn,
                                        ),
                                        width: getProportionateScreenWidth(
                                          18.38,
                                        ),
                                        height: getProportionateScreenHeight(
                                          18.38,
                                        ),
                                      ),
                                      SizedBox(
                                        height: getProportionateScreenHeight(
                                          4.6,
                                        ),
                                      ),
                                      Text(
                                        "Leave",
                                        style: TextStyle(
                                          fontSize:
                                              getProportionateScreenHeight(
                                                11.49,
                                              ),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProfileScreen(
                                          isVerified: true,
                                          userName: widget.chatHandle!,
                                          currentUser: widget.currentUser,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        "assets/icons/chat_details_user-round.svg",
                                        colorFilter: ColorFilter.mode(
                                          iconColor,
                                          BlendMode.srcIn,
                                        ),
                                        width: getProportionateScreenWidth(
                                          18.38,
                                        ),
                                        height: getProportionateScreenHeight(
                                          18.38,
                                        ),
                                      ),
                                      SizedBox(
                                        height: getProportionateScreenHeight(
                                          4.6,
                                        ),
                                      ),
                                      Text(
                                        "Profile",
                                        style: TextStyle(
                                          fontSize:
                                              getProportionateScreenHeight(
                                                11.49,
                                              ),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    widget.isConversationMuted
                                        ? _onUnmute()
                                        : _onMute();
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        "assets/icons/chat_details_bell.svg",
                                        colorFilter: ColorFilter.mode(
                                          iconColor,
                                          BlendMode.srcIn,
                                        ),
                                        width: getProportionateScreenWidth(
                                          18.38,
                                        ),
                                        height: getProportionateScreenHeight(
                                          18.38,
                                        ),
                                      ),
                                      SizedBox(
                                        height: getProportionateScreenHeight(
                                          4.6,
                                        ),
                                      ),
                                      widget.isConversationMuted
                                          ? Text(
                                              "Unmute",
                                              style: TextStyle(
                                                fontSize:
                                                    getProportionateScreenHeight(
                                                      11.49,
                                                    ),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            )
                                          : Text(
                                              "Mute",
                                              style: TextStyle(
                                                fontSize:
                                                    getProportionateScreenHeight(
                                                      11.49,
                                                    ),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                    ],
                                  ),
                                ),

                                InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text(
                                            "Block User",
                                            style: TextStyle(
                                              fontSize:
                                                  getProportionateScreenHeight(
                                                    18,
                                                  ),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          content: Text(
                                            "Are you sure you want to Block Ayodele?",
                                            style: TextStyle(
                                              fontSize:
                                                  getProportionateScreenHeight(
                                                    16,
                                                  ),
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                "Cancel",
                                                style: TextStyle(
                                                  fontSize:
                                                      getProportionateScreenHeight(
                                                        16,
                                                      ),
                                                  fontWeight: FontWeight.normal,
                                                  color: kAccentColor,
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                "Block",
                                                style: TextStyle(
                                                  fontSize:
                                                      getProportionateScreenHeight(
                                                        16,
                                                      ),
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        "assets/icons/chat_block.svg",
                                        colorFilter: ColorFilter.mode(
                                          iconColor,
                                          BlendMode.srcIn,
                                        ),
                                        width: getProportionateScreenWidth(
                                          18.38,
                                        ),
                                        height: getProportionateScreenHeight(
                                          18.38,
                                        ),
                                      ),
                                      SizedBox(
                                        height: getProportionateScreenHeight(
                                          4.6,
                                        ),
                                      ),
                                      Text(
                                        "Block",
                                        style: TextStyle(
                                          fontSize:
                                              getProportionateScreenHeight(
                                                11.49,
                                              ),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () {},
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        "assets/icons/chat_report.svg",
                                        colorFilter: ColorFilter.mode(
                                          iconColor,
                                          BlendMode.srcIn,
                                        ),
                                        width: getProportionateScreenWidth(
                                          18.38,
                                        ),
                                        height: getProportionateScreenHeight(
                                          18.38,
                                        ),
                                      ),
                                      SizedBox(
                                        height: getProportionateScreenHeight(
                                          4.6,
                                        ),
                                      ),
                                      Text(
                                        "Report",
                                        style: TextStyle(
                                          fontSize:
                                              getProportionateScreenHeight(
                                                11.49,
                                              ),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ),
                    SizedBox(height: getProportionateScreenHeight(35.02)),
                    Padding(
                      padding: EdgeInsetsGeometry.symmetric(
                        horizontal: getProportionateScreenWidth(27),
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: getProportionateScreenHeight(20),
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: dividerColor, width: 1.0),
                            bottom: BorderSide(color: dividerColor, width: 1.0),
                          ),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Theme",
                              style: TextStyle(
                                fontSize: getProportionateScreenHeight(15),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: getProportionateScreenHeight(26)),
                            widget.isGroup
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Invite Link",
                                        style: TextStyle(
                                          fontSize:
                                              getProportionateScreenHeight(15),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        "https://t.me/FlutterChat",
                                        style: TextStyle(
                                          fontSize:
                                              getProportionateScreenHeight(13),
                                          fontWeight: FontWeight.normal,
                                          color: kProfileText,
                                        ),
                                      ),
                                    ],
                                  )
                                : InkWell(
                                    onTap: _onMoreButtonTap,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Dissapearing Messages",
                                          style: TextStyle(
                                            fontSize:
                                                getProportionateScreenHeight(
                                                  15,
                                                ),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          "Off",
                                          style: TextStyle(
                                            fontSize:
                                                getProportionateScreenHeight(
                                                  13,
                                                ),
                                            fontWeight: FontWeight.normal,
                                            color: kProfileText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                            SizedBox(height: getProportionateScreenHeight(26)),
                            widget.isGroup
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "People",
                                        style: TextStyle(
                                          fontSize:
                                              getProportionateScreenHeight(15),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(
                                        width: getProportionateScreenWidth(285),
                                        child: Text(
                                          widget.participants
                                              .map((e) => e.user.fullName)
                                              .join(", "),
                                          style: TextStyle(
                                            fontSize:
                                                getProportionateScreenHeight(
                                                  13,
                                                ),
                                            fontWeight: FontWeight.normal,
                                            color: kProfileText,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    "Move Chat",
                                    style: TextStyle(
                                      fontSize: getProportionateScreenHeight(
                                        15,
                                      ),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                            widget.isGroup
                                ? SizedBox(
                                    height: getProportionateScreenHeight(26),
                                  )
                                : Container(),

                            widget.isGroup
                                ? InkWell(
                                    onTap: _onDelete,
                                    child: Text(
                                      "Delete Group Chat",
                                      style: TextStyle(
                                        fontSize: getProportionateScreenHeight(
                                          15,
                                        ),
                                        fontWeight: FontWeight.w500,
                                        color: Colors.red,
                                      ),
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: getProportionateScreenHeight(37)),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  indicatorPadding: EdgeInsets.zero,
                  indicatorWeight: 3,
                  indicatorColor: kLightPurple,
                  controller: controller,
                  dividerColor: dividerColor,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: TextStyle(
                    fontSize: getProportionateScreenHeight(15),
                    fontWeight: FontWeight.w500,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: getProportionateScreenHeight(15),
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: [
                    Tab(
                      child: Text(
                        "Media",
                        style: TextStyle(
                          fontSize: getProportionateScreenHeight(15),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Tab(
                      child: Text(
                        "Files",
                        style: TextStyle(
                          fontSize: getProportionateScreenHeight(15),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Tab(
                      child: Text(
                        "Voice",
                        style: TextStyle(
                          fontSize: getProportionateScreenHeight(15),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: controller,
          children: [
            // Media Tab
            isMediaLoaded
                ? Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: getProportionateScreenWidth(14),
                      vertical: getProportionateScreenHeight(14),
                    ),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: getProportionateScreenWidth(5),
                        mainAxisSpacing: getProportionateScreenHeight(5),
                      ),
                      itemCount: mediaResponse!.data.length,
                      itemBuilder: (context, index) {
                        return MediaWidget(data: mediaResponse!.data[index]);
                      },
                    ),
                  )
                : Center(child: CircularProgressIndicator()),

            // Files Tab
            isFilesLoaded
                ? Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: getProportionateScreenWidth(14),
                      vertical: getProportionateScreenHeight(14),
                    ),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: getProportionateScreenWidth(10),
                        mainAxisSpacing: getProportionateScreenHeight(10),
                        childAspectRatio: 0.9, // Adjust for file display
                      ),
                      itemCount: filesResponse!.data.length,
                      itemBuilder: (context, index) {
                        return FileWidget(data: filesResponse!.data[index]);
                      },
                    ),
                  )
                : Center(child: CircularProgressIndicator()),

            // Voice Tab
            isVoiceLoaded
                ? Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: getProportionateScreenWidth(14),
                      vertical: getProportionateScreenHeight(14),
                    ),
                    child: ListView.separated(
                      itemCount: voiceResponse!.data.length,
                      separatorBuilder: (context, index) => Divider(),
                      itemBuilder: (context, index) {
                        return VoiceWidget(data: voiceResponse!.data[index]);
                      },
                    ),
                  )
                : Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  void _onMoreButtonTap() async {
    final selected = await showMenu<String>(
      context: context,
      color: Theme.of(context).scaffoldBackgroundColor,
      position: RelativeRect.fromLTRB(
        getProportionateScreenWidth(1000),
        getProportionateScreenHeight(400),
        getProportionateScreenWidth(10),
        getProportionateScreenHeight(300),
      ),
      items: [
        PopupMenuItem<String>(
          value: 'Off',
          child: Text(
            'Off',
            style: TextStyle(
              fontSize: getProportionateScreenWidth(15),
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'Once they have been seen',
          child: Text(
            'Once they have been seen',
            style: TextStyle(
              fontSize: getProportionateScreenWidth(15),
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: '24 hours',
          child: Text(
            '24 hours',
            style: TextStyle(
              fontSize: getProportionateScreenWidth(15),
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: '3 days',
          child: Text(
            '3 days',
            style: TextStyle(
              fontSize: getProportionateScreenWidth(15),
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: '7 days',
          child: Text(
            '7 days',
            style: TextStyle(
              fontSize: getProportionateScreenWidth(15),
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ],
    );
    if (selected == 'Off' && mounted) {}
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

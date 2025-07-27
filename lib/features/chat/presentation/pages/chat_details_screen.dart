import 'dart:convert';

import 'package:app/features/chat/presentation/pages/group_participants_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;

import 'package:app/components/nav_page.dart';
import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:app/features/chat/data/models/get_media_response_model.dart';
import 'package:app/features/chat/domain/entities/get_messages_response_entity.dart';

import '../../../../constants.dart';
import '../../../../services/auth_manager.dart';
import '../../../../size_config.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
import '../widgets/file_widget.dart';
import '../widgets/media_widget.dart';
import '../widgets/voice_widget.dart';
import 'change_group_details_screen.dart';

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
    required this.isConversationBlockedForMe,
  });
  final String chatId;
  final String chatName;
  final String chatImage;
  final String? chatHandle;
  final UserEntity currentUser;
  final bool isGroup;
  final List<Participant> participants;
  final bool isConversationMuted;
  final bool isConversationBlockedForMe;

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController controller;

  // Media pagination
  List<dynamic> mediaItems = [];
  bool isMediaLoaded = false;
  bool isMediaLoadingMore = false;
  bool hasMoreMedia = true;
  int mediaPage = 1;
  final int mediaLimit = 20;

  // Files pagination
  List<dynamic> filesItems = [];
  bool isFilesLoaded = false;
  bool isFilesLoadingMore = false;
  bool hasMoreFiles = true;
  int filesPage = 1;
  final int filesLimit = 15;

  // Voice pagination
  List<dynamic> voiceItems = [];
  bool isVoiceLoaded = false;
  bool isVoiceLoadingMore = false;
  bool hasMoreVoice = true;
  int voicePage = 1;
  final int voiceLimit = 10;

  // Scroll controllers for pagination
  final ScrollController _mediaScrollController = ScrollController();
  final ScrollController _filesScrollController = ScrollController();
  final ScrollController _voiceScrollController = ScrollController();

  bool isMuted = false;
  @override
  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);

    // Initialize scroll listeners
    _setupScrollListeners();

    // Initial data load
    _fetchMedia();
    _fetchFiles();
    _fetchVoice();
    if (mounted) {
      setState(() {
        isMuted = widget.isConversationMuted;
      });
    }
  }

  void _setupScrollListeners() {
    _mediaScrollController.addListener(() {
      if (_mediaScrollController.position.pixels ==
          _mediaScrollController.position.maxScrollExtent) {
        if (!isMediaLoadingMore && hasMoreMedia) {
          _loadMoreMedia();
        }
      }
    });

    _filesScrollController.addListener(() {
      if (_filesScrollController.position.pixels ==
          _filesScrollController.position.maxScrollExtent) {
        if (!isFilesLoadingMore && hasMoreFiles) {
          _loadMoreFiles();
        }
      }
    });

    _voiceScrollController.addListener(() {
      if (_voiceScrollController.position.pixels ==
          _voiceScrollController.position.maxScrollExtent) {
        if (!isVoiceLoadingMore && hasMoreVoice) {
          _loadMoreVoice();
        }
      }
    });
  }

  Future<void> _fetchMedia({bool loadMore = false}) async {
    if (loadMore) {
      setState(() => isMediaLoadingMore = true);
    }

    final token = await AuthManager.getToken();
    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/v1/chat/conversations/${widget.chatId}/media?mediaType=image&page=$mediaPage&limit=$mediaLimit',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final mediaResponse = GetMediaResponseModel.fromJson(
        jsonDecode(response.body),
      );

      setState(() {
        if (loadMore) {
          mediaItems.addAll(mediaResponse.data);
          isMediaLoadingMore = false;
        } else {
          mediaItems = mediaResponse.data;
          isMediaLoaded = true;
        }

        // Check if there are more items
        hasMoreMedia = mediaResponse.data.length == mediaLimit;

        if (loadMore) {
          mediaPage++;
        }
      });
    } else {
      setState(() {
        if (loadMore) {
          isMediaLoadingMore = false;
        } else {
          isMediaLoaded = true;
        }
      });
    }
  }

  Future<void> _fetchFiles({bool loadMore = false}) async {
    if (loadMore) {
      setState(() => isFilesLoadingMore = true);
    }

    final token = await AuthManager.getToken();
    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/v1/chat/conversations/${widget.chatId}/files?mediaType=file&page=$filesPage&limit=$filesLimit',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final filesResponse = GetMediaResponseModel.fromJson(
        jsonDecode(response.body),
      );

      setState(() {
        if (loadMore) {
          filesItems.addAll(filesResponse.data);
          isFilesLoadingMore = false;
        } else {
          filesItems = filesResponse.data;
          isFilesLoaded = true;
        }

        hasMoreFiles = filesResponse.data.length == filesLimit;

        if (loadMore) {
          filesPage++;
        }
      });
    } else {
      setState(() {
        if (loadMore) {
          isFilesLoadingMore = false;
        } else {
          isFilesLoaded = true;
        }
      });
    }
  }

  Future<void> _fetchVoice({bool loadMore = false}) async {
    if (loadMore) {
      setState(() => isVoiceLoadingMore = true);
    }

    final token = await AuthManager.getToken();
    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/v1/chat/conversations/${widget.chatId}/audio?mediaType=audio&page=$voicePage&limit=$voiceLimit',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final voiceResponse = GetMediaResponseModel.fromJson(
        jsonDecode(response.body),
      );

      setState(() {
        if (loadMore) {
          voiceItems.addAll(voiceResponse.data);
          isVoiceLoadingMore = false;
        } else {
          voiceItems = voiceResponse.data;
          isVoiceLoaded = true;
        }

        hasMoreVoice = voiceResponse.data.length == voiceLimit;

        if (loadMore) {
          voicePage++;
        }
      });
    } else {
      setState(() {
        if (loadMore) {
          isVoiceLoadingMore = false;
        } else {
          isVoiceLoaded = true;
        }
      });
    }
  }

  void _loadMoreMedia() {
    if (hasMoreMedia && !isMediaLoadingMore) {
      mediaPage++;
      _fetchMedia(loadMore: true);
    }
  }

  void _loadMoreFiles() {
    if (hasMoreFiles && !isFilesLoadingMore) {
      filesPage++;
      _fetchFiles(loadMore: true);
    }
  }

  void _loadMoreVoice() {
    if (hasMoreVoice && !isVoiceLoadingMore) {
      voicePage++;
      _fetchVoice(loadMore: true);
    }
  }

  // Add refresh functionality
  Future<void> _refreshMedia() async {
    setState(() {
      mediaPage = 1;
      hasMoreMedia = true;
      mediaItems.clear();
      isMediaLoaded = false;
    });
    await _fetchMedia();
  }

  Future<void> _refreshFiles() async {
    setState(() {
      filesPage = 1;
      hasMoreFiles = true;
      filesItems.clear();
      isFilesLoaded = false;
    });
    await _fetchFiles();
  }

  Future<void> _refreshVoice() async {
    setState(() {
      voicePage = 1;
      hasMoreVoice = true;
      voiceItems.clear();
      isVoiceLoaded = false;
    });
    await _fetchVoice();
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: EdgeInsets.all(16),
      alignment: Alignment.center,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(kLightPurple),
      ),
    );
  }

  Widget _buildMediaTab() {
    if (!isMediaLoaded) {
      return Center(child: CircularProgressIndicator());
    }

    if (mediaItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No media found',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshMedia,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: getProportionateScreenWidth(14),
          vertical: getProportionateScreenHeight(14),
        ),
        child: GridView.builder(
          controller: _mediaScrollController,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: getProportionateScreenWidth(5),
            mainAxisSpacing: getProportionateScreenHeight(5),
          ),
          itemCount: mediaItems.length + (isMediaLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == mediaItems.length) {
              return _buildLoadingIndicator();
            }
            return MediaWidget(data: mediaItems[index]);
          },
        ),
      ),
    );
  }

  Widget _buildFilesTab() {
    if (!isFilesLoaded) {
      return Center(child: CircularProgressIndicator());
    }

    if (filesItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No files found',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshFiles,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: getProportionateScreenWidth(14),
          vertical: getProportionateScreenHeight(14),
        ),
        child: GridView.builder(
          controller: _filesScrollController,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: getProportionateScreenWidth(10),
            mainAxisSpacing: getProportionateScreenHeight(10),
            childAspectRatio: 0.9,
          ),
          itemCount: filesItems.length + (isFilesLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == filesItems.length) {
              return _buildLoadingIndicator();
            }
            return FileWidget(data: filesItems[index]);
          },
        ),
      ),
    );
  }

  Widget _buildVoiceTab() {
    if (!isVoiceLoaded) {
      return Center(child: CircularProgressIndicator());
    }

    if (voiceItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mic_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No voice messages found',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshVoice,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: getProportionateScreenWidth(14),
          vertical: getProportionateScreenHeight(14),
        ),
        child: ListView.separated(
          controller: _voiceScrollController,
          itemCount: voiceItems.length + (isVoiceLoadingMore ? 1 : 0),
          separatorBuilder: (context, index) => Divider(),
          itemBuilder: (context, index) {
            if (index == voiceItems.length) {
              return _buildLoadingIndicator();
            }
            return VoiceWidget(data: voiceItems[index]);
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    _mediaScrollController.dispose();
    _filesScrollController.dispose();
    _voiceScrollController.dispose();
    super.dispose();
  }

  // ... [Rest of your existing methods remain the same]
  void _onMute() async {
    final token = await AuthManager.getToken();
    await http.put(
      Uri.parse('$baseUrl/api/v1/chat/conversations/${widget.chatId}/mute'),
      headers: {'Authorization': 'Bearer $token'},
    );
    setState(() {
      isMuted = true;
    });
  }

  void _onUnmute() async {
    final token = await AuthManager.getToken();
    await http.put(
      Uri.parse('$baseUrl/api/v1/chat/conversations/${widget.chatId}/unmute'),
      headers: {'Authorization': 'Bearer $token'},
    );
    setState(() {
      isMuted = false;
    });
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
      MaterialPageRoute(builder: (context) => NavPage()),
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

  void _onBlock() async {
    final token = await AuthManager.getToken();
    final userId = widget.participants
        .firstWhere(
          (participant) => participant.userId != widget.currentUser.id,
        )
        .userId;
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/user/block/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NavPage()),
      );
    }
  }

  void _onUnblock() async {
    final token = await AuthManager.getToken();
    final userId = widget.participants
        .firstWhere(
          (participant) => participant.userId != widget.currentUser.id,
        )
        .userId;
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/user/unblock/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NavPage()),
      );
    }
  }

  void _onDelete() async {
    final token = await AuthManager.getToken();
    await http.put(
      Uri.parse('$baseUrl/api/v1/chat/conversations/${widget.chatId}/delete'),
      headers: {'Authorization': 'Bearer $token'},
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => NavPage()),
    );
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
          final otherParticipant = widget.participants.firstWhere(
            (participant) => participant.userId != widget.currentUser.id,
            orElse: () =>
                throw Exception("Current user not found in participants"),
          );
          return [
            // ... [Your existing header sliver code remains the same]
            SliverToBoxAdapter(
              child: Center(
                child: Column(
                  children: [
                    SizedBox(height: getProportionateScreenHeight(32)),
                    InkWell(
                      onTap: () {
                        if (widget.isGroup) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(
                              isVerified: true,
                              isFromNav: false,
                              userName: otherParticipant.user.username,
                              currentUser: widget.currentUser,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: getProportionateScreenHeight(60),
                        width: getProportionateScreenWidth(60),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: widget.chatImage.isEmpty
                                ? NetworkImage(defaultAvatar)
                                : NetworkImage(widget.chatImage),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: getProportionateScreenHeight(19.5)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.chatName,
                          style: TextStyle(
                            fontSize: getProportionateScreenHeight(24),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        widget.isGroup
                            ? SizedBox(width: getProportionateScreenWidth(20))
                            : const SizedBox(),
                        widget.isGroup
                            ? InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ChangeGroupDetailsScreen(
                                            currentName: widget.chatName,
                                            chatId: widget.chatId,
                                            currentImageUrl: widget.chatImage,
                                          ),
                                    ),
                                  );
                                },
                                child: SvgPicture.asset(
                                  "assets/icons/pencil.svg",
                                  colorFilter: ColorFilter.mode(
                                    iconColor,
                                    BlendMode.srcIn,
                                  ),
                                  width: getProportionateScreenWidth(19),
                                  height: getProportionateScreenHeight(19),
                                ),
                              )
                            : const SizedBox(),
                      ],
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
                                    isMuted ? _onUnmute() : _onMute();
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                      isMuted
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
                                    isMuted ? _onUnmute() : _onMute();
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
                                      isMuted
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

                                widget.isConversationBlockedForMe
                                    ? InkWell(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text(
                                                  "Unblock User",
                                                  style: TextStyle(
                                                    fontSize:
                                                        getProportionateScreenHeight(
                                                          18,
                                                        ),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                content: Text(
                                                  "Are you sure you want to Unblock ${widget.chatHandle}?",
                                                  style: TextStyle(
                                                    fontSize:
                                                        getProportionateScreenHeight(
                                                          16,
                                                        ),
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text("Cancel"),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      _onUnblock();
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text(
                                                      "Unblock",
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SvgPicture.asset(
                                              "assets/icons/chat_details_block.svg",
                                              colorFilter: ColorFilter.mode(
                                                iconColor,
                                                BlendMode.srcIn,
                                              ),
                                              width:
                                                  getProportionateScreenWidth(
                                                    18.38,
                                                  ),
                                              height:
                                                  getProportionateScreenHeight(
                                                    18.38,
                                                  ),
                                            ),
                                            SizedBox(
                                              height:
                                                  getProportionateScreenHeight(
                                                    4.6,
                                                  ),
                                            ),
                                            Text(
                                              "Unblock",
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
                                      )
                                    : InkWell(
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
                                                  "Are you sure you want to Block ${widget.chatHandle}?",
                                                  style: TextStyle(
                                                    fontSize:
                                                        getProportionateScreenHeight(
                                                          16,
                                                        ),
                                                    fontWeight:
                                                        FontWeight.normal,
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
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: kAccentColor,
                                                      ),
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      _onBlock();
                                                    },
                                                    child: Text(
                                                      "Block",
                                                      style: TextStyle(
                                                        fontSize:
                                                            getProportionateScreenHeight(
                                                              16,
                                                            ),
                                                        fontWeight:
                                                            FontWeight.normal,
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SvgPicture.asset(
                                              "assets/icons/chat_block.svg",
                                              colorFilter: ColorFilter.mode(
                                                iconColor,
                                                BlendMode.srcIn,
                                              ),
                                              width:
                                                  getProportionateScreenWidth(
                                                    18.38,
                                                  ),
                                              height:
                                                  getProportionateScreenHeight(
                                                    18.38,
                                                  ),
                                            ),
                                            SizedBox(
                                              height:
                                                  getProportionateScreenHeight(
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
                                // InkWell(
                                //   onTap: () {},
                                //   child: Column(
                                //     mainAxisAlignment: MainAxisAlignment.center,
                                //     children: [
                                //       SvgPicture.asset(
                                //         "assets/icons/chat_report.svg",
                                //         colorFilter: ColorFilter.mode(
                                //           iconColor,
                                //           BlendMode.srcIn,
                                //         ),
                                //         width: getProportionateScreenWidth(
                                //           18.38,
                                //         ),
                                //         height: getProportionateScreenHeight(
                                //           18.38,
                                //         ),
                                //       ),
                                //       SizedBox(
                                //         height: getProportionateScreenHeight(
                                //           4.6,
                                //         ),
                                //       ),
                                //       Text(
                                //         "Report",
                                //         style: TextStyle(
                                //           fontSize:
                                //               getProportionateScreenHeight(
                                //                 11.49,
                                //               ),
                                //           fontWeight: FontWeight.w500,
                                //         ),
                                //       ),
                                //     ],
                                //   ),
                                // ),
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
                                ? InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              GroupParticipantsScreen(
                                                participants:
                                                    widget.participants,
                                                conversationId: widget.chatId,
                                              ),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "People",
                                          style: TextStyle(
                                            fontSize:
                                                getProportionateScreenHeight(
                                                  15,
                                                ),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            SizedBox(
                                              width:
                                                  getProportionateScreenWidth(
                                                    230,
                                                  ),
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
                                            SizedBox(
                                              width:
                                                  getProportionateScreenWidth(
                                                    5,
                                                  ),
                                            ),
                                            Text(
                                              "more",
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
                                      ],
                                    ),
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
          children: [_buildMediaTab(), _buildFilesTab(), _buildVoiceTab()],
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

import 'dart:convert';

import 'package:app/features/chat/data/models/get_messages_response_model.dart';
import 'package:app/features/chat/domain/entities/get_messages_response_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:app/features/chat/presentation/pages/new_chat_screen.dart';
import 'package:http/http.dart' as http;

import '../../../../constants.dart';
import '../../../../services/auth_manager.dart';
import '../../../../services/encryption_service.dart';
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
  late final EncryptionService _encryptionService;
  String selectedChip = "All";
  final List<Map<String, dynamic>> filters = [
    {'label': 'All', 'count': 15},
    {'label': 'Groups', 'count': 2},
    {'label': 'Secret', 'count': 2},
    {'label': 'Archived', 'count': 2},
    {'label': 'Requests', 'count': 2},
  ];

  GetMessageResponse? allMessagesResponse;
  GetMessageResponse? secretMessagesResponse;
  GetMessageResponse? groupMessagesResponse;
  GetMessageResponse? archivedMessagesResponse;
  GetMessageResponse? requestsMessagesResponse;

  bool isAllMessagesLoaded = false;
  bool isSecretMessagesLoaded = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAllConversations();
    // Initialize encryption service
    _encryptionService = EncryptionService();
    // Set up the master encryption key (you should get this from secure storage)
    // For now, using a placeholder - replace with your actual master key
    _encryptionService.setSecretKey(
      '967f042a1b97cb7ec81f7b7825deae4b05a661aae329b738d7068b044de6f56a',
    );
  }

  Future<void> _loadAllConversations() async {
    setState(() => isLoading = true);

    await Future.wait([_fetchConversations(false), _fetchConversations(true)]);

    _processGroupMessages();
    _updateFilterCounts();

    setState(() => isLoading = false);
  }

  Future<void> _fetchConversations(bool isSecret) async {
    try {
      final token = await AuthManager.getToken();
      String url =
          '$baseUrl/api/v1/chat/conversations?page=1&limit=20&isSecret=$isSecret';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = GetMessageResponseModel.fromJson(
          jsonDecode(response.body),
        );

        if (isSecret) {
          secretMessagesResponse = responseData;
          setState(() => isSecretMessagesLoaded = true);
        } else {
          allMessagesResponse = responseData;
          setState(() => isAllMessagesLoaded = true);
        }
      } else {
        _showErrorSnackBar(response.body);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load conversations: $e');
    }
  }

  void _processGroupMessages() {
    if (allMessagesResponse == null) return;

    final groupConversations = allMessagesResponse!.conversations
        .where((conversation) => conversation.type == 'GROUP')
        .toList();

    groupMessagesResponse = GetMessageResponse(
      conversations: groupConversations,
      pagination: Pagination(
        hasMore: allMessagesResponse!.pagination.hasMore,
        page: allMessagesResponse!.pagination.page,
        limit: allMessagesResponse!.pagination.limit,
        totalCount: groupConversations.length,
        totalPages: allMessagesResponse!.pagination.totalPages,
      ),
    );
  }

  void _updateFilterCounts() {
    if (allMessagesResponse == null) return;

    final allCount = allMessagesResponse!.conversations.length;
    final groupCount = groupMessagesResponse?.conversations.length ?? 0;
    final secretCount = secretMessagesResponse?.conversations.length ?? 0;

    setState(() {
      filters[0]['count'] = allCount;
      filters[1]['count'] = groupCount;
      filters[2]['count'] = secretCount;
      // Update other counts as needed
    });
  }

  void _showErrorSnackBar(String errorBody) {
    final errorMessage = jsonDecode(
      errorBody,
    )['message'].toString().replaceAll(RegExp(r'\[|\]'), '');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            errorMessage,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  GetMessageResponse? _getSelectedMessagesResponse() {
    switch (selectedChip) {
      case "All":
        return allMessagesResponse;
      case "Secret":
        return secretMessagesResponse;
      case "Groups":
        return groupMessagesResponse;
      case "Archived":
        return archivedMessagesResponse;
      case "Requests":
        return requestsMessagesResponse;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final dividerColor = isDarkMode ? kGreyInputFillDark : kGreyInputBorder;
    final iconColor = isDarkMode ? kWhite : kBlack;
    final selectedChipColor = isDarkMode ? kGreyInputFillDark : kLightPurple;

    return Scaffold(
      appBar: _buildAppBar(iconColor),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(dividerColor, selectedChipColor, iconColor),
    );
  }

  PreferredSizeWidget _buildAppBar(Color iconColor) {
    return AppBar(
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
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    NewChatScreen(currentUser: widget.currentUser),
              ),
            ),
            child: SvgPicture.asset(
              "assets/icons/edit.svg",
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              width: getProportionateScreenWidth(24),
              height: getProportionateScreenHeight(24),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(
    Color dividerColor,
    Color selectedChipColor,
    Color iconColor,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: getProportionateScreenHeight(17)),
          _buildSearchField(),
          SizedBox(height: getProportionateScreenHeight(34)),
          _buildFilterChips(dividerColor, selectedChipColor, iconColor),
          SizedBox(height: getProportionateScreenHeight(34)),
          _buildConversationList(dividerColor),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: getProportionateScreenWidth(16),
      ),
      child: TextFormField(
        decoration: _buildChatSearchFieldDecoration(context),
        onChanged: (value) {
          // Add search functionality here
        },
      ),
    );
  }

  Widget _buildFilterChips(
    Color dividerColor,
    Color selectedChipColor,
    Color iconColor,
  ) {
    return Padding(
      padding: EdgeInsets.only(left: getProportionateScreenWidth(17)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SvgPicture.asset(
              "assets/icons/sliders-horizontal.svg",
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              width: getProportionateScreenWidth(15),
              height: getProportionateScreenHeight(15),
            ),
            SizedBox(width: getProportionateScreenWidth(11)),
            ...filters.map(
              (filter) =>
                  _buildFilterChip(filter, dividerColor, selectedChipColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    Map<String, dynamic> filter,
    Color dividerColor,
    Color selectedChipColor,
  ) {
    final isSelected = selectedChip == filter['label'];

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () => setState(() => selectedChip = filter['label']),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? selectedChipColor : Colors.transparent,
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
                  fontSize: getProportionateScreenHeight(12),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                filter['count'].toString(),
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: getProportionateScreenHeight(12),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConversationList(Color dividerColor) {
    final selectedResponse = _getSelectedMessagesResponse();

    if (selectedResponse == null || selectedResponse.conversations.isEmpty) {
      return const Center(child: Text('No conversations found'));
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: getProportionateScreenWidth(18),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: selectedResponse.conversations.length,
        itemBuilder: (context, index) =>
            _buildChatTile(selectedResponse.conversations[index], dividerColor),
      ),
    );
  }

  String _decryptMessageContent(String encryptedContent, String encryptionKey) {
    try {
      return _encryptionService.decryptWithConversationKey(
        encryptedContent,
        encryptionKey,
      );
    } catch (e) {
      // Return placeholder text if decryption fails
      // In production, you might want to handle this differently
      return '[Message could not be decrypted]';
    }
  }

  Widget _buildChatTile(dynamic conversation, Color dividerColor) {
    final isGroupChat = conversation.type == "GROUP";
    final otherParticipant = isGroupChat
        ? null
        : conversation.participants.firstWhere(
            (participant) =>
                participant.user.username != widget.currentUser.username,
          );

    return ChatTile(
      dividerColor: dividerColor,
      image: isGroupChat
          ? "https://images.unsplash.com/photo-1522202176988-66273c2fd55f?q=80&w=1742&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D" // TODO: Add group image
          : otherParticipant?.user.profileImage,
      name: isGroupChat
          ? conversation.name ?? 'Group Chat'
          : otherParticipant?.user.fullName ?? 'Unknown User',
      lastMessage: conversation.lastMessage?.content == null
          ? "No message yet"
          : _decryptMessageContent(
              conversation.lastMessage!.content,
              conversation.encryptionKey,
            ),
      time: conversation.lastMessage?.createdAt ?? DateTime.now(),
      unreadMessages: conversation.unreadCount ?? 0,
      chatId: conversation.id,
      currentUser: widget.currentUser,
      encryptionKey: conversation.encryptionKey,
    );
  }

  InputDecoration _buildChatSearchFieldDecoration(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final borderColor = isDarkMode ? kGreySearchInput : kGreyInputBorder;
    final iconColor = isDarkMode ? kGreyDarkInputBorder : kGreyInputBorder;

    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(getProportionateScreenWidth(30)),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(getProportionateScreenWidth(30)),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(getProportionateScreenWidth(30)),
        borderSide: BorderSide(color: borderColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(getProportionateScreenWidth(30)),
        borderSide: BorderSide(color: borderColor),
      ),
      fillColor: isDarkMode ? kGreySearchInput : null,
      filled: isDarkMode,
      prefixIcon: Padding(
        padding: EdgeInsets.all(getProportionateScreenHeight(14)),
        child: SvgPicture.asset(
          "assets/icons/search.svg",
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          width: getProportionateScreenWidth(14),
          height: getProportionateScreenHeight(14),
        ),
      ),
      hintText: "Search",
    );
  }
}

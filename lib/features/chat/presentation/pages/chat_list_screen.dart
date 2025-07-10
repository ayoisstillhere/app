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
  late final ScrollController _scrollController;

  String selectedChip = "All";
  final List<Map<String, dynamic>> filters = [
    {'label': 'All', 'count': 0},
    {'label': 'Groups', 'count': 0},
    {'label': 'Secret', 'count': 0},
    {'label': 'Archived', 'count': 0},
    {'label': 'Requests', 'count': 0},
  ];

  // Pagination state for each filter
  final Map<String, int> _currentPages = {
    'All': 1,
    'Secret': 1,
    'Groups': 1,
    'Archived': 1,
    'Requests': 1,
  };

  final Map<String, bool> _hasMore = {
    'All': true,
    'Secret': true,
    'Groups': true,
    'Archived': true,
    'Requests': true,
  };

  final Map<String, bool> _isLoadingMore = {
    'All': false,
    'Secret': false,
    'Groups': false,
    'Archived': false,
    'Requests': false,
  };

  // Store accumulated conversations for each filter
  final Map<String, List<Conversation>> _allConversations = {
    'All': [],
    'Secret': [],
    'Groups': [],
    'Archived': [],
    'Requests': [],
  };

  GetMessageResponse? allMessagesResponse;
  GetMessageResponse? secretMessagesResponse;
  GetMessageResponse? groupMessagesResponse;
  GetMessageResponse? archivedMessagesResponse;
  GetMessageResponse? requestsMessagesResponse;

  bool isAllMessagesLoaded = false;
  bool isSecretMessagesLoaded = false;
  bool isLoading = false;

  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _loadInitialConversations();

    // Initialize encryption service
    _encryptionService = EncryptionService();
    _encryptionService.setSecretKey(
      '967f042a1b97cb7ec81f7b7825deae4b05a661aae329b738d7068b044de6f56a',
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Use ModalRoute to check if this screen is currently active
    if (ModalRoute.of(context)?.isCurrent == true) {
      _loadInitialConversations();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreConversations();
    }
  }

  Future<void> _loadInitialConversations() async {
    setState(() => isLoading = true);

    // Reset pagination state
    _currentPages.updateAll((key, value) => 1);
    _hasMore.updateAll((key, value) => true);
    _allConversations.updateAll((key, value) => []);

    await Future.wait([
      _fetchConversations(false, 1),
      _fetchConversations(true, 1),
    ]);

    _processGroupMessages();
    _updateFilterCounts();

    setState(() => isLoading = false);
  }

  Future<void> _loadMoreConversations() async {
    final currentFilter = selectedChip;

    // Don't load more if already loading or no more data
    if (_isLoadingMore[currentFilter]! || !_hasMore[currentFilter]!) {
      return;
    }

    setState(() => _isLoadingMore[currentFilter] = true);

    try {
      final nextPage = _currentPages[currentFilter]! + 1;

      switch (currentFilter) {
        case 'All':
          await _fetchConversations(false, nextPage, isLoadMore: true);
          break;
        case 'Secret':
          await _fetchConversations(true, nextPage, isLoadMore: true);
          break;
        case 'Groups':
          await _fetchConversations(false, nextPage, isLoadMore: true);
          break;
        // Add cases for Archived and Requests when implemented
      }

      _currentPages[currentFilter] = nextPage;
      _updateFilterCounts();
    } catch (e) {
      _showErrorSnackBar('Failed to load more conversations: $e');
    } finally {
      setState(() => _isLoadingMore[currentFilter] = false);
    }
  }

  Future<void> _fetchConversations(
    bool isSecret,
    int page, {
    bool isLoadMore = false,
  }) async {
    try {
      final token = await AuthManager.getToken();
      String url =
          '$baseUrl/api/v1/chat/conversations?page=$page&limit=$_pageSize&isSecret=$isSecret';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = GetMessageResponseModel.fromJson(
          jsonDecode(response.body),
        );

        if (isSecret) {
          if (isLoadMore) {
            // Append to existing conversations
            _allConversations['Secret']!.addAll(responseData.conversations);
            secretMessagesResponse = GetMessageResponse(
              conversations: _allConversations['Secret']!,
              pagination: responseData.pagination,
            );
          } else {
            // Replace conversations (initial load)
            _allConversations['Secret'] = responseData.conversations;
            secretMessagesResponse = responseData;
          }

          _hasMore['Secret'] = responseData.pagination.hasMore;
          setState(() => isSecretMessagesLoaded = true);
        } else {
          if (isLoadMore) {
            // Append to existing conversations
            _allConversations['All']!.addAll(responseData.conversations);
            allMessagesResponse = GetMessageResponse(
              conversations: _allConversations['All']!,
              pagination: responseData.pagination,
            );
          } else {
            // Replace conversations (initial load)
            _allConversations['All'] = responseData.conversations;
            allMessagesResponse = responseData;
          }

          _hasMore['All'] = responseData.pagination.hasMore;
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
    if (_allConversations['All']!.isEmpty) return;

    final groupConversations = _allConversations['All']!
        .where((conversation) => conversation.type == 'GROUP')
        .toList();

    _allConversations['Groups'] = groupConversations;
    groupMessagesResponse = GetMessageResponse(
      conversations: groupConversations,
      pagination: Pagination(
        hasMore: allMessagesResponse?.pagination.hasMore ?? false,
        page: allMessagesResponse?.pagination.page ?? 1,
        limit: allMessagesResponse?.pagination.limit ?? _pageSize,
        totalCount: groupConversations.length,
        totalPages: allMessagesResponse?.pagination.totalPages ?? 1,
      ),
    );
  }

  void _updateFilterCounts() {
    final allCount = _allConversations['All']!
        .where((conversation) => conversation.lastMessage != null)
        .length;
    final groupCount = _allConversations['Groups']!
        .where((conversation) => conversation.lastMessage != null)
        .length;
    final secretCount = _allConversations['Secret']!
        .where((conversation) => conversation.lastMessage != null)
        .length;

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

  List<dynamic> _getSelectedConversations() {
    switch (selectedChip) {
      case "All":
        return _allConversations['All']!;
      case "Secret":
        return _allConversations['Secret']!;
      case "Groups":
        return _allConversations['Groups']!;
      case "Archived":
        return _allConversations['Archived']!;
      case "Requests":
        return _allConversations['Requests']!;
      default:
        return [];
    }
  }

  bool _hasMoreForCurrentFilter() {
    return _hasMore[selectedChip] ?? false;
  }

  bool _isLoadingMoreForCurrentFilter() {
    return _isLoadingMore[selectedChip] ?? false;
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
      controller: _scrollController,
      child: Column(
        children: [
          SizedBox(height: getProportionateScreenHeight(17)),
          _buildSearchField(),
          SizedBox(height: getProportionateScreenHeight(34)),
          _buildFilterChips(dividerColor, selectedChipColor, iconColor),
          SizedBox(height: getProportionateScreenHeight(34)),
          _buildConversationList(dividerColor),
          if (_isLoadingMoreForCurrentFilter())
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (!_hasMoreForCurrentFilter() &&
              _getSelectedConversations().isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No more conversations to load',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: getProportionateScreenHeight(12),
                ),
              ),
            ),
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
        onTap: () {
          setState(() => selectedChip = filter['label']);
          // Reset scroll position when changing filters
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
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
    final selectedConversations = _getSelectedConversations();

    if (selectedConversations.isEmpty) {
      return const Center(child: Text('No conversations found'));
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: getProportionateScreenWidth(18),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: selectedConversations.length,
        itemBuilder: (context, index) =>
            _buildChatTile(selectedConversations[index], dividerColor),
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

    return conversation.lastMessage?.content == null
        ? Container()
        : ChatTile(
            dividerColor: dividerColor,
            image: isGroupChat
                ? "https://images.unsplash.com/photo-1522202176988-66273c2fd55f?q=80&w=1742&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
                : otherParticipant?.user.profileImage,
            name: isGroupChat
                ? conversation.name ?? 'Group Chat'
                : otherParticipant?.user.fullName ?? 'Unknown User',
            lastMessage: conversation.isSecret
                ? '[Secret Message]'
                : conversation.lastMessage?.type == "TEXT"
                ? _decryptMessageContent(
                    conversation.lastMessage!.content,
                    conversation.encryptionKey,
                  )
                : conversation.lastMessage.type.toString(),
            time: conversation.lastMessage?.createdAt ?? DateTime.now(),
            unreadMessages: conversation.unreadCount ?? 0,
            chatId: conversation.id,
            currentUser: widget.currentUser,
            encryptionKey: conversation.encryptionKey,
            chatHandle: conversation.participants
                .firstWhere(
                  (participant) =>
                      participant.user.username != widget.currentUser.username,
                )
                .user
                .username,
            isGroup: conversation.type == "GROUP",
            participants: conversation.participants,
            isConversationMuted: conversation.isConversationMutedForMe,
            isSecretChat: conversation.isSecret,
            isConversationBlockedForMe: conversation.isConversationBlockedForMe,
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

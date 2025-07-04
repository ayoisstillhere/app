import 'package:app/features/chat/presentation/pages/chat_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../constants.dart';
import '../../../../size_config.dart';
import '../../data/models/chat_message_model.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Sample messages - replace with your actual data model

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        messages.add(
          ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: _messageController.text.trim(),
            isMe: true,
            timestamp: DateTime.now(),
            isRead: false,
          ),
        );
      });
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final iconColor = isDark ? kWhite : kBlack;
    final dividerColor = isDark ? kGreyInputFillDark : kGreyInputBorder;
    final backgroundColor = isDark ? kBlack : kWhite;
    final inputFillColor = isDark
        ? kGreyInputFillDark
        : kGreyInputBorder.withValues(alpha: 0.3);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Row(
          children: [
            Container(
              height: getProportionateScreenHeight(40),
              width: getProportionateScreenWidth(40),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(
                    "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=3000&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: getProportionateScreenWidth(13)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Ayodele",
                  style: TextStyle(
                    fontSize: getProportionateScreenHeight(16),
                    fontWeight: FontWeight.w600,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ],
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
                  "assets/icons/lock.svg",
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatDetailsScreen(),
                    ),
                  );
                },
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
          preferredSize: Size.fromHeight(getProportionateScreenHeight(10)),
          child: Container(
            width: double.infinity,
            height: 1,
            color: dividerColor,
          ),
        ),
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.only(
                left: getProportionateScreenWidth(13),
                right: getProportionateScreenWidth(17),
                top: getProportionateScreenHeight(8),
                bottom: getProportionateScreenHeight(8),
              ),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return MessageBubble(message: message, isDark: isDark);
              },
            ),
          ),

          // Message Input
          Container(
            padding: EdgeInsets.only(bottom: getProportionateScreenHeight(16)),
            decoration: BoxDecoration(color: backgroundColor),
            child: SafeArea(
              child: Container(
                margin: EdgeInsets.only(
                  left: getProportionateScreenWidth(15),
                  right: getProportionateScreenWidth(14),
                ),
                decoration: BoxDecoration(
                  // color: inputFillColor,
                  borderRadius: BorderRadius.circular(
                    getProportionateScreenWidth(40),
                  ),
                  color: inputFillColor,
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: getProportionateScreenWidth(5),
                    top: getProportionateScreenHeight(8),
                    bottom: getProportionateScreenHeight(7),
                    right: getProportionateScreenWidth(15),
                  ),
                  child: Row(
                    children: [
                      // Camera button
                      InkWell(
                        onTap: () {
                          // Handle camera action
                        },
                        child: Container(
                          padding: EdgeInsets.all(
                            getProportionateScreenWidth(8),
                          ),
                          height: getProportionateScreenHeight(39),
                          width: getProportionateScreenWidth(39),
                          decoration: BoxDecoration(
                            gradient: kChatBubbleGradient,
                            shape: BoxShape.circle,
                          ),
                          child: SvgPicture.asset(
                            "assets/icons/chat_camera.svg",
                            height: getProportionateScreenHeight(21.27),
                            width: getProportionateScreenWidth(21.27),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: "Message...",
                            hintStyle: TextStyle(
                              fontSize: getProportionateScreenHeight(14),
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            fillColor: Colors.transparent,
                            filled: false,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: getProportionateScreenWidth(16),
                              vertical: getProportionateScreenHeight(12),
                            ),
                          ),
                          style: TextStyle(
                            color: iconColor,
                            fontSize: getProportionateScreenHeight(14),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      SvgPicture.asset(
                        "assets/icons/chat_paperclip.svg",
                        height: getProportionateScreenHeight(21.27),
                        width: getProportionateScreenWidth(21.27),
                      ),
                      SizedBox(width: getProportionateScreenWidth(8)),
                      SvgPicture.asset(
                        "assets/icons/chat_mic.svg",
                        height: getProportionateScreenHeight(21.27),
                        width: getProportionateScreenWidth(21.27),
                      ),
                      SizedBox(width: getProportionateScreenWidth(8)),
                      SvgPicture.asset(
                        "assets/icons/chat_image.svg",
                        height: getProportionateScreenHeight(21.27),
                        width: getProportionateScreenWidth(21.27),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

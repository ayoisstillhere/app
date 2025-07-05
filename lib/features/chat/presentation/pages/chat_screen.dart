import 'dart:convert';

import 'package:app/features/chat/presentation/pages/chat_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;

import '../../../../constants.dart';
import '../../../../services/auth_manager.dart';
import '../../../../size_config.dart';
import '../../data/models/chat_message_model.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.chatId,
    required this.name,
    required this.imageUrl,
  });
  final String chatId;
  final String name;
  final String imageUrl;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      final url = Uri.parse('$baseUrl/api/v1/chat/messages');
      final token = await AuthManager.getToken();

      final request = http.MultipartRequest('POST', url)
        ..headers['accept'] = '*/*'
        ..headers['Authorization'] = 'Bearer $token';

      // Add form fields
      request.fields['conversationId'] = widget.chatId;
      request.fields['type'] = 'TEXT';
      request.fields['content'] = _messageController.text.trim();
      request.fields['isViewOnce'] = 'false';
      request.fields['deleteAfter24Hours'] = 'false';
      request.fields['isForwarded'] = 'false';
      // request.fields['replyToId'] = '123e4567-e89b-12d3-a456-426614174000';

      // You can skip this if you're not uploading a file
      // request.files.add(await http.MultipartFile.fromPath('file', 'path_to_file'));

      try {
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200 || response.statusCode == 201) {
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
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(e.toString(), style: TextStyle(color: Colors.white)),
          ),
        );
      }
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
                  image: NetworkImage(widget.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: getProportionateScreenWidth(13)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
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
                return MessageBubble(
                  message: message,
                  isDark: isDark,
                  imageUrl: widget.imageUrl,
                );
              },
            ),
          ),

          // Message Input
          // Replace your message input Container with this:
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
                      // Use ValueListenableBuilder to listen to text changes
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _messageController,
                        builder: (context, value, child) {
                          final hasText = value.text.trim().isNotEmpty;
                          return Row(
                            children: [
                              // Send button - visible when there's text
                              if (hasText)
                                InkWell(
                                  onTap: () => _sendMessage(),
                                  child: Container(
                                    width: getProportionateScreenWidth(55),
                                    height: getProportionateScreenHeight(34),
                                    padding: EdgeInsets.symmetric(
                                      vertical: getProportionateScreenHeight(5),
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: kChatBubbleGradient,
                                      borderRadius: BorderRadius.circular(
                                        getProportionateScreenWidth(20),
                                      ),
                                    ),
                                    child: SvgPicture.asset(
                                      "assets/icons/send.svg",
                                      height: getProportionateScreenHeight(
                                        21.27,
                                      ),
                                      width: getProportionateScreenWidth(21.27),
                                    ),
                                  ),
                                ),
                              // Attachment icons - visible when there's no text
                              if (!hasText) ...[
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
                            ],
                          );
                        },
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

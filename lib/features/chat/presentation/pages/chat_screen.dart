import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;

import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:app/features/chat/domain/entities/text_message_entity.dart';
import 'package:app/features/chat/presentation/pages/chat_details_screen.dart';

import '../../../../constants.dart';
import '../../../../services/auth_manager.dart';
import '../../../../services/encryption_service.dart'; // Add this import
import '../../../../size_config.dart';
import '../cubit/chat_cubit.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.chatId,
    required this.name,
    required this.imageUrl,
    required this.currentUser,
    required this.encryptionKey,
  });
  final String chatId;
  final String name;
  final String imageUrl;
  final UserEntity currentUser;
  final String encryptionKey;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final EncryptionService _encryptionService;

  @override
  void initState() {
    // Initialize encryption service
    _encryptionService = EncryptionService();
    // Set up the master encryption key (you should get this from secure storage)
    // For now, using a placeholder - replace with your actual master key
    _encryptionService.setSecretKey(
      '967f042a1b97cb7ec81f7b7825deae4b05a661aae329b738d7068b044de6f56a',
    );

    BlocProvider.of<ChatCubit>(context).getTextMessages();
    super.initState();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      final url = Uri.parse('$baseUrl/api/v1/chat/messages');
      final token = await AuthManager.getToken();

      final request = http.MultipartRequest('POST', url)
        ..headers['accept'] = '*/*'
        ..headers['Authorization'] = 'Bearer $token';

      // Encrypt the message content before sending
      String encryptedContent;
      try {
        encryptedContent = _encryptionService.encryptWithConversationKey(
          _messageController.text.trim(),
          widget.encryptionKey,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Failed to encrypt message: ${e.toString()}',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
        return;
      }

      // Add form fields with encrypted content
      request.fields['conversationId'] = widget.chatId;
      request.fields['type'] = 'TEXT';
      request.fields['content'] = encryptedContent; // Send encrypted content
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

  // Method to decrypt message content
  String _decryptMessageContent(String encryptedContent) {
    try {
      return _encryptionService.decryptWithConversationKey(
        encryptedContent,
        widget.encryptionKey,
      );
    } catch (e) {
      // Return placeholder text if decryption fails
      // In production, you might want to handle this differently
      return '[Message could not be decrypted]';
    }
  }

  // Method to create decrypted message entity
  TextMessageEntity _createDecryptedMessage(TextMessageEntity original) {
    final decryptedContent = _decryptMessageContent(original.content);

    // Create a new TextMessageEntity with decrypted content
    // You'll need to adjust this based on your TextMessageEntity constructor
    return TextMessageEntity(
      decryptedContent,
      original.conversationId,
      original.createdAt,
      original.expiredAt,
      original.id,
      original.isForwarded,
      original.isViewOnce,
      original.mediaUrl,
      original.reactions,
      original.senderId,
      original.type,
    );
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
      body: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          if (state is ChatLoaded) {
            // Decrypt messages as they're processed
            List<TextMessageEntity> requiredMessages = [];
            for (TextMessageEntity textMessageEntity in state.messages) {
              if (textMessageEntity.conversationId == widget.chatId) {
                final decryptedMessage = _createDecryptedMessage(
                  textMessageEntity,
                );
                requiredMessages.add(decryptedMessage);
              }
            }

            // Sort by timestamp (newest first)
            requiredMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            return Column(
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
                    itemCount: requiredMessages.length,
                    itemBuilder: (context, index) {
                      final message = requiredMessages[index];
                      return MessageBubble(
                        message: message, // This now contains decrypted content
                        isDark: isDark,
                        imageUrl: widget.imageUrl,
                        currentUser: widget.currentUser,
                      );
                    },
                  ),
                ),

                // Message Input
                Container(
                  padding: EdgeInsets.only(
                    bottom: getProportionateScreenHeight(16),
                  ),
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
                                          width: getProportionateScreenWidth(
                                            55,
                                          ),
                                          height: getProportionateScreenHeight(
                                            34,
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            vertical:
                                                getProportionateScreenHeight(5),
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: kChatBubbleGradient,
                                            borderRadius: BorderRadius.circular(
                                              getProportionateScreenWidth(20),
                                            ),
                                          ),
                                          child: SvgPicture.asset(
                                            "assets/icons/send.svg",
                                            height:
                                                getProportionateScreenHeight(
                                                  21.27,
                                                ),
                                            width: getProportionateScreenWidth(
                                              21.27,
                                            ),
                                          ),
                                        ),
                                      ),
                                    // Attachment icons - visible when there's no text
                                    if (!hasText) ...[
                                      SvgPicture.asset(
                                        "assets/icons/chat_paperclip.svg",
                                        height: getProportionateScreenHeight(
                                          21.27,
                                        ),
                                        width: getProportionateScreenWidth(
                                          21.27,
                                        ),
                                      ),
                                      SizedBox(
                                        width: getProportionateScreenWidth(8),
                                      ),
                                      SvgPicture.asset(
                                        "assets/icons/chat_mic.svg",
                                        height: getProportionateScreenHeight(
                                          21.27,
                                        ),
                                        width: getProportionateScreenWidth(
                                          21.27,
                                        ),
                                      ),
                                      SizedBox(
                                        width: getProportionateScreenWidth(8),
                                      ),
                                      SvgPicture.asset(
                                        "assets/icons/chat_image.svg",
                                        height: getProportionateScreenHeight(
                                          21.27,
                                        ),
                                        width: getProportionateScreenWidth(
                                          21.27,
                                        ),
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
            );
          }
          return Center(child: CircularProgressIndicator());
        },
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

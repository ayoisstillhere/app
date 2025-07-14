import 'dart:convert';
import 'dart:io';

import 'package:app/features/chat/data/models/get_messages_response_model.dart';
import 'package:app/features/chat/presentation/pages/video_call_screen.dart';
import 'package:app/features/chat/presentation/pages/voice_call_screen.dart';
import 'package:fast_rsa/fast_rsa.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:app/features/chat/domain/entities/get_messages_response_entity.dart'
    hide User;
import 'package:app/features/chat/domain/entities/text_message_entity.dart';
import 'package:app/features/chat/presentation/pages/chat_details_screen.dart';
import 'package:app/services/file_encryptor.dart';

import '../../../../constants.dart';
import '../../../../services/auth_manager.dart';
import '../../../../services/encryption_service.dart';
import '../../../../size_config.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
import '../cubit/chat_cubit.dart';
import '../widgets/message_bubble.dart';
import 'secret_chat_screen.dart';

class SelectedFile {
  final File file;
  final MessageType type;
  final String? thumbnail;
  final Duration? duration;

  SelectedFile({
    required this.file,
    required this.type,
    this.thumbnail,
    this.duration,
  });
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.chatId,
    required this.name,
    required this.imageUrl,
    required this.currentUser,
    required this.encryptionKey,
    this.chatHandle,
    required this.isGroup,
    required this.participants,
    required this.isConversationMuted,
    required this.isConversationBlockedForMe,
  });
  final String chatId;
  final String name;
  final String imageUrl;
  final UserEntity currentUser;
  final String encryptionKey;
  final String? chatHandle;
  final bool isGroup;
  final List<Participant> participants;
  final bool isConversationMuted;
  final bool isConversationBlockedForMe;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final EncryptionService _encryptionService;
  final ImagePicker _imagePicker = ImagePicker();
  late FlutterSoundRecorder _audioRecorder;

  SelectedFile? _selectedFile;
  bool _isRecording = false;
  bool _isSending = false;
  String? _recordingPath;
  VideoPlayerController? _videoController;

  // Add reply state
  TextMessageEntity? _replyToMessage;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    BlocProvider.of<ChatCubit>(context).getTextMessages();
    _markAllAssRead();
  }

  void _initializeServices() {
    _encryptionService = EncryptionService();
    _encryptionService.setSecretKey(
      '967f042a1b97cb7ec81f7b7825deae4b05a661aae329b738d7068b044de6f56a',
    );
    _audioRecorder = FlutterSoundRecorder();
    _initializeAudioRecorder();
  }

  Future<void> _createSecretChat({bool deleteFormerChat = false}) async {
    try {
      if (widget.isGroup) {
        return;
      }
      final token = await AuthManager.getToken();
      final uri = Uri.parse('$baseUrl/api/v1/chat/secret-conversations');

      // Generate a conversation key for end-to-end encryption
      final conversationKey = _encryptionService.generateConversationKey();

      // Get the current user's participant data
      final myParticipant = widget.participants.firstWhere(
        (participant) => participant.userId == widget.currentUser.id,
        orElse: () => throw Exception("Current user not found in participants"),
      );

      // Get the other participant's data
      final otherParticipant = widget.participants.firstWhere(
        (participant) => participant.userId != widget.currentUser.id,
        orElse: () => throw Exception("Other participant not found"),
      );

      // Get both public keys
      final myPublicKey = myParticipant.user.publicKey;
      final otherPublicKey = otherParticipant.user.publicKey;

      // Use RSA to encrypt the conversation key with both public keys
      final myEncryptedKey = await RSA.encryptPKCS1v15(
        conversationKey,
        myPublicKey!,
      );
      final otherEncryptedKey = await RSA.encryptPKCS1v15(
        conversationKey,
        otherPublicKey!,
      );

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final body = jsonEncode({
        "participantUserIds": widget.participants.map((e) => e.userId).toList(),
        "myConversationKey": myEncryptedKey,
        "otherParticipantConversationKey": otherEncryptedKey,
        "deleteFormerChat": deleteFormerChat,
      });

      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SecretChatScreen(
              chatId: jsonDecode(response.body)['id'],
              name: widget.name,
              imageUrl: widget.imageUrl,
              currentUser: widget.currentUser,
              chatHandle: widget.chatHandle,
              isGroup: false,
              participants: (jsonDecode(response.body)['participants'] as List)
                  .map((e) => ParticipantModel.fromJson(e))
                  .toList(),

              isConversationMuted: jsonDecode(
                response.body,
              )['isConversationMutedForMe'],
              isConversationBlockedForMe: jsonDecode(
                response.body,
              )['isConversationBlockedForMe'],
            ),
          ),
        ).then((result) {
          if (result != null && result['recreateSecretChat'] == true) {
            _createSecretChat(deleteFormerChat: true);
          }
        });
      }
    } catch (e) {
      debugPrint(e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "A secret Chat cannot be created with this user currently",
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    }
  }

  Future<void> _initializeAudioRecorder() async {
    await _audioRecorder.openRecorder();
  }

  Future<void> _markAllAssRead() async {
    final token = await AuthManager.getToken();
    final uri = Uri.parse(
      '$baseUrl/api/v1/chat/conversations/${widget.chatId}/mark-all-read',
    );

    final response = await http.put(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      // Successfully marked all messages as read
    } else {}
  }

  Future<void> _sendMessage(MessageType type) async {
    if (_isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      final url = Uri.parse('$baseUrl/api/v1/chat/messages');
      final token = await AuthManager.getToken();

      final request = http.MultipartRequest('POST', url)
        ..headers['accept'] = '*/*'
        ..headers['Authorization'] = 'Bearer $token';

      // Add basic form fields
      request.fields['conversationId'] = widget.chatId;
      request.fields['type'] = type.name;
      request.fields['deleteAfter24Hours'] = 'false';
      request.fields['isForwarded'] = 'false';

      // Add reply field if replying to a message
      if (_replyToMessage != null) {
        request.fields['replyToId'] = _replyToMessage!.id;
      }

      if (type == MessageType.TEXT) {
        // Handle text messages
        if (_messageController.text.trim().isEmpty) return;

        final encryptedContent = _encryptionService.encryptWithConversationKey(
          _messageController.text.trim(),
          widget.encryptionKey,
        );
        request.fields['content'] = encryptedContent;
      } else {
        // Handle file messages - existing code remains the same
        if (_selectedFile == null) return;

        File fileToSend = _selectedFile!.file;

        if (type == MessageType.IMAGE) {
          fileToSend = await compressImage(File(_selectedFile!.file.path));
        } else if (type == MessageType.VIDEO) {
          fileToSend = await compressVideo(File(_selectedFile!.file.path));
        }

        final encryptedFile = await FileEncryptor.encryptFile(fileToSend);

        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            encryptedFile['encryptedFile'].path,
            filename: _selectedFile!.file.path.split('/').last,
          ),
        );

        encryptedFile.putIfAbsent(
          'filename',
          () => fileToSend.path.split('/').last,
        );
        encryptedFile.remove('encryptedFile');
        request.fields['encryptionMetadata'] = jsonEncode(encryptedFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _messageController.clear();
        _clearSelectedFile();
        _clearReply(); // Clear reply state
        _scrollToBottom();

        // Refresh messages to show the new one
        BlocProvider.of<ChatCubit>(context).getTextMessages();
      } else {
        _showErrorSnackBar(
          jsonDecode(
            response.body,
          )['message'].toString().replaceAll(RegExp(r'\[|\]'), ''),
        );
      }
    } catch (e) {
      _showErrorSnackBar('Failed to send message: ${e.toString()}');
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  // Add method to set reply
  void _setReply(TextMessageEntity message) {
    setState(() {
      _replyToMessage = message;
    });
  }

  // Add method to clear reply
  void _clearReply() {
    setState(() {
      _replyToMessage = null;
    });
  }

  // Add method to build reply preview
  Widget _buildReplyPreview() {
    if (_replyToMessage == null) return SizedBox.shrink();

    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.grey[800] : Colors.grey[200];
    final textColor = isDark ? Colors.white : Colors.black;

    return Container(
      margin: EdgeInsets.only(
        left: getProportionateScreenWidth(15),
        right: getProportionateScreenWidth(15),
        top: getProportionateScreenHeight(8),
      ),
      padding: EdgeInsets.all(getProportionateScreenWidth(12)),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(getProportionateScreenWidth(8)),
        border: Border(
          left: BorderSide(
            color: Colors.blue,
            width: getProportionateScreenWidth(3),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _replyToMessage!.senderId == widget.currentUser.id
                      ? 'You'
                      : _getMessageSenderName(_replyToMessage!),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: getProportionateScreenHeight(12),
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: getProportionateScreenHeight(4)),
                Text(
                  _getReplyPreviewText(_replyToMessage!),
                  style: TextStyle(
                    fontSize: getProportionateScreenHeight(14),
                    color: textColor.withOpacity(0.8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _clearReply,
            icon: Icon(
              Icons.close,
              size: getProportionateScreenWidth(20),
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get sender name
  String _getMessageSenderName(TextMessageEntity message) {
    if (widget.isGroup) {
      final participant = widget.participants.firstWhere(
        (participant) => participant.userId == message.senderId,
        orElse: () => throw Exception("Participant not found"),
      );
      return participant.user.username;
    }
    return widget.name;
  }

  // Helper method to get reply preview text
  String _getReplyPreviewText(TextMessageEntity message) {
    if (message.type == MessageType.TEXT.name) {
      return message.content;
    } else {
      return '${message.type.toLowerCase()} message';
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(message, style: TextStyle(color: Colors.white)),
      ),
    );
  }

  // Camera functionality
  Future<void> _takePicture() async {
    // Show dialog to choose between photo and video
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choose Media Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_camera),
              title: Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _capturePhoto();
              },
            ),
            ListTile(
              leading: Icon(Icons.videocam),
              title: Text('Record Video'),
              onTap: () {
                Navigator.pop(context);
                _captureVideo();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _capturePhoto() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image != null) {
      _setSelectedFile(File(image.path), MessageType.IMAGE);
    }
  }

  Future<void> _captureVideo() async {
    final XFile? video = await _imagePicker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(minutes: 5), // Set max duration as needed
    );

    if (video != null) {
      _setSelectedFile(File(video.path), MessageType.VIDEO);
    }
  }

  // Gallery functionality
  Future<void> _pickMediaFromGallery() async {
    try {
      // This will show both images and videos in the picker
      final XFile? media = await _imagePicker.pickMedia(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (media != null) {
        final file = File(media.path);
        final extension = media.path.split('.').last.toLowerCase();

        MessageType type = MessageType.IMAGE;
        if (['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(extension)) {
          type = MessageType.VIDEO;
        }

        _setSelectedFile(file, type);
      }
    } catch (e) {
      debugPrint('Error picking media: $e');
    }
  }

  // File picker functionality
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = File(result.files.first.path!);
      final extension = result.files.first.extension?.toLowerCase();

      MessageType type = MessageType.FILE;
      if (extension != null) {
        if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
          type = MessageType.IMAGE;
        } else if (['mp4', 'mov', 'avi', 'mkv'].contains(extension)) {
          type = MessageType.VIDEO;
        } else if (['mp3', 'wav', 'aac', 'm4a'].contains(extension)) {
          type = MessageType.AUDIO;
        }
      }

      _setSelectedFile(file, type);
    }
  }

  // Audio recording functionality
  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    final status = await Permission.microphone.request();

    if (status == PermissionStatus.permanentlyDenied) {
      // Show dialog to open app settings
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Microphone Permission Required'),
          content: Text('Please enable microphone access in Settings'),
          actions: [
            TextButton(
              onPressed: () => openAppSettings(),
              child: Text('Open Settings'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        ),
      );
      return;
    }

    if (status != PermissionStatus.granted) {
      throw Exception("Microphone permission not granted");
    }
    final tempDir = await getTemporaryDirectory();
    _recordingPath =
        '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.aac';
    await _audioRecorder.openRecorder();
    await _audioRecorder.startRecorder(
      toFile: _recordingPath,
      codec: Codec.aacADTS,
    );

    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopRecording() async {
    await _audioRecorder.stopRecorder();

    if (_recordingPath != null) {
      _setSelectedFile(File(_recordingPath!), MessageType.AUDIO);
    }

    setState(() {
      _isRecording = false;
    });
  }

  void _setSelectedFile(File file, MessageType type) {
    setState(() {
      _selectedFile = SelectedFile(file: file, type: type);
    });

    // Initialize video controller if it's a video file
    if (type == MessageType.VIDEO) {
      _videoController = VideoPlayerController.file(file);
      _videoController!.initialize().then((_) {
        setState(() {});
      });
    }
  }

  void _clearSelectedFile() {
    if (mounted) {
      setState(() {
        _selectedFile = null;
      });
    }

    if (_videoController != null) {
      _videoController!.dispose();
      _videoController = null;
    }
  }

  String _decryptMessageContent(String encryptedContent) {
    try {
      return _encryptionService.decryptWithConversationKey(
        encryptedContent,
        widget.encryptionKey,
      );
    } catch (e) {
      return '[Message could not be decrypted]';
    }
  }

  TextMessageEntity _createDecryptedMessage(TextMessageEntity original) {
    String decryptedContent;

    if (original.type == MessageType.TEXT.name) {
      // Handle text messages as before
      decryptedContent = _decryptMessageContent(original.content);
    } else {
      // For non-text messages, you might want to keep a placeholder
      // The actual media will be loaded separately
      decryptedContent = "[${original.type} message]";
    }

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
      original.replyToId,
      original.senderId,
      original.type,
      original.encryptionMetadata,
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

  Future<void> _initiateCall(bool isVideo) async {
    final token = await AuthManager.getToken();
    String callToken;
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/calls'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'type': 'AUDIO', 'conversationId': widget.chatId}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      callToken = jsonDecode(response.body)['token'];
      StreamVideo.reset();
      StreamVideo(
        getStreamKey,
        user: User(
          info: UserInfo(
            name: widget.currentUser.fullName,
            id: widget.currentUser.id,
          ),
        ),
        userToken: callToken,
      );
      String roomId = jsonDecode(response.body)['call']['roomId'];

      try {
        var call = StreamVideo.instance.makeCall(
          callType: StreamCallType.defaultType(),
          id: roomId,
        );

        await call.getOrCreate();

        if (isVideo) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  VideoCallScreen(call: call, name: widget.name),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VoiceCallScreen(
                call: call,
                image: widget.imageUrl,
                name: widget.name,
              ),
            ),
          );
        }
      } catch (e) {
        debugPrint('Error joining or creating call: $e');
        debugPrint(e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              jsonDecode(
                e.toString(),
              )['message'].toString().replaceAll(RegExp(r'\[|\]'), ''),
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    }
  }

  Widget _buildSelectedFilePreview() {
    if (_selectedFile == null) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.all(getProportionateScreenWidth(15)),
      padding: EdgeInsets.all(getProportionateScreenWidth(10)),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(getProportionateScreenWidth(10)),
      ),
      child: Row(
        children: [
          // File preview
          Container(
            width: getProportionateScreenWidth(60),
            height: getProportionateScreenHeight(60),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                getProportionateScreenWidth(8),
              ),
              color: Colors.grey[300],
            ),
            child: _buildFilePreviewWidget(),
          ),
          SizedBox(width: getProportionateScreenWidth(10)),
          // File info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Text(
                //   _selectedFile!.file.path.split('/').last,
                //   style: TextStyle(
                //     fontSize: getProportionateScreenHeight(14),
                //     fontWeight: FontWeight.w500,
                //   ),
                //   maxLines: 1,
                //   overflow: TextOverflow.ellipsis,
                // ),
                Text(
                  _selectedFile!.type.name,
                  style: TextStyle(
                    fontSize: getProportionateScreenHeight(12),
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Remove button
          IconButton(
            onPressed: _clearSelectedFile,
            icon: Icon(Icons.close, size: getProportionateScreenWidth(20)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePreviewWidget() {
    if (_selectedFile == null) return SizedBox.shrink();

    switch (_selectedFile!.type) {
      case MessageType.IMAGE:
        return ClipRRect(
          borderRadius: BorderRadius.circular(getProportionateScreenWidth(8)),
          child: Image.file(
            _selectedFile!.file,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        );
      case MessageType.VIDEO:
        return ClipRRect(
          borderRadius: BorderRadius.circular(getProportionateScreenWidth(8)),
          child:
              _videoController != null && _videoController!.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: VideoPlayer(_videoController!),
                )
              : Container(
                  color: Colors.black,
                  child: Icon(Icons.video_library, color: Colors.white),
                ),
        );
      case MessageType.AUDIO:
        return Icon(Icons.audiotrack, size: getProportionateScreenWidth(30));
      case MessageType.FILE:
        return Icon(
          Icons.insert_drive_file,
          size: getProportionateScreenWidth(30),
        );
      default:
        return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final iconColor = isDark ? kWhite : kBlack;
    final dividerColor = isDark ? kGreyInputFillDark : kGreyInputBorder;
    final backgroundColor = isDark ? kBlackBg : kWhite;
    final inputFillColor = isDark
        ? kGreyInputFillDark
        : kGreyInputBorder.withValues(alpha: 0.3);
    final otherParticipant = widget.participants.firstWhere(
      (participant) => participant.userId != widget.currentUser.id,
      orElse: () => throw Exception("Current user not found in participants"),
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Row(
          children: [
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
                height: getProportionateScreenHeight(40),
                width: getProportionateScreenWidth(40),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: widget.imageUrl.isEmpty
                        ? NetworkImage(defaultAvatar)
                        : NetworkImage(widget.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(width: getProportionateScreenWidth(13)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: getProportionateScreenWidth(75),
                  child: Text(
                    widget.name,
                    style: TextStyle(
                      fontSize: getProportionateScreenHeight(16),
                      fontWeight: FontWeight.w600,
                      color: iconColor,
                    ),
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
                onTap: () {
                  _initiateCall(false);
                },
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
                onTap: () {
                  _initiateCall(true);
                },
                child: SvgPicture.asset(
                  "assets/icons/chat_video.svg",
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  width: getProportionateScreenWidth(24),
                  height: getProportionateScreenHeight(24),
                ),
              ),
            ),
          ),
          widget.isGroup
              ? Container()
              : Padding(
                  padding: EdgeInsets.only(
                    right: getProportionateScreenWidth(16),
                  ),
                  child: SizedBox(
                    height: getProportionateScreenHeight(24),
                    width: getProportionateScreenWidth(24),
                    child: InkWell(
                      onTap: _createSecretChat,
                      child: SvgPicture.asset(
                        "assets/icons/lock.svg",
                        colorFilter: ColorFilter.mode(
                          iconColor,
                          BlendMode.srcIn,
                        ),
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
                      builder: (context) => ChatDetailsScreen(
                        chatId: widget.chatId,
                        chatName: widget.name,
                        chatImage: widget.imageUrl,
                        chatHandle: widget.chatHandle,
                        currentUser: widget.currentUser,
                        isGroup: widget.isGroup,
                        participants: widget.participants,
                        isConversationMuted: widget.isConversationMuted,
                        isConversationBlockedForMe:
                            widget.isConversationBlockedForMe,
                      ),
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
            List<TextMessageEntity> requiredMessages = [];
            for (TextMessageEntity textMessageEntity in state.messages) {
              if (textMessageEntity.conversationId == widget.chatId) {
                final decryptedMessage = _createDecryptedMessage(
                  textMessageEntity,
                );
                requiredMessages.add(decryptedMessage);
              }
            }

            requiredMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

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
                      String image;
                      String username;
                      if (!widget.isGroup) {
                        image = widget.imageUrl;
                        username = '';
                      } else {
                        final participant = widget.participants.firstWhere(
                          (participant) =>
                              participant.userId ==
                              requiredMessages[index].senderId,
                        );
                        if (participant.user.profileImage == null) {
                          image = widget.imageUrl;
                        }
                        image = participant.user.profileImage!;
                        username = participant.user.username;
                      }
                      final message = requiredMessages[index];
                      return MessageBubble(
                        message: message,
                        isDark: isDark,
                        imageUrl: image,
                        currentUser: widget.currentUser,
                        username: username,
                        onReply: () => _setReply(message), // Add reply callback
                        allMessages:
                            requiredMessages, // Pass all messages for reply context
                      );
                    },
                  ),
                ),

                // Reply Preview
                _buildReplyPreview(),

                // File Preview
                _buildSelectedFilePreview(),

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
                              onTap: _takePicture,
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
                            // Text input - only show if no file selected
                            if (_selectedFile == null)
                              Expanded(
                                child: TextField(
                                  controller: _messageController,
                                  decoration: InputDecoration(
                                    hintText: "Message...",
                                    hintStyle: TextStyle(
                                      fontSize: getProportionateScreenHeight(
                                        14,
                                      ),
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    fillColor: Colors.transparent,
                                    filled: false,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: getProportionateScreenWidth(
                                        16,
                                      ),
                                      vertical: getProportionateScreenHeight(
                                        12,
                                      ),
                                    ),
                                  ),
                                  style: TextStyle(
                                    color: iconColor,
                                    fontSize: getProportionateScreenHeight(14),
                                  ),
                                  onSubmitted: (_) =>
                                      _sendMessage(MessageType.TEXT),
                                ),
                              ),
                            // File selected indicator
                            if (_selectedFile != null)
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: getProportionateScreenWidth(16),
                                    vertical: getProportionateScreenHeight(12),
                                  ),
                                  child: Text(
                                    '${_selectedFile!.type.name} selected',
                                    style: TextStyle(
                                      color: iconColor,
                                      fontSize: getProportionateScreenHeight(
                                        14,
                                      ),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ),
                            // Action buttons
                            if (_selectedFile != null)
                              // Send button for files
                              InkWell(
                                onTap: _isSending
                                    ? null
                                    : () => _sendMessage(_selectedFile!.type),
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
                                    height: getProportionateScreenHeight(21.27),
                                    width: getProportionateScreenWidth(21.27),
                                  ),
                                ),
                              )
                            else
                              // Text message controls
                              ValueListenableBuilder<TextEditingValue>(
                                valueListenable: _messageController,
                                builder: (context, value, child) {
                                  final hasText = value.text.trim().isNotEmpty;
                                  return Row(
                                    children: [
                                      // Send button for text
                                      if (hasText)
                                        InkWell(
                                          onTap: _isSending
                                              ? null
                                              : () => _sendMessage(
                                                  MessageType.TEXT,
                                                ),
                                          child: Container(
                                            width: getProportionateScreenWidth(
                                              55,
                                            ),
                                            height:
                                                getProportionateScreenHeight(
                                                  34,
                                                ),
                                            padding: EdgeInsets.symmetric(
                                              vertical:
                                                  getProportionateScreenHeight(
                                                    5,
                                                  ),
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: kChatBubbleGradient,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    getProportionateScreenWidth(
                                                      20,
                                                    ),
                                                  ),
                                            ),
                                            child: SvgPicture.asset(
                                              "assets/icons/send.svg",
                                              height:
                                                  getProportionateScreenHeight(
                                                    21.27,
                                                  ),
                                              width:
                                                  getProportionateScreenWidth(
                                                    21.27,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      // Attachment icons
                                      if (!hasText) ...[
                                        InkWell(
                                          onTap: _pickFile,
                                          child: SvgPicture.asset(
                                            "assets/icons/chat_paperclip.svg",
                                            height:
                                                getProportionateScreenHeight(
                                                  21.27,
                                                ),
                                            width: getProportionateScreenWidth(
                                              21.27,
                                            ),
                                            colorFilter: ColorFilter.mode(
                                              iconColor,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: getProportionateScreenWidth(8),
                                        ),
                                        InkWell(
                                          onTap: _toggleRecording,
                                          child: Container(
                                            padding: _isRecording
                                                ? EdgeInsets.all(2)
                                                : EdgeInsets.zero,
                                            decoration: _isRecording
                                                ? BoxDecoration(
                                                    color: Colors.red,
                                                    shape: BoxShape.circle,
                                                  )
                                                : null,
                                            child: SvgPicture.asset(
                                              "assets/icons/chat_mic.svg",
                                              height:
                                                  getProportionateScreenHeight(
                                                    21.27,
                                                  ),
                                              width:
                                                  getProportionateScreenWidth(
                                                    21.27,
                                                  ),
                                              colorFilter: _isRecording
                                                  ? ColorFilter.mode(
                                                      Colors.white,
                                                      BlendMode.srcIn,
                                                    )
                                                  : ColorFilter.mode(
                                                      iconColor,
                                                      BlendMode.srcIn,
                                                    ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: getProportionateScreenWidth(8),
                                        ),
                                        InkWell(
                                          onTap: _pickMediaFromGallery,
                                          child: SvgPicture.asset(
                                            "assets/icons/chat_image.svg",
                                            height:
                                                getProportionateScreenHeight(
                                                  21.27,
                                                ),
                                            width: getProportionateScreenWidth(
                                              21.27,
                                            ),
                                            colorFilter: ColorFilter.mode(
                                              iconColor,
                                              BlendMode.srcIn,
                                            ),
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
    _audioRecorder.closeRecorder();

    // Make sure to release video resources
    if (_videoController != null) {
      _videoController!.dispose();
      _videoController = null;
    }

    super.dispose();
  }

  Future<File> compressImage(File file) async {
    final compressedBytes = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: 50, // adjust as needed
    );

    final compressedFile = File('${file.path}_compressed.jpg')
      ..writeAsBytesSync(compressedBytes!);
    return compressedFile;
  }

  Future<File> compressVideo(File file) async {
    final compressedVideo = await VideoCompress.compressVideo(
      file.path,
      quality: VideoQuality.MediumQuality,
      deleteOrigin: false,
      includeAudio: true,
    );

    if (compressedVideo != null) {
      return File(compressedVideo.path!);
    }
    return file; // Return original if compression fails
  }
}

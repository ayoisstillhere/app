import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app/features/chat/presentation/pages/video_call_screen.dart';
import 'package:app/features/chat/presentation/pages/voice_call_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_rsa/fast_rsa.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';
import 'package:video_compress/video_compress.dart';

import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:app/features/chat/domain/entities/get_messages_response_entity.dart'
    hide User;
import 'package:app/features/chat/domain/entities/text_message_entity.dart';
import 'package:app/features/chat/presentation/pages/chat_details_screen.dart';
import 'package:app/services/file_encryptor.dart';

import '../../../../components/default_button.dart';
import '../../../../constants.dart';
import '../../../../services/auth_manager.dart';
import '../../../../services/encryption_service.dart';
import '../../../../services/secret_chat_encryption_service.dart';
import '../../../../size_config.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
import '../cubit/chat_cubit.dart';
import '../widgets/message_bubble.dart';

import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

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

class SecretChatScreen extends StatefulWidget {
  const SecretChatScreen({
    super.key,
    required this.chatId,
    required this.name,
    required this.imageUrl,
    required this.currentUser,
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
  final String? chatHandle;
  final bool isGroup;
  final List<Participant> participants;
  final bool isConversationMuted;
  final bool isConversationBlockedForMe;

  @override
  State<SecretChatScreen> createState() => _SecretChatScreenState();
}

class _SecretChatScreenState extends State<SecretChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final EncryptionService _encryptionService;
  late final SecretChatEncryptionService _secretChatEncryptionService;
  final ImagePicker _imagePicker = ImagePicker();
  late FlutterSoundRecorder _audioRecorder;

  SelectedFile? _selectedFile;
  bool _isRecording = false;
  bool _isSending = false;
  String? _recordingPath;
  Player? _player;
  VideoController? _videoController;
  bool _showSecretChatOverlay = true;
  String? _conversationKey;
  String conversationId = '';

  final _noScreenshot = NoScreenshot.instance;

  // Add reply state
  TextMessageEntity? _replyToMessage;

  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;

  bool _isLoadingKey = true;
  bool _isRecreatingChat = false;

  @override
  void initState() {
    super.initState();
    conversationId = widget.chatId;
    _initializeServices();
    BlocProvider.of<ChatCubit>(context).getTextMessages();
    _markAllAssRead();
    _scrollToBottom();
    _decryptConversationKey();
    disableScreenshot();
  }

  Future<void> _recreateSecretChat({bool deleteFormerChat = true}) async {
    try {
      if (widget.isGroup) {
        return;
      }

      setState(() {
        _isRecreatingChat = true;
      });
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
        // Successfully recreated the chat
        final responseData = jsonDecode(response.body);

        // Update the current conversation key
        _conversationKey = conversationKey;
        conversationId = responseData['id'];

        // Refresh messages
        BlocProvider.of<ChatCubit>(context).getTextMessages();

        // _showErrorSnackBar("Secret chat recreated successfully");
      } else {
        _showErrorSnackBar("Failed to recreate secret chat");
      }
    } catch (e) {
      print('Error recreating secret chat: $e');
      _showErrorSnackBar("Error recreating secret chat");
    } finally {
      if (mounted) {
        setState(() {
          _isRecreatingChat = false;
        });
      }
    }
  }

  void disableScreenshot() async {
    bool result = await _noScreenshot.screenshotOff();
    debugPrint('Screenshot Off: $result');
  }

  void enableScreenshot() async {
    bool result = await _noScreenshot.screenshotOn();
    debugPrint('Enable Screenshot: $result');
  }

  Future<void> _decryptConversationKey() async {
    setState(() {
      _isLoadingKey = true;
    });

    try {
      final participant = widget.participants.firstWhere(
        (participant) => participant.userId == widget.currentUser.id,
        orElse: () => throw Exception("Current user not found in participants"),
      );
      final encryptedConversationKey = participant.mySecretConversationKey!;

      // Decrypt the conversation key using the private key
      _conversationKey = await _secretChatEncryptionService
          .decryptConversationKey(encryptedConversationKey);

      setState(() {
        _isLoadingKey = false;
      });
    } catch (e) {
      print('Error decrypting conversation key: $e');

      if (mounted) {
        setState(() {
          _isLoadingKey = false;
        });
        // Instead of navigating back, recreate the secret chat directly
        await _recreateSecretChat(deleteFormerChat: true);
      }
    }
  }

  void _initializeServices() {
    _encryptionService = EncryptionService();
    _encryptionService.setSecretKey(
      '967f042a1b97cb7ec81f7b7825deae4b05a661aae329b738d7068b044de6f56a',
    );
    _audioRecorder = FlutterSoundRecorder();
    _secretChatEncryptionService = SecretChatEncryptionService();
    _initializeAudioRecorder();
  }

  Future<void> _initializeAudioRecorder() async {
    await _audioRecorder.openRecorder();
  }

  Future<void> _markAllAssRead() async {
    final token = await AuthManager.getToken();
    final uri = Uri.parse(
      '$baseUrl/api/v1/chat/conversations/$conversationId/mark-all-read',
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
      request.fields['conversationId'] = conversationId;
      request.fields['type'] = type.name;
      request.fields['deleteAfter24Hours'] = 'false';
      request.fields['isForwarded'] = 'false';

      if (type == MessageType.TEXT) {
        // Handle text messages
        if (_messageController.text.trim().isEmpty) return;

        final encryptedContent = _secretChatEncryptionService.encryptMessage(
          _messageController.text.trim(),
          _conversationKey!,
        );
        request.fields['content'] = encryptedContent;
      } else {
        // Handle file messages
        if (_selectedFile == null) return;

        File fileToSend = _selectedFile!.file;

        if (type == MessageType.IMAGE || type == MessageType.VIDEO) {
          fileToSend = await compressImage(File(_selectedFile!.file.path));
        }

        final encryptedFile = await FileEncryptor.encryptFile(fileToSend);

        // Add encrypted file to request
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
        // border: Border(
        //   left: BorderSide(
        //     color: Colors.blue,
        //     width: getProportionateScreenWidth(3),
        //   ),
        // ),
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
      bitRate: 128000, // Higher bit rate for better quality
      sampleRate: 44100, // Standard high-quality sample rate
    );

    // Start the timer
    _recordingDuration = Duration.zero;
    _recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _recordingDuration = Duration(seconds: timer.tick);
      });
    });

    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopRecording() async {
    await _audioRecorder.stopRecorder();

    // Stop the timer
    _recordingTimer?.cancel();
    _recordingTimer = null;

    if (_recordingPath != null) {
      _setSelectedFile(File(_recordingPath!), MessageType.AUDIO);
    }

    setState(() {
      _isRecording = false;
      _recordingDuration = Duration.zero;
    });
  }

  void _cancelRecording() {
    if (_isRecording) {
      setState(() {
        _isRecording = false;
        _recordingDuration = Duration.zero;
      });
      // Stop any recording processes
      // Add your recording cancellation logic here
      print("Recording cancelled");
    }
  }

  // Add this method to format recording duration
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> _setSelectedFile(File file, MessageType type) async {
    // Dispose of any existing video controller
    if (_player != null) {
      _player!.dispose();
      _player = null;
    }
    if (_videoController != null) {
      _videoController = null;
    }

    setState(() {
      _selectedFile = SelectedFile(file: file, type: type);
    });

    // Initialize video player if it's a video file
    if (type == MessageType.VIDEO) {
      _player = Player();
      _videoController = VideoController(_player!);
      await _player!.open(Media('file://${file.path}'));
    }
  }

  void _clearSelectedFile() {
    // Dispose of any existing video controller
    if (_player != null) {
      _player!.dispose();
      _player = null;
    }
    if (_videoController != null) {
      _videoController = null;
    }

    setState(() {
      _selectedFile = null;
    });
  }

  String _decryptMessageContent(String encryptedContent) {
    try {
      return _secretChatEncryptionService.decryptMessage(
        encryptedContent,
        _conversationKey!,
      );
    } catch (e) {
      return '[Secret]';
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
      body: json.encode({
        'type': isVideo ? 'VIDEO' : 'AUDIO',
        'conversationId': conversationId,
      }),
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
              builder: (context) => VideoCallScreen(
                call: call,
                name: widget.name,
                image: widget.imageUrl,
                currentUser: widget.currentUser,
              ),
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
                currentUser: widget.currentUser,
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
            icon: Icon(
              Icons.close,
              size: getProportionateScreenWidth(20),
              color: Colors.grey[600],
            ),
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
          child: _player != null && _videoController != null
              ? AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Video(
                    controller: _videoController!,
                    fit: BoxFit.cover,
                    aspectRatio: 16 / 9,
                  ),
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
                      onTap: () {},
                      child: SvgPicture.asset(
                        "assets/icons/lock_secret.svg",
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
                        chatId: conversationId,
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
      body: _isLoadingKey
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                BlocBuilder<ChatCubit, ChatState>(
                  builder: (context, state) {
                    if (state is ChatLoaded) {
                      List<TextMessageEntity> requiredMessages = [];
                      for (TextMessageEntity textMessageEntity
                          in state.messages) {
                        if (textMessageEntity.conversationId ==
                            conversationId) {
                          final decryptedMessage = _createDecryptedMessage(
                            textMessageEntity,
                          );
                          requiredMessages.add(decryptedMessage);
                        }
                      }

                      requiredMessages.sort(
                        (a, b) => a.createdAt.compareTo(b.createdAt),
                      );

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
                                  final participant = widget.participants
                                      .firstWhere(
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
                                  onReply: () =>
                                      _setReply(message), // Add reply callback
                                  allMessages:
                                      requiredMessages, // Pass all messages for reply context
                                  getSenderName: (String userId) {
                                    // Create a wrapper function that takes just a userId
                                    final dummyMessage = TextMessageEntity(
                                      '', // content
                                      '', // conversationId
                                      Timestamp.now(), // createdAt
                                      null, // expiredAt
                                      '', // id
                                      false, // isForwarded
                                      false, // isViewOnce
                                      '', // mediaUrl
                                      {}, // reactions
                                      null, // replyToId
                                      userId, // senderId - this is what we need
                                      'TEXT', // type
                                      null, // encryptionMetadata
                                    );
                                    return _getMessageSenderName(dummyMessage);
                                  },
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
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 300),
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
                                      // Camera button - hide when recording
                                      if (!_isRecording)
                                        Padding(
                                          padding: EdgeInsets.only(
                                            bottom:
                                                getProportionateScreenHeight(0),
                                          ),
                                          child: InkWell(
                                            onTap: _takePicture,
                                            child: Container(
                                              padding: EdgeInsets.all(
                                                getProportionateScreenWidth(8),
                                              ),
                                              height:
                                                  getProportionateScreenHeight(
                                                    39,
                                                  ),
                                              width:
                                                  getProportionateScreenWidth(
                                                    39,
                                                  ),
                                              decoration: BoxDecoration(
                                                gradient: kChatBubbleGradient,
                                                shape: BoxShape.circle,
                                              ),
                                              child: SvgPicture.asset(
                                                "assets/icons/chat_camera.svg",
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
                                        ),

                                      // Recording UI with slide to cancel
                                      if (_isRecording) ...[
                                        // Recording indicator with pulsing animation
                                        Padding(
                                          padding: EdgeInsets.only(
                                            left: getProportionateScreenWidth(
                                              8,
                                            ),
                                            bottom:
                                                getProportionateScreenHeight(5),
                                          ),
                                          child: Container(
                                            height:
                                                getProportionateScreenHeight(
                                                  39,
                                                ),
                                            width: getProportionateScreenWidth(
                                              39,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: AnimatedContainer(
                                                duration: Duration(
                                                  milliseconds: 500,
                                                ),
                                                height:
                                                    getProportionateScreenHeight(
                                                      12,
                                                    ),
                                                width:
                                                    getProportionateScreenWidth(
                                                      12,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),

                                        // Recording text and duration with slide to cancel functionality
                                        Expanded(
                                          child: GestureDetector(
                                            onPanUpdate: (details) {
                                              // Check if sliding left (negative delta)
                                              if (details.delta.dx < -5) {
                                                _cancelRecording();
                                              }
                                            },
                                            onTap: () {
                                              // Optional: cancel on tap as well
                                              _cancelRecording();
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    getProportionateScreenWidth(
                                                      12,
                                                    ),
                                                vertical:
                                                    getProportionateScreenHeight(
                                                      12,
                                                    ),
                                              ),
                                              decoration: BoxDecoration(
                                                color: inputFillColor,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      getProportionateScreenWidth(
                                                        20,
                                                      ),
                                                    ),
                                              ),
                                              child: Row(
                                                children: [
                                                  // Slide to cancel text with animation
                                                  Expanded(
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.chevron_left,
                                                          color:
                                                              Colors.grey[600],
                                                          size:
                                                              getProportionateScreenWidth(
                                                                18,
                                                              ),
                                                        ),
                                                        SizedBox(
                                                          width:
                                                              getProportionateScreenWidth(
                                                                4,
                                                              ),
                                                        ),
                                                        Text(
                                                          "Slide to cancel",
                                                          style: TextStyle(
                                                            color: Colors
                                                                .grey[600],
                                                            fontSize:
                                                                getProportionateScreenHeight(
                                                                  14,
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  // Recording duration
                                                  Text(
                                                    _formatDuration(
                                                      _recordingDuration,
                                                    ),
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize:
                                                          getProportionateScreenHeight(
                                                            16,
                                                          ),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),

                                        SizedBox(
                                          width: getProportionateScreenWidth(8),
                                        ),

                                        // Stop recording button
                                        InkWell(
                                          onTap: _stopRecording,
                                          child: Container(
                                            padding: EdgeInsets.all(
                                              getProportionateScreenWidth(8),
                                            ),
                                            height:
                                                getProportionateScreenHeight(
                                                  39,
                                                ),
                                            width: getProportionateScreenWidth(
                                              39,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.send,
                                              color: Colors.white,
                                              size: getProportionateScreenWidth(
                                                20,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]
                                      // Normal UI (when not recording)
                                      else ...[
                                        // Text input - only show if no file selected
                                        if (_selectedFile == null)
                                          Expanded(
                                            child: TextField(
                                              controller: _messageController,
                                              maxLines: null,
                                              minLines: 1,
                                              textAlignVertical:
                                                  TextAlignVertical.center,
                                              decoration: InputDecoration(
                                                hintText: "Message...",
                                                hintStyle: TextStyle(
                                                  fontSize:
                                                      getProportionateScreenHeight(
                                                        16,
                                                      ),
                                                ),
                                                border: InputBorder.none,
                                                enabledBorder: InputBorder.none,
                                                focusedBorder: InputBorder.none,
                                                errorBorder: InputBorder.none,
                                                disabledBorder:
                                                    InputBorder.none,
                                                fillColor: Colors.transparent,
                                                filled: false,
                                                contentPadding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      getProportionateScreenWidth(
                                                        16,
                                                      ),
                                                  vertical:
                                                      getProportionateScreenHeight(
                                                        12,
                                                      ),
                                                ),
                                              ),
                                              style: TextStyle(
                                                color: iconColor,
                                                fontSize:
                                                    getProportionateScreenHeight(
                                                      18,
                                                    ),
                                              ),
                                              onSubmitted: (_) => _sendMessage(
                                                MessageType.TEXT,
                                              ),
                                            ),
                                          ),

                                        // File selected indicator
                                        if (_selectedFile != null)
                                          Expanded(
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    getProportionateScreenWidth(
                                                      16,
                                                    ),
                                                vertical:
                                                    getProportionateScreenHeight(
                                                      12,
                                                    ),
                                              ),
                                              child: Text(
                                                '${_selectedFile!.type.name} selected',
                                                style: TextStyle(
                                                  color: iconColor,
                                                  fontSize:
                                                      getProportionateScreenHeight(
                                                        16,
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
                                                : () => _sendMessage(
                                                    _selectedFile!.type,
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
                                          )
                                        else
                                          // Text message controls
                                          ValueListenableBuilder<
                                            TextEditingValue
                                          >(
                                            valueListenable: _messageController,
                                            builder: (context, value, child) {
                                              final hasText = value.text
                                                  .trim()
                                                  .isNotEmpty;
                                              return Padding(
                                                padding: EdgeInsets.only(
                                                  bottom:
                                                      getProportionateScreenHeight(
                                                        0,
                                                      ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    // Send button for text
                                                    if (hasText)
                                                      InkWell(
                                                        onTap: _isSending
                                                            ? null
                                                            : () =>
                                                                  _sendMessage(
                                                                    MessageType
                                                                        .TEXT,
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
                                                          width:
                                                              getProportionateScreenWidth(
                                                                21.27,
                                                              ),
                                                          colorFilter:
                                                              ColorFilter.mode(
                                                                iconColor,
                                                                BlendMode.srcIn,
                                                              ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width:
                                                            getProportionateScreenWidth(
                                                              8,
                                                            ),
                                                      ),
                                                      InkWell(
                                                        onTap: _toggleRecording,
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
                                                          colorFilter:
                                                              ColorFilter.mode(
                                                                iconColor,
                                                                BlendMode.srcIn,
                                                              ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width:
                                                            getProportionateScreenWidth(
                                                              8,
                                                            ),
                                                      ),
                                                      InkWell(
                                                        onTap:
                                                            _pickMediaFromGallery,
                                                        child: SvgPicture.asset(
                                                          "assets/icons/chat_image.svg",
                                                          height:
                                                              getProportionateScreenHeight(
                                                                21.27,
                                                              ),
                                                          width:
                                                              getProportionateScreenWidth(
                                                                21.27,
                                                              ),
                                                          colorFilter:
                                                              ColorFilter.mode(
                                                                iconColor,
                                                                BlendMode.srcIn,
                                                              ),
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                      ],
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

                // Secret Chat Overlay
                if (_showSecretChatOverlay)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showSecretChatOverlay = false;
                      });
                    },
                    child: Container(
                      color: Colors.black.withOpacity(0.7),
                      child: Center(
                        child: Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: getProportionateScreenWidth(20),
                          ),
                          padding: EdgeInsets.all(
                            getProportionateScreenWidth(30),
                          ),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(
                              getProportionateScreenWidth(20),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Secret chat is enabled",
                                style: TextStyle(
                                  fontSize: getProportionateScreenHeight(20),
                                  fontWeight: FontWeight.w500,
                                  color: iconColor,
                                ),
                              ),
                              SizedBox(
                                height: getProportionateScreenHeight(20),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "• ",
                                    style: TextStyle(
                                      fontSize: getProportionateScreenHeight(
                                        15,
                                      ),
                                      fontWeight: FontWeight.w500,
                                      color: iconColor,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "Screenshots cannot be taken",
                                      style: TextStyle(
                                        fontSize: getProportionateScreenHeight(
                                          15,
                                        ),
                                        fontWeight: FontWeight.w500,
                                        color: iconColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: getProportionateScreenHeight(10),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "• ",
                                    style: TextStyle(
                                      fontSize: getProportionateScreenHeight(
                                        15,
                                      ),
                                      fontWeight: FontWeight.w500,
                                      color: iconColor,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "Messages cannot be forwarded out of the chat",
                                      style: TextStyle(
                                        fontSize: getProportionateScreenHeight(
                                          15,
                                        ),
                                        fontWeight: FontWeight.w500,
                                        color: iconColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: getProportionateScreenHeight(30),
                              ),
                              DefaultButton(
                                text: "Disable Secret Chat",
                                press: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                // Show recreating chat overlay if needed
                if (_isRecreatingChat)
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            "Recreating secret chat...",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
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
    _audioRecorder.closeRecorder();
    _recordingTimer?.cancel(); // Add this line

    // Dispose media kit resources
    if (_player != null) {
      _player!.dispose();
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
      quality: VideoQuality.LowQuality,
      deleteOrigin: false,
      includeAudio: true,
    );

    if (compressedVideo != null) {
      return File(compressedVideo.path!);
    }
    return file; // Return original if compression fails
  }
}

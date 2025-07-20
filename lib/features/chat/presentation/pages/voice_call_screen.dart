import 'package:app/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../constants.dart';
import '../../../../services/auth_manager.dart';
import '../../../chat/data/models/get_messages_response_model.dart';
import '../../../chat/domain/entities/get_messages_response_entity.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../widgets/add_person_dialog.dart';

class VoiceCallScreen extends StatefulWidget {
  final Call call;
  final String image;
  final String name;
  final UserEntity currentUser;
  final String callId;

  const VoiceCallScreen({
    super.key,
    required this.call,
    required this.image,
    required this.name,
    required this.currentUser,
    required this.callId,
  });

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen> {
  bool _isMicrophoneEnabled = true;
  bool _isSpeakerEnabled = false;
  bool _isConnected = false;

  // Timer for call duration
  Timer? _callTimer;
  Duration _callDuration = Duration.zero;
  DateTime? _callStartTime;

  // Conversations state
  List<Conversation> _allConversations = [];
  bool _isLoadingConversations = false;

  // Participants state
  List<CallParticipantState> _participants = [];

  @override
  void initState() {
    super.initState();
    widget.call.join();

    // Listen for call state changes
    widget.call.state.listen((callState) {
      final hasOtherParticipants = callState.callParticipants.length > 1;

      if (hasOtherParticipants && !_isConnected) {
        _isConnected = true;
        _startCallTimer();
      } else if (!hasOtherParticipants && _isConnected) {
        _isConnected = false;
        _stopCallTimer();
      }

      if (mounted) {
        setState(() {
          _isMicrophoneEnabled =
              callState.localParticipant?.isAudioEnabled ?? true;
          _participants = callState.callParticipants.toList();
        });
      }
    });

    _fetchAllConversations();
  }

  void _startCallTimer() {
    _callStartTime = DateTime.now();
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callDuration = DateTime.now().difference(_callStartTime!);
        });
      }
    });
  }

  void _stopCallTimer() {
    _callTimer?.cancel();
    _callTimer = null;
    _callDuration = Duration.zero;
    _callStartTime = null;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  Future<void> _fetchAllConversations() async {
    setState(() => _isLoadingConversations = true);

    try {
      final token = await AuthManager.getToken();
      const int pageSize = 50;
      String url =
          '$baseUrl/api/v1/chat/conversations?page=1&limit=$pageSize&isSecret=false';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = GetMessageResponseModel.fromJson(
          jsonDecode(response.body),
        );

        setState(() {
          _allConversations = responseData.conversations
              .where(
                (conversation) =>
                    conversation.lastMessage != null &&
                    !conversation.isConversationArchivedForMe,
              )
              .toList();
        });
      } else {
        _showErrorSnackBar('Failed to load conversations: ${response.body}');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load conversations: $e');
    } finally {
      setState(() => _isLoadingConversations = false);
    }
  }

  void _showAddPersonDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddPersonDialog(
          conversations: _allConversations,
          currentUser: widget.currentUser,
          isLoading: _isLoadingConversations,
          onAddPerson: _addPersonToCall,
          onRefresh: _fetchAllConversations,
        );
      },
    );
  }

  Future<void> _addPersonToCall(String conversationId) async {
    try {
      final token = await AuthManager.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/calls/${widget.callId}/conversation'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'conversationId': conversationId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccessSnackBar('Person added to call successfully');
      } else {
        _showErrorSnackBar('Failed to add person to call: ${response.body}');
      }
    } catch (e) {
      _showErrorSnackBar('Error adding person to call: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamCallContainer(
        call: widget.call,
        callConnectOptions: CallConnectOptions(
          microphone: TrackOption.enabled(),
          camera: TrackOption.disabled(),
        ),
        callContentBuilder: (context, call, callState) {
          return _buildCustomCallContent(context, call, callState);
        },
      ),
    );
  }

  Widget _buildCustomCallContent(
    BuildContext context,
    Call call,
    CallState callState,
  ) {
    return Stack(
      children: [
        // Background
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
        ),

        // Top bar with back button and menu
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  call.end();
                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              IconButton(
                onPressed: () {
                  // Handle menu action
                },
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
        ),

        // Privacy indicator
        Positioned(
          top: MediaQuery.of(context).padding.top + 80,
          left: 0,
          right: 0,
          child: _buildPrivacyIndicator(),
        ),

        // Main content area - participant info and audio visualization
        Positioned(
          top: MediaQuery.of(context).size.height * 0.2,
          left: 0,
          right: 0,
          bottom: MediaQuery.of(context).size.height * 0.25,
          child: _buildParticipantsSection(),
        ),

        // Bottom controls
        Positioned(
          bottom: MediaQuery.of(context).padding.bottom + 40,
          left: 0,
          right: 0,
          child: _buildBottomControls(call),
        ),
      ],
    );
  }

  Widget _buildPrivacyIndicator() {
    final participantCount = _participants.length;
    final otherParticipants = _participants
        .where((p) => p.userId != widget.currentUser.id)
        .toList();

    String privacyText;
    if (participantCount <= 2) {
      final otherName = otherParticipants.isNotEmpty
          ? otherParticipants.first.name ?? 'Unknown'
          : widget.name;
      privacyText =
          'This session is encrypted and private. Only you and\n$otherName are connected.';
    } else {
      privacyText =
          'This session is encrypted and private.\n$participantCount participants connected.';
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.lock, color: Colors.white, size: 16),
        const SizedBox(height: 8),
        Text(
          privacyText,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: getProportionateScreenHeight(12),
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantsSection() {
    final participantCount = _participants.length;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Participants display
        _buildParticipantsDisplay(),

        const SizedBox(height: 24),

        // Call status
        Text(
          _isConnected ? _formatDuration(_callDuration) : 'Connecting...',
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),

        const SizedBox(height: 40),

        // Audio visualization
        SvgPicture.asset(
          "assets/icons/voice_call_wave.svg",
          height: getProportionateScreenHeight(26),
          width: getProportionateScreenWidth(157),
        ),
      ],
    );
  }

  Widget _buildParticipantsDisplay() {
    final otherParticipants = _participants
        .where((p) => p.userId != widget.currentUser.id)
        .toList();

    if (otherParticipants.isEmpty) {
      // No other participants, show original layout
      return Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 2),
              image: DecorationImage(
                image: NetworkImage(widget.image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    } else if (otherParticipants.length == 1) {
      // One other participant, show single large profile
      final participant = otherParticipants.first;
      return Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 2),
              image: participant.image!.isEmpty
                  ? DecorationImage(
                      image: NetworkImage(participant.image!),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: participant.image!.isEmpty ? Colors.grey[600] : null,
            ),
            child: participant.image == null
                ? Icon(Icons.person, size: 60, color: Colors.white)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            participant.name ?? 'Unknown',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    } else if (otherParticipants.length <= 4) {
      // 2-4 other participants, show grid layout
      return Column(
        children: [
          _buildParticipantGrid(otherParticipants),
          const SizedBox(height: 16),
          Text(
            '${otherParticipants.length + 1} participants',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    } else {
      // 5+ other participants, show compact layout with overflow
      return Column(
        children: [
          _buildCompactParticipantLayout(otherParticipants),
          const SizedBox(height: 16),
          Text(
            '${otherParticipants.length + 1} participants',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildParticipantGrid(List<CallParticipantState> participants) {
    final count = participants.length;

    if (count == 2) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: participants
            .map((p) => _buildParticipantAvatar(p, 80))
            .toList(),
      );
    } else if (count == 3) {
      return Column(
        children: [
          _buildParticipantAvatar(participants[0], 80),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildParticipantAvatar(participants[1], 80),
              _buildParticipantAvatar(participants[2], 80),
            ],
          ),
        ],
      );
    } else if (count == 4) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildParticipantAvatar(participants[0], 70),
              _buildParticipantAvatar(participants[1], 70),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildParticipantAvatar(participants[2], 70),
              _buildParticipantAvatar(participants[3], 70),
            ],
          ),
        ],
      );
    }

    return Container();
  }

  Widget _buildCompactParticipantLayout(
    List<CallParticipantState> participants,
  ) {
    final displayParticipants = participants.take(5).toList();
    final remainingCount = participants.length - 5;

    return Column(
      children: [
        // First row - 3 participants
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: displayParticipants
              .take(3)
              .map((p) => _buildParticipantAvatar(p, 60))
              .toList(),
        ),
        const SizedBox(height: 12),
        // Second row - 2 participants + overflow indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (displayParticipants.length > 3)
              _buildParticipantAvatar(displayParticipants[3], 60),
            if (displayParticipants.length > 4)
              _buildParticipantAvatar(displayParticipants[4], 60),
            if (remainingCount > 0) _buildOverflowIndicator(remainingCount, 60),
          ],
        ),
      ],
    );
  }

  Widget _buildParticipantAvatar(
    CallParticipantState participant,
    double size,
  ) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 1.5),
                image: participant.image!.isEmpty
                    ? DecorationImage(
                        image: NetworkImage(participant.image!),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: participant.image!.isEmpty ? Colors.grey[600] : null,
              ),
              child: participant.image!.isEmpty
                  ? Icon(Icons.person, size: size * 0.5, color: Colors.white)
                  : null,
            ),
            // Mic indicator
            if (!participant.isAudioEnabled)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: size * 0.3,
                  height: size * 0.3,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mic_off,
                    size: size * 0.2,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: size + 10,
          child: Text(
            participant.name ?? 'Unknown',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: size > 70 ? 14 : 12,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildOverflowIndicator(int count, double size) {
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24, width: 1.5),
            color: Colors.white24,
          ),
          child: Center(
            child: Text(
              '+$count',
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.25,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: size + 10,
          child: Text(
            'more',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: size > 70 ? 14 : 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls(Call call) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Microphone toggle
          _buildControlButton(
            icon: _isMicrophoneEnabled ? Icons.mic : Icons.mic_off,
            isEnabled: _isMicrophoneEnabled,
            onPressed: () async {
              try {
                if (_isMicrophoneEnabled) {
                  await call.setMicrophoneEnabled(enabled: false);
                } else {
                  await call.setMicrophoneEnabled(enabled: true);
                }
                // State will be updated through the call state listener
              } catch (e) {
                debugPrint('Failed to toggle microphone: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Unable to toggle microphone'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),

          // Speaker toggle
          _buildControlButton(
            icon: _isSpeakerEnabled ? Icons.volume_up : Icons.volume_off,
            isEnabled: _isSpeakerEnabled,
            onPressed: () async {
              try {
                if (Theme.of(context).platform == TargetPlatform.iOS) {
                  await RtcMediaDeviceNotifier.instance
                      .triggeriOSAudioRouteSelectionUI();
                } else {
                  final audioOutputsResult = await RtcMediaDeviceNotifier
                      .instance
                      .audioOutputs();
                  audioOutputsResult.fold(
                    success: (audioOutputsSuccess) {
                      final audioOutputs = audioOutputsSuccess.data;
                      if (audioOutputs.isNotEmpty) {
                        final currentOutput =
                            call.state.value.audioOutputDevice;
                        final nextDevice = audioOutputs.firstWhere(
                          (device) => device.id != currentOutput?.id,
                          orElse: () => audioOutputs.first,
                        );
                        call.setAudioOutputDevice(nextDevice).then((result) {
                          result.fold(
                            success: (success) {
                              setState(() {
                                _isSpeakerEnabled = !_isSpeakerEnabled;
                              });
                            },
                            failure: (failure) {
                              print(
                                'Failed to set audio output: ${failure.error.message}',
                              );
                            },
                          );
                        });
                      }
                    },
                    failure: (failure) {
                      print(
                        'Failed to get audio outputs: ${failure.error.message}',
                      );
                    },
                  );
                }
              } catch (e) {
                print('Error toggling speaker: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Unable to toggle speaker'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),

          // Add person to call button
          _buildControlButton(
            icon: Icons.person_add,
            isEnabled: true,
            onPressed: _showAddPersonDialog,
          ),

          // End call
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () async {
                await call.end();
                if (mounted) {
                  Navigator.of(context).pop();
                }
              },
              icon: const Icon(Icons.call_end, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isEnabled ? Colors.white24 : Colors.white10,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: isEnabled ? Colors.white : Colors.white54,
          size: 28,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    super.dispose();
  }
}

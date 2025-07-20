import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stream_video_flutter/stream_video_flutter.dart';
import 'dart:async';

import '../../../../constants.dart';
import '../../../../services/auth_manager.dart';
import '../../../../size_config.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../data/models/get_messages_response_model.dart';
import '../../domain/entities/get_messages_response_entity.dart';
import '../widgets/add_person_dialog.dart';

class VideoCallScreen extends StatefulWidget {
  final Call call;
  final String image;
  final String name;
  final UserEntity currentUser;

  const VideoCallScreen({
    super.key,
    required this.call,
    required this.name,
    required this.image,
    required this.currentUser,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool _isLocalVideoExpanded = false;
  double _localVideoWidth = 120.0;
  double _localVideoHeight = 160.0;
  Offset _localVideoPosition = const Offset(20, 100);

  // Call state tracking
  bool _isConnected = false;
  bool _isMicrophoneEnabled = true;
  bool _isSpeakerEnabled = true;

  // Timer for call duration
  Timer? _callTimer;
  Duration _callDuration = Duration.zero;
  DateTime? _callStartTime;

  // New: Track which participant is in the main view (true = local, false = remote)
  bool _isLocalInMainView = false;

  // Conversations state
  List<Conversation> _allConversations = [];
  bool _isLoadingConversations = false;

  @override
  void initState() {
    super.initState();
    // Join the call when the screen is initialized
    widget.call.join();

    // Listen for call state changes
    widget.call.state.listen((callState) {
      // Check if there are other participants (at least 2 including yourself)
      final hasOtherParticipants = callState.callParticipants.length > 1;

      if (hasOtherParticipants && !_isConnected) {
        // Other participant joined, start timer
        _isConnected = true;
        _startCallTimer();
      } else if (!hasOtherParticipants && _isConnected) {
        // Other participant left, stop timer and reset
        _isConnected = false;
        _stopCallTimer();
      }

      // Update UI state based on actual call state
      if (mounted) {
        setState(() {
          _isMicrophoneEnabled =
              callState.localParticipant?.isAudioEnabled ?? true;
        });
      }
    });

    // Fetch conversations when screen initializes
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

  // New: Function to switch the main view
  void _switchMainView() {
    setState(() {
      _isLocalInMainView = !_isLocalInMainView;
    });
  }

  // Fetch all conversations from the API
  Future<void> _fetchAllConversations() async {
    setState(() => _isLoadingConversations = true);

    try {
      final token = await AuthManager.getToken();
      const int pageSize = 50; // Fetch more conversations for selection
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

  // Show dialog to select a person to add to call (single selection)
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

  // API call to add a person to call (single conversation)
  Future<void> _addPersonToCall(String conversationId) async {
    // TODO: Implement API call to add conversation to the current call
    // This should call your backend endpoint that adds the selected conversation to the call

    try {
      final token = await AuthManager.getToken();
      // Example endpoint structure - adjust according to your backend API
      // final response = await http.post(
      //   Uri.parse('$baseUrl/api/v1/call/${widget.call.id}/add-participant'),
      //   headers: {
      //     'Authorization': 'Bearer $token',
      //     'Content-Type': 'application/json',
      //   },
      //   body: jsonEncode({
      //     'conversationId': conversationId,
      //   }),
      // );

      // if (response.statusCode == 200) {
      //   _showSuccessSnackBar('Person added to call successfully');
      // } else {
      //   _showErrorSnackBar('Failed to add person to call: ${response.body}');
      // }

      // For now, just show a placeholder message
      _showSuccessSnackBar('Add person functionality will be implemented');
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
        onBackPressed: () {
          widget.call.end();
        },
        call: widget.call,
        callConnectOptions: CallConnectOptions(
          microphone: TrackOption.enabled(),
        ),
        callContentBuilder:
            (BuildContext context, Call call, CallState callState) {
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
    final participants = callState.callParticipants;
    final localParticipant = participants.where((p) => p.isLocal).firstOrNull;
    final remoteParticipants = participants.where((p) => !p.isLocal).toList();

    return Stack(
      children: [
        // Header with privacy notice
        _buildHeader(),

        // Main view - shows either local or remote participant based on _isLocalInMainView
        if (_isLocalInMainView)
          _buildMainLocalParticipantView(localParticipant)
        else
          _buildMainRemoteParticipantView(
            remoteParticipants.isNotEmpty ? remoteParticipants.first : null,
          ),

        // Small participant view - shows the opposite of main view
        if (_isLocalInMainView)
          _buildSmallRemoteParticipantView(
            remoteParticipants.isNotEmpty ? remoteParticipants.first : null,
          )
        else
          _buildSmallLocalParticipantView(localParticipant),

        // Control buttons
        _buildControlButtons(call),
      ],
    );
  }

  Widget _buildHeader() {
    return Positioned(
      top: 50,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'This session is encrypted and private. Only you and\n${widget.name} are connected.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: getProportionateScreenHeight(12),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _isConnected ? Colors.green : Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _isConnected
                      ? 'Connected • ${_formatDuration(_callDuration)}'
                      : 'Connecting...',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Main view for remote participant
  Widget _buildMainRemoteParticipantView(CallParticipantState? participant) {
    final hasVideo =
        participant != null &&
        participant.publishedTracks.entries.any(
          (entry) =>
              entry.key == SfuTrackType.video && participant.isVideoEnabled,
        );

    return Positioned.fill(
      child: GestureDetector(
        onTap: _switchMainView,
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 200, 20, 120),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF6C5CE7), width: 3),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(17),
            child: hasVideo
                ? StreamVideoRenderer(
                    call: widget.call,
                    participant: participant,
                    videoTrackType: SfuTrackType.video,
                  )
                : _buildRemoteParticipantAvatar(participant != null),
          ),
        ),
      ),
    );
  }

  // Main view for local participant
  Widget _buildMainLocalParticipantView(CallParticipantState? participant) {
    final hasVideo =
        participant != null &&
        participant.publishedTracks.entries.any(
          (entry) =>
              entry.key == SfuTrackType.video && participant.isVideoEnabled,
        );

    return Positioned.fill(
      child: GestureDetector(
        onTap: _switchMainView,
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 200, 20, 120),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF6C5CE7), width: 3),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(17),
            child: hasVideo
                ? StreamVideoRenderer(
                    call: widget.call,
                    participant: participant,
                    videoTrackType: SfuTrackType.video,
                  )
                : _buildLocalParticipantAvatar(),
          ),
        ),
      ),
    );
  }

  // Small draggable remote participant view
  Widget _buildSmallRemoteParticipantView(CallParticipantState? participant) {
    final hasVideo =
        participant != null &&
        participant.publishedTracks.entries.any(
          (entry) =>
              entry.key == SfuTrackType.video && participant.isVideoEnabled,
        );

    return Positioned(
      left: _localVideoPosition.dx,
      top: _localVideoPosition.dy,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isLocalVideoExpanded = !_isLocalVideoExpanded;
            if (_isLocalVideoExpanded) {
              _localVideoWidth = 200.0;
              _localVideoHeight = 267.0;
            } else {
              _localVideoWidth = 120.0;
              _localVideoHeight = 160.0;
            }
          });
          _switchMainView();
        },
        onPanUpdate: (details) {
          setState(() {
            _localVideoPosition = Offset(
              (_localVideoPosition.dx + details.delta.dx).clamp(
                0.0,
                MediaQuery.of(context).size.width - _localVideoWidth,
              ),
              (_localVideoPosition.dy + details.delta.dy).clamp(
                0.0,
                MediaQuery.of(context).size.height - _localVideoHeight,
              ),
            );
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _localVideoWidth,
          height: _localVideoHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isLocalVideoExpanded
                  ? const Color(0xFF6C5CE7)
                  : Colors.white.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: hasVideo
                ? StreamVideoRenderer(
                    call: widget.call,
                    participant: participant,
                    videoTrackType: SfuTrackType.video,
                  )
                : _buildSmallRemoteParticipantAvatar(participant != null),
          ),
        ),
      ),
    );
  }

  // Small draggable local participant view
  Widget _buildSmallLocalParticipantView(CallParticipantState? participant) {
    final hasVideo =
        participant != null &&
        participant.publishedTracks.entries.any(
          (entry) =>
              entry.key == SfuTrackType.video && participant.isVideoEnabled,
        );

    return Positioned(
      left: _localVideoPosition.dx,
      top: _localVideoPosition.dy,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isLocalVideoExpanded = !_isLocalVideoExpanded;
            if (_isLocalVideoExpanded) {
              _localVideoWidth = 200.0;
              _localVideoHeight = 267.0;
            } else {
              _localVideoWidth = 120.0;
              _localVideoHeight = 160.0;
            }
          });
          _switchMainView();
        },
        onPanUpdate: (details) {
          setState(() {
            _localVideoPosition = Offset(
              (_localVideoPosition.dx + details.delta.dx).clamp(
                0.0,
                MediaQuery.of(context).size.width - _localVideoWidth,
              ),
              (_localVideoPosition.dy + details.delta.dy).clamp(
                0.0,
                MediaQuery.of(context).size.height - _localVideoHeight,
              ),
            );
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _localVideoWidth,
          height: _localVideoHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isLocalVideoExpanded
                  ? const Color(0xFF6C5CE7)
                  : Colors.white.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: hasVideo
                ? StreamVideoRenderer(
                    call: widget.call,
                    participant: participant,
                    videoTrackType: SfuTrackType.video,
                  )
                : _buildSmallLocalParticipantAvatar(),
          ),
        ),
      ),
    );
  }

  Widget _buildRemoteParticipantAvatar(bool isParticipantJoined) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6C5CE7).withOpacity(0.8),
            const Color(0xFF4834d4).withOpacity(0.9),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Profile image
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipOval(
                child: widget.image.isNotEmpty
                    ? Image.network(
                        widget.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultRemoteAvatar();
                        },
                      )
                    : _buildDefaultRemoteAvatar(),
              ),
            ),
            const SizedBox(height: 20),
            // Participant name
            Text(
              widget.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            // Status indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isParticipantJoined ? Icons.videocam_off : Icons.phone,
                    color: Colors.white.withOpacity(0.8),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isParticipantJoined
                        ? 'Camera is off'
                        : 'Waiting to join...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // New: Avatar for local participant when camera is off (main view)
  Widget _buildLocalParticipantAvatar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2ECC71).withOpacity(0.8),
            const Color(0xFF27AE60).withOpacity(0.9),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Profile image or default avatar
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipOval(child: _buildDefaultLocalAvatar()),
            ),
            const SizedBox(height: 20),
            // "You" label
            const Text(
              'You',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            // Status indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.videocam_off,
                    color: Colors.white.withOpacity(0.8),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Camera is off',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // New: Small avatar for remote participant when in small view
  Widget _buildSmallRemoteParticipantAvatar(bool isParticipantJoined) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6C5CE7).withOpacity(0.8),
            const Color(0xFF4834d4).withOpacity(0.9),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: ClipOval(
                child: widget.image.isNotEmpty
                    ? Image.network(
                        widget.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultRemoteAvatar();
                        },
                      )
                    : _buildDefaultRemoteAvatar(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // New: Small avatar for local participant when in small view
  Widget _buildSmallLocalParticipantAvatar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2ECC71).withOpacity(0.8),
            const Color(0xFF27AE60).withOpacity(0.9),
          ],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off, color: Colors.white, size: 32),
            SizedBox(height: 8),
            Text(
              'You',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultRemoteAvatar() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF6C5CE7),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          widget.name.isNotEmpty ? widget.name[0].toUpperCase() : 'U',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultLocalAvatar() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF2ECC71),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(Icons.person, color: Colors.white, size: 48),
      ),
    );
  }

  Widget _buildControlButtons(Call call) {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
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
                // For iOS, trigger the native audio route picker
                if (Theme.of(context).platform == TargetPlatform.iOS) {
                  await RtcMediaDeviceNotifier.instance
                      .triggeriOSAudioRouteSelectionUI();
                } else {
                  // For Android, toggle speaker phone
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
                              debugPrint(
                                'Failed to set audio output: ${failure.error.message}',
                              );
                            },
                          );
                        });
                      }
                    },
                    failure: (failure) {
                      debugPrint(
                        'Failed to get audio outputs: ${failure.error.message}',
                      );
                    },
                  );
                }
              } catch (e) {
                debugPrint('Error toggling speaker: $e');
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

          // Camera toggle
          _buildControlButton(
            icon: Icons.videocam,
            onPressed: () async {
              try {
                final isVideoEnabled =
                    call.state.valueOrNull?.localParticipant?.isVideoEnabled ??
                    false;

                if (isVideoEnabled) {
                  await call.setCameraEnabled(enabled: false);
                } else {
                  await call.setCameraEnabled(enabled: true);
                }
              } catch (e) {
                debugPrint('Failed to toggle camera: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Unable to toggle camera'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),

          // Add person to call button (updated for single selection)
          _buildControlButton(
            icon: Icons.person_add,
            isEnabled: true,
            onPressed: _showAddPersonDialog,
          ),

          // Screen share
          _buildControlButton(
            icon: Icons.screen_share,
            onPressed: () {
              // Toggle screen share - implement as needed
            },
          ),

          // End call
          _buildControlButton(
            icon: Icons.call_end,
            backgroundColor: Colors.red,
            onPressed: () async {
              await call.end();
              if (mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? backgroundColor,
    bool? isEnabled,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            (isEnabled == true
                ? Colors.white24
                : isEnabled == false
                ? Colors.white10
                : Colors.grey.withOpacity(0.3)),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: isEnabled == false ? Colors.white54 : Colors.white,
        ),
        onPressed: onPressed,
      ),
    );
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    super.dispose();
  }
}

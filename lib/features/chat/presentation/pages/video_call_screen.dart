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
  final String callId;

  const VideoCallScreen({
    super.key,
    required this.call,
    required this.name,
    required this.image,
    required this.currentUser,
    required this.callId,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  // Call state tracking
  bool _isConnected = false;
  bool _isMicrophoneEnabled = true;
  bool _isSpeakerEnabled = true;

  // Timer for call duration
  Timer? _callTimer;
  Duration _callDuration = Duration.zero;
  DateTime? _callStartTime;

  // Conversations state
  List<Conversation> _allConversations = [];
  bool _isLoadingConversations = false;

  // Grid layout state
  String? _focusedParticipantId;
  bool _isGridView = false;

  final double _localVideoWidth = 120.0;
  final double _localVideoHeight = 160.0;
  Offset _localVideoPosition = const Offset(20, 100);

  //Screen Share
  bool _isScreenSharingEnabled = false;

  // Call Timer
  Timer? _noParticipantsTimer;

  @override
  void initState() {
    super.initState();
    // Join the call when the screen is initialized
    widget.call.join();
    _startNoParticipantsTimer();

    // Listen for call state changes
    widget.call.state.listen((callState) {
      // Check if there are other participants (at least 2 including yourself)
      final hasOtherParticipants = callState.callParticipants.length > 1;

      if (hasOtherParticipants && !_isConnected) {
        // Other participant joined, start timer
        _isConnected = true;
        _startCallTimer();
        if (callState.callParticipants.length > 1) {
          _noParticipantsTimer?.cancel(); // Cancel timer when someone joins
        }
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
          _isScreenSharingEnabled =
              callState.localParticipant?.isScreenShareEnabled ?? false;
        });
      }
    });

    // Fetch conversations when screen initializes
    _fetchAllConversations();
  }

  void _startNoParticipantsTimer() {
    _noParticipantsTimer = Timer(const Duration(minutes: 1), () {
      if (mounted) {
        // Check if there's only the local participant (initiator)
        final participants = widget.call.state.value.callParticipants;
        if (participants.length <= 1) {
          widget.call.end();
          Navigator.of(context).pop();
        }
      }
    });
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

  // Calculate grid dimensions based on participant count
  Map<String, int> _calculateGridDimensions(int participantCount) {
    if (participantCount <= 2) return {'rows': 1, 'columns': 2};
    if (participantCount <= 4) return {'rows': 2, 'columns': 2};
    if (participantCount <= 6) return {'rows': 2, 'columns': 3};
    if (participantCount <= 9) return {'rows': 3, 'columns': 3};
    if (participantCount <= 12) return {'rows': 3, 'columns': 4};
    return {'rows': 4, 'columns': 4}; // Max 16 participants
  }

  // Toggle between grid view and focused view
  void _toggleViewMode() {
    setState(() {
      _isGridView = !_isGridView;
      if (!_isGridView) {
        _focusedParticipantId = null;
      }
    });
  }

  // Focus on a specific participant
  void _focusParticipant(String participantId) {
    setState(() {
      _focusedParticipantId = participantId;
      _isGridView = false;
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
    final participantCount = participants.length;

    return Stack(
      children: [
        // Header with privacy notice
        _buildHeader(participantCount),

        // Main content area - either grid or focused view
        if (_isGridView || participantCount > 2)
          _buildGridView(participants)
        else
          _buildFocusedView(participants),

        // Control buttons
        _buildControlButtons(call),

        // View mode toggle button (only show when there are more than 2 participants)
        if (participantCount > 2) _buildViewToggleButton(),
      ],
    );
  }

  Widget _buildHeader(int participantCount) {
    String privacyText;
    if (participantCount <= 2) {
      privacyText =
          'This session is encrypted and private. Only you and\n${widget.name} are connected.';
    } else {
      privacyText =
          'This session is encrypted and private.\n$participantCount participants connected.';
    }

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
              privacyText,
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

  Widget _buildViewToggleButton() {
    return Positioned(
      top: 150,
      right: 20,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: IconButton(
          icon: Icon(
            _isGridView ? Icons.person : Icons.grid_view,
            color: Colors.white,
            size: 20,
          ),
          onPressed: _toggleViewMode,
        ),
      ),
    );
  }

  Widget _buildGridView(List<CallParticipantState> participants) {
    final dimensions = _calculateGridDimensions(participants.length);
    final rows = dimensions['rows']!;
    final columns = dimensions['columns']!;

    return Positioned(
      top: 200,
      left: 20,
      right: 20,
      bottom: 120,
      child: Column(
        children: List.generate(rows, (rowIndex) {
          return Expanded(
            child: Row(
              children: List.generate(columns, (colIndex) {
                final participantIndex = rowIndex * columns + colIndex;
                if (participantIndex >= participants.length) {
                  return Expanded(child: Container()); // Empty space
                }

                final participant = participants[participantIndex];
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    child: _buildGridParticipantTile(participant),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildGridParticipantTile(CallParticipantState participant) {
    final hasVideo = participant.publishedTracks.entries.any(
      (entry) => entry.key == SfuTrackType.video && participant.isVideoEnabled,
    );

    final hasScreenShare = participant.publishedTracks.entries.any(
      (entry) =>
          entry.key == SfuTrackType.screenShare &&
          participant.isScreenShareEnabled,
    );

    return GestureDetector(
      onTap: () => _focusParticipant(participant.userId),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: participant.isLocal
                ? const Color(0xFF2ECC71)
                : const Color(0xFF6C5CE7),
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              // Video or avatar
              Positioned.fill(
                child: hasScreenShare
                    ? StreamVideoRenderer(
                        call: widget.call,
                        participant: participant,
                        videoTrackType: SfuTrackType.screenShare,
                      )
                    : hasVideo
                    ? StreamVideoRenderer(
                        call: widget.call,
                        participant: participant,
                        videoTrackType: SfuTrackType.video,
                      )
                    : _buildParticipantAvatar(participant, isSmall: true),
              ),

              // Screen share indicator
              if (hasScreenShare)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.screen_share,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),

              // Participant info overlay
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!participant.isAudioEnabled)
                        const Icon(
                          Icons.mic_off,
                          color: Colors.white,
                          size: 12,
                        ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          participant.isLocal
                              ? 'You'
                              : _getParticipantName(participant),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFocusedView(List<CallParticipantState> participants) {
    final localParticipant = participants.where((p) => p.isLocal).firstOrNull;
    final remoteParticipants = participants.where((p) => !p.isLocal).toList();

    // Determine focused participant
    CallParticipantState? focusedParticipant;
    if (_focusedParticipantId != null) {
      focusedParticipant = participants
          .where((p) => p.userId == _focusedParticipantId)
          .firstOrNull;
    }
    focusedParticipant ??= remoteParticipants.isNotEmpty
        ? remoteParticipants.first
        : localParticipant;

    return Stack(
      children: [
        // Main focused participant
        if (focusedParticipant != null)
          _buildMainParticipantView(focusedParticipant),

        // Thumbnail strip for other participants
        if (participants.length > 1)
          _buildThumbnailStrip(participants, focusedParticipant),
      ],
    );
  }

  Widget _buildMainParticipantView(CallParticipantState participant) {
    final hasVideo = participant.publishedTracks.entries.any(
      (entry) => entry.key == SfuTrackType.video && participant.isVideoEnabled,
    );

    final hasScreenShare = participant.publishedTracks.entries.any(
      (entry) =>
          entry.key == SfuTrackType.screenShare &&
          participant.isScreenShareEnabled,
    );

    return Positioned.fill(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 200, 20, 120),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: participant.isLocal
                ? const Color(0xFF2ECC71)
                : const Color(0xFF6C5CE7),
            width: 3,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: Stack(
            children: [
              // Screen share takes priority over video
              Positioned.fill(
                child: hasScreenShare
                    ? StreamVideoRenderer(
                        call: widget.call,
                        participant: participant,
                        videoTrackType: SfuTrackType.screenShare,
                      )
                    : hasVideo
                    ? StreamVideoRenderer(
                        call: widget.call,
                        participant: participant,
                        videoTrackType: SfuTrackType.video,
                      )
                    : _buildParticipantAvatar(participant, isSmall: false),
              ),

              // Screen share indicator
              if (hasScreenShare)
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.screen_share, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Screen sharing',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailStrip(
    List<CallParticipantState> participants,
    CallParticipantState? focusedParticipant,
  ) {
    final otherParticipants = participants
        .where((p) => p.userId != focusedParticipant?.userId)
        .toList();

    if (otherParticipants.isEmpty) return const SizedBox.shrink();

    return Positioned(
      left: _localVideoPosition.dx,
      top: _localVideoPosition.dy,
      child: GestureDetector(
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
          child: Column(
            children: otherParticipants.take(4).map((participant) {
              // Limit to 4 thumbnails
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => _focusParticipant(participant.userId),
                  child: _buildThumbnailParticipant(participant),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailParticipant(CallParticipantState participant) {
    final hasVideo = participant.publishedTracks.entries.any(
      (entry) => entry.key == SfuTrackType.video && participant.isVideoEnabled,
    );

    final hasScreenShare = participant.publishedTracks.entries.any(
      (entry) =>
          entry.key == SfuTrackType.screenShare &&
          participant.isScreenShareEnabled,
    );

    return Container(
      width: 80,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: participant.isLocal
              ? const Color(0xFF2ECC71)
              : const Color(0xFF6C5CE7),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            Positioned.fill(
              child: hasScreenShare
                  ? StreamVideoRenderer(
                      call: widget.call,
                      participant: participant,
                      videoTrackType: SfuTrackType.screenShare,
                    )
                  : hasVideo
                  ? StreamVideoRenderer(
                      call: widget.call,
                      participant: participant,
                      videoTrackType: SfuTrackType.video,
                    )
                  : _buildParticipantAvatar(participant, isSmall: true),
            ),

            // Screen share indicator
            if (hasScreenShare)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.screen_share,
                    color: Colors.white,
                    size: 8,
                  ),
                ),
              ),

            // Name overlay
            Positioned(
              bottom: 4,
              left: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  participant.isLocal
                      ? 'You'
                      : _getParticipantName(participant),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantAvatar(
    CallParticipantState participant, {
    required bool isSmall,
  }) {
    final name = participant.isLocal ? 'You' : _getParticipantName(participant);
    final color = participant.isLocal
        ? const Color(0xFF2ECC71)
        : const Color(0xFF6C5CE7);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.8), color.withOpacity(0.9)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isSmall) ...[
              // Large avatar for main view
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
                  child: participant.isLocal
                      ? _buildDefaultLocalAvatar()
                      : _buildDefaultRemoteAvatar(name),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
            ] else ...[
              // Small avatar for thumbnails/grid
              if (participant.isLocal)
                const Icon(Icons.videocam_off, color: Colors.white, size: 24)
              else
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipOval(child: _buildDefaultRemoteAvatar(name)),
                ),
              const SizedBox(height: 4),
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getParticipantName(CallParticipantState participant) {
    // Try to get name from participant data, fallback to first letter of user ID
    return participant.name.isNotEmpty == true
        ? participant.name
        : (participant.userId.isNotEmpty
              ? participant.userId[0].toUpperCase()
              : 'U');
  }

  Widget _buildDefaultRemoteAvatar(String name) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF6C5CE7),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
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
      child: SafeArea(
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
                      call
                          .state
                          .valueOrNull
                          ?.localParticipant
                          ?.isVideoEnabled ??
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
              icon: _isScreenSharingEnabled
                  ? Icons.stop_screen_share
                  : Icons.screen_share,
              isEnabled: _isScreenSharingEnabled,
              onPressed: () async {
                try {
                  if (_isScreenSharingEnabled) {
                    // Stop screen sharing
                    await call.setScreenShareEnabled(enabled: false);
                    if (CurrentPlatform.isAndroid) {
                      await StreamBackgroundService()
                          .stopScreenSharingNotificationService(call.id);
                    } else {
                      // TODO: IOS Stop screen sharing
                    }
                  } else {
                    // Start screen sharing
                    if (CurrentPlatform.isAndroid) {
                      // Check if the user has granted permission to share their screen
                      if (!await call.requestScreenSharePermission()) {
                        return;
                      }
                      // Start the screen sharing notification service
                      await StreamBackgroundService()
                          .startScreenSharingNotificationService(call);

                      await call.setScreenShareEnabled(enabled: true);
                    } else {
                      // TODO: IOS Start screen sharing
                      await widget.call.setScreenShareEnabled(enabled: true);
                    }
                  }
                } catch (e) {
                  debugPrint('Failed to toggle screen share: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Unable to toggle screen share'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
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
    _noParticipantsTimer?.cancel();
    super.dispose();
    widget.call.leave();
  }
}

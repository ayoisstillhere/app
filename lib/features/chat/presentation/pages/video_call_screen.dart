import 'package:flutter/material.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

import '../../../../size_config.dart';

class VideoCallScreen extends StatefulWidget {
  final Call call;
  final String image;
  final String name;

  const VideoCallScreen({
    super.key,
    required this.call,
    required this.name,
    required this.image,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool _isLocalVideoExpanded = false;
  double _localVideoWidth = 120.0;
  double _localVideoHeight = 160.0;
  Offset _localVideoPosition = const Offset(20, 100);

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

        // Main remote participant view
        if (remoteParticipants.isNotEmpty)
          _buildRemoteParticipantView(remoteParticipants.first),

        // Local participant view (draggable and resizable)
        if (localParticipant != null)
          _buildLocalParticipantView(localParticipant),

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
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Secure & Connected',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemoteParticipantView(CallParticipantState participant) {
    // Check if the remote participant has video enabled
    final hasVideo = participant.publishedTracks.entries.any(
      (entry) => entry.key == SfuTrackType.video && participant.isVideoEnabled,
    );

    return Positioned.fill(
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
              : _buildParticipantAvatar(),
        ),
      ),
    );
  }

  Widget _buildParticipantAvatar() {
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
                          return _buildDefaultAvatar();
                        },
                      )
                    : _buildDefaultAvatar(),
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
            // Camera off indicator
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

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF6C5CE7),
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

  Widget _buildLocalParticipantView(CallParticipantState participant) {
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
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: StreamVideoRenderer(
              call: widget.call,
              participant: participant,
              videoTrackType: SfuTrackType.video,
            ),
          ),
        ),
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
          _buildControlButton(
            icon: Icons.mic,
            onPressed: () {
              call.setMicrophoneEnabled(
                enabled:
                    !(call
                            .state
                            .valueOrNull
                            ?.localParticipant
                            ?.publishedTracks
                            .entries
                            .any((entry) => entry.key == SfuTrackType.audio) ??
                        false),
              );
            },
          ),
          _buildControlButton(
            icon: Icons.volume_up,
            onPressed: () {
              // Toggle speaker
            },
          ),
          _buildControlButton(
            icon: Icons.videocam_off,
            onPressed: () {
              call.setCameraEnabled(
                enabled:
                    !(call
                            .state
                            .valueOrNull
                            ?.localParticipant
                            ?.publishedTracks
                            .entries
                            .any((entry) => entry.key == SfuTrackType.video) ??
                        false),
              );
            },
          ),
          _buildControlButton(
            icon: Icons.screen_share,
            onPressed: () {
              // Toggle screen share
            },
          ),
          _buildControlButton(
            icon: Icons.call_end,
            backgroundColor: Colors.red,
            onPressed: () {
              call.end();
              Navigator.of(context).pop();
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
  }) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}

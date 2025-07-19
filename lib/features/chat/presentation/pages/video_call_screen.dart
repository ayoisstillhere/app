import 'package:flutter/material.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';
import 'dart:async';

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

  // Call state tracking
  bool _isConnected = false;
  bool _isMicrophoneEnabled = true;
  bool _isSpeakerEnabled = true;

  // Timer for call duration
  Timer? _callTimer;
  Duration _callDuration = Duration.zero;
  DateTime? _callStartTime;

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

        // Main remote participant view - always show avatar, video when available
        _buildRemoteParticipantView(
          remoteParticipants.isNotEmpty ? remoteParticipants.first : null,
        ),

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

  Widget _buildRemoteParticipantView(CallParticipantState? participant) {
    // Check if the remote participant has video enabled
    final hasVideo =
        participant != null &&
        participant.publishedTracks.entries.any(
          (entry) =>
              entry.key == SfuTrackType.video && participant.isVideoEnabled,
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
              : _buildParticipantAvatar(participant != null),
        ),
      ),
    );
  }

  Widget _buildParticipantAvatar(bool isParticipantJoined) {
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

  Widget _buildDefaultAvatar() {
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
      width: 56,
      height: 56,
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

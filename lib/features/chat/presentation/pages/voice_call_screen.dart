import 'package:app/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';
import 'dart:async';

class VoiceCallScreen extends StatefulWidget {
  final Call call;
  final String image;
  final String name;

  const VoiceCallScreen({
    super.key,
    required this.call,
    required this.image,
    required this.name,
  });

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen> {
  bool _isMicrophoneEnabled = true;
  bool _isSpeakerEnabled = true;
  bool _isCameraEnabled = false;

  // Timer for call duration
  Timer? _callTimer;
  Duration _callDuration = Duration.zero;
  DateTime? _callStartTime;

  @override
  void initState() {
    super.initState();
    // Join the call when the screen is initialized
    widget.call.join();

    // Listen for call state changes instead of starting timer immediately
    widget.call.state.listen((callState) {
      // Check if there are other participants (at least 2 including yourself)
      if (callState.callParticipants.length > 1 && _callTimer == null) {
        _startCallTimer();
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                'This session is encrypted and private. Only you and\n${widget.name} are connected.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: getProportionateScreenHeight(12),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),

        // Main content area - participant info and audio visualization
        Positioned(
          top: MediaQuery.of(context).size.height * 0.25,
          left: 0,
          right: 0,
          child: Column(
            children: [
              // Profile picture
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

              const SizedBox(height: 24),

              // Participant name
              Text(
                widget.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 8),

              // Call duration - now with working timer
              Text(
                _formatDuration(_callDuration),
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),

              const SizedBox(height: 40),

              // Audio visualization
              SvgPicture.asset(
                "assets/icons/voice_call_wave.svg",
                height: getProportionateScreenHeight(26),
                width: getProportionateScreenWidth(157),
              ),
            ],
          ),
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
            onPressed: () {
              setState(() {
                _isMicrophoneEnabled = !_isMicrophoneEnabled;
              });
              if (_isMicrophoneEnabled) {
                call.setMicrophoneEnabled(enabled: true);
              } else {
                call.setMicrophoneEnabled(enabled: false);
              }
            },
          ),

          // Speaker toggle
          _buildControlButton(
            icon: _isSpeakerEnabled ? Icons.volume_up : Icons.volume_off,
            isEnabled: _isSpeakerEnabled,
            onPressed: () {
              setState(() {
                _isSpeakerEnabled = !_isSpeakerEnabled;
              });
              // Handle speaker toggle
            },
          ),

          // Camera toggle
          _buildControlButton(
            icon: _isCameraEnabled ? Icons.videocam : Icons.videocam_off,
            isEnabled: _isCameraEnabled,
            onPressed: () {
              setState(() {
                _isCameraEnabled = !_isCameraEnabled;
              });
              if (_isCameraEnabled) {
                call.setCameraEnabled(enabled: true);
              } else {
                call.setCameraEnabled(enabled: false);
              }
            },
          ),

          // Add contact or notes (optional)
          _buildControlButton(
            icon: Icons.person_add,
            isEnabled: true,
            onPressed: () {
              // Handle add contact or notes
            },
          ),

          // End call
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {
                call.end();
                Navigator.of(context).pop();
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
      width: 60,
      height: 60,
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
    widget.call.end();
    super.dispose();
  }
}

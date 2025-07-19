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
  bool _isConnected = false; // Track connection status

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
          _isCameraEnabled =
              callState.localParticipant?.isVideoEnabled ?? false;
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

              // Call status - show "Connecting..." when not connected, timer when connected
              Text(
                _isConnected ? _formatDuration(_callDuration) : 'Connecting...',
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
                    SnackBar(
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
                  // For Android, you can toggle speaker phone or manage audio output devices
                  // This is a simplified toggle - you might want to implement more sophisticated logic
                  final audioOutputsResult = await RtcMediaDeviceNotifier
                      .instance
                      .audioOutputs();
                  audioOutputsResult.fold(
                    success: (audioOutputsSuccess) {
                      final audioOutputs = audioOutputsSuccess.data;
                      if (audioOutputs.isNotEmpty) {
                        // Find speaker or earpiece device and toggle
                        final currentOutput =
                            call.state.value.audioOutputDevice;
                        // Toggle between available audio outputs
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
                    SnackBar(
                      content: Text('Unable to toggle speaker'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),

          // Camera toggle - Fixed implementation
          _buildControlButton(
            icon: _isCameraEnabled ? Icons.videocam : Icons.videocam_off,
            isEnabled: _isCameraEnabled,
            onPressed: () async {
              try {
                if (_isCameraEnabled) {
                  await call.setCameraEnabled(enabled: false);
                } else {
                  await call.setCameraEnabled(enabled: true);
                }
                // State will be updated through the call state listener
              } catch (e) {
                debugPrint('Failed to toggle camera: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Unable to toggle camera'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
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
    // Don't call end() here as it might interfere with navigation
    // The call will be ended when the user presses the end call button
    super.dispose();
  }
}

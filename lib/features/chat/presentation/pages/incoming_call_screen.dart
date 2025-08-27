import 'dart:convert';

import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:app/features/chat/presentation/pages/voice_call_screen.dart';
import 'package:app/features/chat/presentation/pages/video_call_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stream_video_flutter/stream_video_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

import '../../../../constants.dart';
import '../../../../services/auth_manager.dart';

enum CallState {
  incoming,
  accepting,
  declining,
}

class IncomingCallScreen extends StatefulWidget {
  final String callerName;
  final String callId;
  final UserEntity currentUser;
  final String imageUrl;
  final String callType;

  const IncomingCallScreen({
    super.key,
    required this.callerName,
    required this.callId,
    required this.currentUser,
    required this.imageUrl,
    required this.callType,
  });

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isVibrating = false;
  CallState _callState = CallState.incoming;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _playRingtone();
  }

  @override
  void dispose() {
    _stopRingtone();
    _stopVibration();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playRingtone() async {
    try {
      await _audioPlayer.setSource(AssetSource('sounds/ringtone.mp3'));
      await _audioPlayer.resume();
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(0.8);

      setState(() {
        _isPlaying = true;
      });
    } catch (e) {
      debugPrint('Error playing ringtone: $e');
    }
  }

  Future<void> _stopRingtone() async {
    if (_isPlaying) {
      await _audioPlayer.stop();
      setState(() {
        _isPlaying = false;
      });
    }
  }

  Future<void> _stopVibration() async {
    if (_isVibrating) {
      await Vibration.cancel();
      setState(() {
        _isVibrating = false;
      });
    }
  }

  Future<void> _stopRingtoneAndVibration() async {
    await _stopRingtone();
    await _stopVibration();
  }

  bool get _isVideoCall => widget.callType.toUpperCase() == 'VIDEO';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isVideoCall ? Icons.videocam : Icons.call,
                      color: Colors.white,
                      size: 28,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Incoming ${_isVideoCall ? 'Video' : 'Audio'} Call',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Animated avatar with pulsing effect
                AnimatedContainer(
                  duration: Duration(milliseconds: 1000),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(widget.imageUrl),
                      ),
                      if (_isVideoCall)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.videocam,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  widget.callerName,
                  style: TextStyle(color: Colors.white, fontSize: 32),
                ),
                SizedBox(height: 40),
                // Show loading indicator or call buttons based on state
                _buildCallActions(),
              ],
            ),
          ),
          // Loading overlay
          if (_callState != CallState.incoming) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildCallActions() {
    if (_callState == CallState.incoming) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: CircleBorder(),
              padding: EdgeInsets.all(20),
            ),
            icon: Icon(
              _isVideoCall ? Icons.videocam : Icons.call,
              size: 30,
              color: Colors.white,
            ),
            label: Text(''),
            onPressed: () {
              _acceptCall();
            },
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: CircleBorder(),
              padding: EdgeInsets.all(20),
            ),
            icon: Icon(Icons.call_end, size: 30, color: Colors.white),
            label: Text(''),
            onPressed: () {
              _declineCall();
            },
          ),
        ],
      );
    }
    
    // Show status text when processing
    return Column(
      children: [
        SizedBox(height: 60), // Same height as buttons for consistent spacing
        Text(
          _callState == CallState.accepting 
            ? 'Joining call...' 
            : 'Declining call...',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                _callState == CallState.accepting ? Colors.green : Colors.red,
              ),
            ),
            SizedBox(height: 16),
            Text(
              _callState == CallState.accepting 
                ? 'Connecting to call...' 
                : 'Declining call...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _acceptCall() async {
    if (_callState != CallState.incoming) return;
    
    setState(() {
      _callState = CallState.accepting;
    });

    try {
      await _stopRingtoneAndVibration();

      final token = await AuthManager.getToken();
      String callToken;
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/calls/${widget.callId}/join'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
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
              image: widget.currentUser.profileImage,
            ),
          ),
          userToken: callToken,
        );

        var call = StreamVideo.instance.makeCall(
          callType: StreamCallType.defaultType(),
          id: jsonDecode(response.body)['call']['roomId'],
        );

        await call.getOrCreate();

        // Navigate to appropriate call screen based on call type
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => _isVideoCall
                ? VideoCallScreen(
                    call: call,
                    image: widget.imageUrl,
                    name: widget.callerName,
                    currentUser: widget.currentUser,
                    callId: widget.callId,
                  )
                : VoiceCallScreen(
                    call: call,
                    image: widget.imageUrl,
                    name: widget.callerName,
                    currentUser: widget.currentUser,
                    callId: widget.callId,
                  ),
          ),
        );
      } else {
        _showErrorAndReset('Failed to join call. Please try again.');
      }
    } catch (e) {
      debugPrint('Error joining or creating call: $e');
      _showErrorAndReset('Connection error. Please try again.');
    }
  }

  Future<void> _declineCall() async {
    if (_callState != CallState.incoming) return;
    
    setState(() {
      _callState = CallState.declining;
    });

    try {
      await _stopRingtoneAndVibration();
      final token = await AuthManager.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/calls/${widget.callId}/reject'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context);
      } else {
        _showErrorAndReset('Failed to decline call.');
      }
    } catch (e) {
      debugPrint('Error declining call: $e');
      _showErrorAndReset('Connection error.');
    }
  }

  void _showErrorAndReset(String message) {
    setState(() {
      _callState = CallState.incoming;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }
}
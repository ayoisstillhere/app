import 'dart:convert';

import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:app/features/chat/presentation/pages/voice_call_screen.dart';
import 'package:app/features/chat/presentation/pages/video_call_screen.dart'; // Add this import
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stream_video_flutter/stream_video_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

import '../../../../constants.dart';
import '../../../../services/auth_manager.dart';

class IncomingCallScreen extends StatefulWidget {
  final String callerName;
  final String roomId;
  final UserEntity currentUser;
  final String imageUrl;
  final String callType;

  const IncomingCallScreen({
    super.key,
    required this.callerName,
    required this.roomId,
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
      body: Center(
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
            Row(
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
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _acceptCall() async {
    await _stopRingtoneAndVibration();

    final token = await AuthManager.getToken();
    String callToken;
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/calls/${widget.roomId}/join'),
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
          ),
        ),
        userToken: callToken,
      );

      try {
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
                  )
                : VoiceCallScreen(
                    call: call,
                    image: widget.imageUrl,
                    name: widget.callerName,
                    currentUser: widget.currentUser,
                  ),
          ),
        );
      } catch (e) {
        debugPrint('Error joining or creating call: $e');
        debugPrint(e.toString());
      }
    }
  }

  Future<void> _declineCall() async {
    await _stopRingtoneAndVibration();
    Navigator.pop(context);
  }
}

import 'dart:convert';

import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:app/features/chat/presentation/pages/voice_call_screen.dart';
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

  const IncomingCallScreen({
    super.key,
    required this.callerName,
    required this.roomId,
    required this.currentUser,
    required this.imageUrl,
  });

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _playRingtone();
  }

  @override
  void dispose() {
    _stopRingtone();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playRingtone() async {
    try {
      // Start vibration pattern
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(pattern: [500, 1000, 500, 1000], repeat: 0);
      }
      // Option 1: Play from assets
      await _audioPlayer.play(AssetSource('assets/sounds/ringtone.mp3'));

      // Option 2: Play system default ringtone (alternative)
      // await _audioPlayer.play(AssetSource('sounds/default_ringtone.mp3'));

      // Set to loop the ringtone
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);

      // Set volume (0.0 to 1.0)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Incoming Call',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            SizedBox(height: 20),
            // Animated avatar with pulsing effect
            AnimatedContainer(
              duration: Duration(milliseconds: 1000),
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(widget.imageUrl),
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
                  icon: Icon(Icons.call, size: 30),
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
                  icon: Icon(Icons.call_end, size: 30),
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
    await _stopRingtone(); // Stop ringtone when accepting call

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

        // Created ahead
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CallScreen(call: call)),
        );
      } catch (e) {
        debugPrint('Error joining or creating call: $e');
        debugPrint(e.toString());
      }
    }
  }

  Future<void> _declineCall() async {
    await _stopRingtone(); // Stop ringtone when declining call
    Navigator.pop(context);
  }
}

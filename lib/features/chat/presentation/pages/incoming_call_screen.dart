import 'dart:convert';

import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:app/features/chat/presentation/pages/voice_call_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stream_video_flutter/stream_video_flutter.dart';

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
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(widget.imageUrl),
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
                  ),
                  icon: Icon(Icons.call),
                  label: Text('Accept'),
                  onPressed: () {
                    _acceptCall();
                  },
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  icon: Icon(Icons.call_end),
                  label: Text('Decline'),
                  onPressed: () {
                    Navigator.pop(context);
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
          MaterialPageRoute(
            builder: (context) => CallScreen(
              call: call,
            ),
          ),
        );
      } catch (e) {
        debugPrint('Error joining or creating call: $e');
        debugPrint(e.toString());
      }
    }
  }
}

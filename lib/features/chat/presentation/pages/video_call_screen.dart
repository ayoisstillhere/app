import 'package:flutter/material.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

class VideoCallScreen extends StatefulWidget {
  final Call call;

  const VideoCallScreen({super.key, required this.call});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamCallContainer(
        call: widget.call,
        callConnectOptions: CallConnectOptions(
          microphone: TrackOption.enabled(),
        ),
      ),
    );
  }
}

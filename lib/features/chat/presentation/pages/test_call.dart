import 'package:app/constants.dart';
import 'package:app/features/chat/presentation/pages/voice_call_screen.dart';
import 'package:app/services/auth_manager.dart';
import 'package:flutter/material.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

import 'live_stream_screen.dart';

class TestCall extends StatefulWidget {
  const TestCall({super.key});

  @override
  State<TestCall> createState() => _TestCallState();
}

class _TestCallState extends State<TestCall> {
  // Call Client
  final client = StreamVideo(
    getStreamKey,
    user: const User(
      info: UserInfo(name: 'Ayodele Fagbami', id: 'ayoisstillhere'),
    ),
    userToken:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiYXlvaXNzdGlsbGhlcmUifQ.G4B_u7XNOV-jThatS2MklGnW885CZpZE5hDdNx0ahlw',
  );

  // LiveStream Client
  // final client = StreamVideo(
  //   'mmhfdzb5evj2',
  //   user: const User(
  //     info: UserInfo(name: 'John Doe', id: 'Zuckuss'),
  //   ),
  //   userToken:
  //       'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL3Byb250by5nZXRzdHJlYW0uaW8iLCJzdWIiOiJ1c2VyL1p1Y2t1c3MiLCJ1c2VyX2lkIjoiWnVja3VzcyIsInZhbGlkaXR5X2luX3NlY29uZHMiOjYwNDgwMCwiaWF0IjoxNzUyMDExNjcxLCJleHAiOjE3NTI2MTY0NzF9.UymsFFLbRUD-60MEqX3q2ui7blcXdohf7aKVZbwzsUw',
  // );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _createLivestreamRoom(),
              child: const Text('Create a Livestream'),
            ),
            ElevatedButton(
              onPressed: () => _createCallRoom(),
              child: const Text('Create an Audio Room'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createCallRoom() async {
    final currentUser = await AuthManager.getCurrentUser();
    try {
      var call = StreamVideo.instance.makeCall(
        callType: StreamCallType.defaultType(),
        id: 'default_3aad4a99-c649-406c-82e5-f72dc54fd8a5',
      );

      await call.getOrCreate();

      // Created ahead
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VoiceCallScreen(
            call: call,
            image: '',
            name: 'Ayo',
            currentUser: currentUser!,
            callId: 'default_3aad4a99-c649-406c-82e5-f72dc54fd8a5',
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error joining or creating call: $e');
      debugPrint(e.toString());
    }
  }

  Future<void> _createLivestreamRoom() async {
    // Set up our call object
    final call = StreamVideo.instance.makeCall(
      callType: StreamCallType.liveStream(),
      id: 'HWhhNtSfj80H',
    );

    // Create the call and set the current user as a host
    final result = await call.getOrCreate(
      members: [
        MemberRequest(
          userId: StreamVideo.instance.currentUser.id,
          role: 'host',
        ),
      ],
    );

    if (result.isFailure) {
      debugPrint('Not able to create a call.');
      return;
    }

    // Configure the call to allow users to join before it starts by setting a future start time
    // and specifying how many seconds in advance they can join via `joinAheadTimeSeconds`
    final updateResult = await call.update(
      startsAt: DateTime.now().toUtc().add(const Duration(seconds: 120)),
      backstage: const StreamBackstageSettings(
        enabled: true,
        joinAheadTimeSeconds: 120,
      ),
    );

    if (updateResult.isFailure) {
      debugPrint('Not able to update the call.');
      return;
    }

    // Set some default behaviour for how our devices should be configured once we join a call
    final connectOptions = CallConnectOptions(
      camera: TrackOption.enabled(),
      microphone: TrackOption.enabled(),
    );

    // Our local app user can join and receive events
    await call.join(connectOptions: connectOptions);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LiveStreamScreen(
          livestreamCall: call,
          userName: "Chief",
          liveStreamId: 'HWhhNtSfj80H',
          isScreenshotAllowed: true,
        ),
      ),
    );
  }
}

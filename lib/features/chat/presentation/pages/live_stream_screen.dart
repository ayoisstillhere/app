import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

import '../widgets/custom_livestream_widget.dart';
import '../widgets/live_stream_ended_widget.dart';

class LiveStreamScreen extends StatefulWidget {
  const LiveStreamScreen({
    super.key,
    required this.livestreamCall,
    required this.userName,
  });

  final Call livestreamCall;
  final String userName;

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  late StreamSubscription<CallState> _callStateSubscription;

  @override
  void initState() {
    super.initState();

    // Check if user is host and automatically start livestream
    _checkAndStartLivestream();

    _callStateSubscription = widget.livestreamCall.state.valueStream.listen((
      event,
    ) {
      final status = event.status;

      if (status is CallStatusDisconnected) {
        // Navigate to LivestreamEndedWidget
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) =>
                  LivestreamEndedWidget(call: widget.livestreamCall),
            ),
          );
        }
      }
    });
  }

  void _checkAndStartLivestream() {
    // Get the current call state
    final callState = widget.livestreamCall.state.value;
    final isHost = callState.localParticipant?.roles.contains('host') ?? false;

    // If user is host and livestream is in backstage, start it immediately
    if (isHost && callState.isBackstage) {
      // Start the livestream after a brief delay to ensure everything is initialized
      Future.delayed(const Duration(milliseconds: 500), () {
        widget.livestreamCall.goLive();
      });
    }
  }

  @override
  void dispose() {
    _callStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PartialCallStateBuilder(
      call: widget.livestreamCall,
      selector: (state) =>
          (isBackstage: state.isBackstage, endedAt: state.endedAt),
      builder: (context, callState) {
        return Scaffold(
          body: Builder(
            builder: (context) {
              // Show a loading screen while transitioning from backstage to live for hosts
              if (callState.isBackstage) {
                final isHost =
                    widget.livestreamCall.state.value.localParticipant?.roles
                        .contains('host') ??
                    false;

                if (isHost) {
                  // Show loading screen for host while livestream starts
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Starting livestream...',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Show waiting screen for viewers
                  return WaitingForLivestreamWidget(
                    call: widget.livestreamCall,
                  );
                }
              }

              if (callState.endedAt != null) {
                return LivestreamEndedWidget(call: widget.livestreamCall);
              }

              return CustomLivestreamWidget(
                call: widget.livestreamCall,
                userName: widget.userName,
              );
            },
          ),
        );
      },
    );
  }
}

// New widget to show viewers that livestream hasn't started yet
class WaitingForLivestreamWidget extends StatelessWidget {
  const WaitingForLivestreamWidget({super.key, required this.call});

  final Call call;

  @override
  Widget build(BuildContext context) {
    return PartialCallStateBuilder(
      call: call,
      selector: (state) =>
          state.callParticipants.where((p) => !p.roles.contains('host')).length,
      builder: (context, waitingParticipantsCount) {
        return Center(
          child: Column(
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              PartialCallStateBuilder(
                call: call,
                selector: (state) => state.startsAt,
                builder: (context, startsAt) {
                  return Text(
                    startsAt != null
                        ? 'Livestream starting at ${DateFormat('HH:mm').format(startsAt.toLocal())}'
                        : 'Waiting for livestream to start...',
                    style: Theme.of(context).textTheme.titleLarge,
                  );
                },
              ),
              if (waitingParticipantsCount > 0)
                Text('$waitingParticipantsCount participants waiting'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  call.leave();
                  Navigator.pop(context);
                },
                child: const Text('Leave'),
              ),
            ],
          ),
        );
      },
    );
  }
}

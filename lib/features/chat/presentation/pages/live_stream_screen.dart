import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

class LiveStreamScreen extends StatefulWidget {
  const LiveStreamScreen({super.key, required this.livestreamCall});

  final Call livestreamCall;

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  late StreamSubscription<CallState> _callStateSubscription;

  @override
  void initState() {
    super.initState();

    _callStateSubscription = widget.livestreamCall.state.valueStream
        .distinct((previous, current) => previous.status != current.status)
        .listen((event) {
          if (event.status is CallStatusDisconnected) {
            // Prompt the user to check their internet connection
          }
        });
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
              if (callState.isBackstage) {
                return BackstageWidget(call: widget.livestreamCall);
              }

              if (callState.endedAt != null) {
                return LivestreamEndedWidget(call: widget.livestreamCall);
              }

              return CustomLivestreamWidget(call: widget.livestreamCall);
            },
          ),
        );
      },
    );
  }
}

class CustomLivestreamWidget extends StatefulWidget {
  const CustomLivestreamWidget({super.key, required this.call});

  final Call call;

  @override
  State<CustomLivestreamWidget> createState() => _CustomLivestreamWidgetState();
}

class _CustomLivestreamWidgetState extends State<CustomLivestreamWidget> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  bool get isHost {
    return widget.call.state.value.localParticipant?.roles.contains('host') ??
        false;
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      // Send message logic here
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full screen video background
          Positioned.fill(
            child: PartialCallStateBuilder(
              call: widget.call,
              selector: (state) => state.callParticipants
                  .where((e) => e.roles.contains('host'))
                  .toList(),
              builder: (context, hosts) {
                if (hosts.isEmpty) {
                  return Container(
                    color: Colors.black,
                    child: const Center(
                      child: Text(
                        "Host video not available",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  );
                }

                // Display host's video
                final host = hosts.first;
                return StreamVideoRenderer(
                  videoFit: VideoFit.cover,
                  call: widget.call,
                  participant: host,
                  videoTrackType: SfuTrackType.video,
                );
              },
            ),
          ),

          // Top overlay with host info and follow/end button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Host avatar and info
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Host avatar
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.blue,
                              child: PartialCallStateBuilder(
                                call: widget.call,
                                selector: (state) => state.callParticipants
                                    .where((e) => e.roles.contains('host'))
                                    .firstOrNull,
                                builder: (context, host) {
                                  if (host!.image!.isNotEmpty) {
                                    return ClipOval(
                                      child: Image.network(
                                        host.image!,
                                        width: 32,
                                        height: 32,
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  }
                                  return Text(
                                    host.name.substring(0, 1).toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                PartialCallStateBuilder(
                                  call: widget.call,
                                  selector: (state) =>
                                      state.callParticipants
                                          .where(
                                            (e) => e.roles.contains('host'),
                                          )
                                          .firstOrNull
                                          ?.name ??
                                      'Host',
                                  builder: (context, hostName) {
                                    return Text(
                                      hostName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    );
                                  },
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.visibility,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    PartialCallStateBuilder(
                                      call: widget.call,
                                      selector: (state) =>
                                          state.callParticipants.length,
                                      builder: (context, count) {
                                        return Text(
                                          NumberFormat.compact().format(count),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Follow/End Live button
                      if (isHost)
                        ElevatedButton(
                          onPressed: () {
                            widget.call.stopLive();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('End Live'),
                        )
                      else
                        ElevatedButton(
                          onPressed: () {
                            // Handle follow logic
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('Follow'),
                        ),
                      const SizedBox(width: 8),
                      // Close button
                      GestureDetector(
                        onTap: () {
                          widget.call.leave();
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Chat messages (only for viewers)
          if (!isHost)
            Positioned(
              bottom: 100,
              left: 16,
              right: 16,
              child: SizedBox(
                height: 200,
                child: ListView(
                  controller: _chatScrollController,
                  children: [
                    _buildChatMessage(
                      "Casey Brown",
                      "Engage with active listening",
                    ),
                    _buildChatMessage("Morgan Lee", "I love you"),
                    _buildChatMessage("Taylor Johnson", "Just followed you"),
                    _buildChatMessage("Jordan Smith", "Just sent you a gift!"),
                    _buildChatMessage(
                      "Jamie Chen",
                      "Focus on the task at hand",
                    ),
                    _buildChatMessage("Alex walker", "Stop talking a lot"),
                  ],
                ),
              ),
            ),

          // Message input (only for viewers)
          if (!isHost)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: TextField(
                              controller: _messageController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Message...',
                                hintStyle: const TextStyle(
                                  color: Colors.white70,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChatMessage(String username, String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$username: ',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            TextSpan(
              text: message,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// Keep your existing BackstageWidget and LivestreamEndedWidget classes
class BackstageWidget extends StatelessWidget {
  const BackstageWidget({super.key, required this.call});

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
              PartialCallStateBuilder(
                call: call,
                selector: (state) => state.startsAt,
                builder: (context, startsAt) {
                  return Text(
                    startsAt != null
                        ? 'Livestream starting at ${DateFormat('HH:mm').format(startsAt.toLocal())}'
                        : 'Livestream starting soon',
                    style: Theme.of(context).textTheme.titleLarge,
                  );
                },
              ),
              if (waitingParticipantsCount > 0)
                Text('$waitingParticipantsCount participants waiting'),
              ElevatedButton(
                onPressed: () {
                  call.goLive();
                },
                child: const Text('Go Live'),
              ),
              ElevatedButton(
                onPressed: () {
                  call.leave();
                  Navigator.pop(context);
                },
                child: const Text('Leave Livestream'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class LivestreamEndedWidget extends StatefulWidget {
  const LivestreamEndedWidget({super.key, required this.call});

  final Call call;

  @override
  State<LivestreamEndedWidget> createState() => _LivestreamEndedWidgetState();
}

class _LivestreamEndedWidgetState extends State<LivestreamEndedWidget> {
  late Future<Result<List<CallRecording>>> _recordingsFuture;

  @override
  void initState() {
    super.initState();
    _recordingsFuture = widget.call.listRecordings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            widget.call.leave();
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Livestream has ended'),
            FutureBuilder(
              future: _recordingsFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isSuccess) {
                  final recordings = snapshot.requireData.getDataOrNull();

                  if (recordings == null || recordings.isEmpty) {
                    return const Text('No recordings found');
                  }

                  return Column(
                    children: [
                      const Text('Watch recordings'),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: recordings.length,
                        itemBuilder: (context, index) {
                          final recording = recordings[index];
                          return ListTile(
                            title: Text(recording.url),
                            onTap: () {
                              // open
                            },
                          );
                        },
                      ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}

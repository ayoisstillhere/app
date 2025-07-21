import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

import '../../../../constants.dart';
import '../../../../services/auth_manager.dart';

class CustomLivestreamWidget extends StatefulWidget {
  const CustomLivestreamWidget({
    super.key,
    required this.call,
    required this.userName,
    required this.liveStreamId,
  });

  final Call call;
  final String userName;
  final String liveStreamId;

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

  void _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      try {
        final url = Uri.parse(
          '$baseUrl/api/v1/calls/live-stream/${widget.liveStreamId}/comment',
        );
        final token = await AuthManager.getToken();

        final response = await http.post(
          url,
          headers: {
            'accept': '*/*',
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode({'comment': _messageController.text.trim()}),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          _messageController.clear();
          // Refresh messages to show the new one
          // BlocProvider.of<ChatCubit>(context).getTextMessages();
        } else {
          _showErrorSnackBar(
            jsonDecode(
              response.body,
            )['message'].toString().replaceAll(RegExp(r'\[|\]'), ''),
          );
        }
      } catch (e) {
        _showErrorSnackBar('Failed to send message: ${e.toString()}');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(message, style: TextStyle(color: Colors.white)),
      ),
    );
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
                                  if (host != null && host.image!.isNotEmpty) {
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
                                    host != null
                                        ? host.name
                                              .substring(0, 1)
                                              .toUpperCase()
                                        : '',
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
                            Navigator.pop(context);
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
                          if (isHost) {
                            widget.call.stopLive();
                          } else {
                            widget.call.leave();
                          }
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
                  _buildChatMessage("Jamie Chen", "Focus on the task at hand"),
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

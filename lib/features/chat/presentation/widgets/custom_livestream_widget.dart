import 'dart:convert';

import 'package:app/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

import '../../../../constants.dart';
import '../../../../services/auth_manager.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/live_stream_comment_entity.dart';
import '../cubit/live_stream_comment_cubit.dart';

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
  UserEntity? user;
  bool isUserLoaded = false;
  UserEntity? currentUser;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      _fetchUser();
    }
    BlocProvider.of<LiveStreamCommentCubit>(context).getLiveStreamComments();
  }

  Future<void> _fetchUser() async {
    final token = await AuthManager.getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/api/v1/user/profile/${widget.userName}"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          user = UserModel.fromJson(jsonDecode(response.body));
          isUserLoaded = true;
        });
      }
    } else {
      _showErrorSnackBar(response.body);
    }
  }

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
          BlocProvider.of<LiveStreamCommentCubit>(
            context,
          ).getLiveStreamComments();
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
      body: isUserLoaded
          ? Stack(
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
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
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
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent,
                        ],
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
                                      selector: (state) => state
                                          .callParticipants
                                          .where(
                                            (e) => e.roles.contains('host'),
                                          )
                                          .firstOrNull,
                                      builder: (context, host) {
                                        if (host != null &&
                                            host.image!.isNotEmpty) {
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      PartialCallStateBuilder(
                                        call: widget.call,
                                        selector: (state) =>
                                            state.callParticipants
                                                .where(
                                                  (e) =>
                                                      e.roles.contains('host'),
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
                                                NumberFormat.compact().format(
                                                  count,
                                                ),
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
                              user!.isFollowing
                                  ? Container()
                                  : ElevatedButton(
                                      onPressed: () async {
                                        final token =
                                            await AuthManager.getToken();
                                        final response = await http.post(
                                          Uri.parse(
                                            "$baseUrl/api/v1/user/follow",
                                          ),
                                          headers: {
                                            "Authorization": "Bearer $token",
                                            "Content-Type": "application/json",
                                          },
                                          body: jsonEncode({
                                            "userId": user!.id,
                                          }),
                                        );

                                        if (response.statusCode == 200) {
                                          _fetchUser();
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              backgroundColor: Colors.red,
                                              content: Text(
                                                "Failed to follow user. Please try again.",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
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
                    height: getProportionateScreenHeight(282),
                    child:
                        BlocBuilder<
                          LiveStreamCommentCubit,
                          LiveStreamCommentState
                        >(
                          builder: (context, state) {
                            if (state is LiveStreamCommentLoaded) {
                              List<LiveStreamCommentEntity> requiredComments =
                                  [];
                              for (LiveStreamCommentEntity
                                  liveStreamCommentEntity
                                  in state.comments) {
                                if (liveStreamCommentEntity.liveStreamId ==
                                    widget.liveStreamId) {
                                  requiredComments.add(liveStreamCommentEntity);
                                }
                              }

                              requiredComments.sort(
                                (a, b) => a.createdAt.compareTo(b.createdAt),
                              );

                              // Auto-scroll to bottom after build is complete
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (_chatScrollController.hasClients) {
                                  _chatScrollController.animateTo(
                                    _chatScrollController
                                        .position
                                        .maxScrollExtent,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                  );
                                }
                              });

                              return ListView.builder(
                                controller: _chatScrollController,
                                itemCount: requiredComments.length,
                                itemBuilder: (context, index) {
                                  final comment = requiredComments[index];
                                  return _buildChatMessage(
                                    comment.username,
                                    comment.comment,
                                  );
                                },
                              );
                            }
                            return Center(child: CircularProgressIndicator());
                          },
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
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.6),
                          ],
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
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
            )
          : Center(child: CircularProgressIndicator()),
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

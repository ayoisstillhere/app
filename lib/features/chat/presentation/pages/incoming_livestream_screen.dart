import 'dart:convert';

import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stream_video_flutter/stream_video_flutter.dart';

import '../../../../constants.dart';
import '../../../../services/auth_manager.dart';
import 'live_stream_screen.dart';

class IncomingLivestreamScreen extends StatefulWidget {
  final String streamerName;
  final String roomId;
  final UserEntity currentUser;
  final String imageUrl;
  final String streamTitle;

  const IncomingLivestreamScreen({
    super.key,
    required this.streamerName,
    required this.roomId,
    required this.currentUser,
    required this.imageUrl,
    required this.streamTitle,
  });

  @override
  State<IncomingLivestreamScreen> createState() =>
      _IncomingLivestreamScreenState();
}

class _IncomingLivestreamScreenState extends State<IncomingLivestreamScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _liveController;
  late AnimationController _loadingController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _liveAnimation;
  late Animation<double> _loadingAnimation;

  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _liveController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _loadingController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _liveAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _liveController, curve: Curves.easeInOut),
    );

    _loadingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
    _liveController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _liveController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple.shade900, Colors.black87, Colors.black],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Live indicator
                  AnimatedBuilder(
                    animation: _liveAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _liveAnimation.value,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.circle, color: Colors.white, size: 8),
                              SizedBox(width: 4),
                              Text(
                                'LIVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20),

                  Text(
                    'You\'re invited to join',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  SizedBox(height: 8),

                  Text(
                    '${widget.streamerName}\'s Livestream',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),

                  // Animated avatar with pulsing effect
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purple.withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundImage: NetworkImage(widget.imageUrl),
                            backgroundColor: Colors.purple.shade300,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20),

                  Text(
                    widget.streamerName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),

                  if (widget.streamTitle.isNotEmpty)
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        widget.streamTitle,
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  SizedBox(height: 12),

                  // Viewer count
                  // Container(
                  //   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  //   decoration: BoxDecoration(
                  //     color: Colors.white.withOpacity(0.1),
                  //     borderRadius: BorderRadius.circular(15),
                  //   ),
                  //   child: Row(
                  //     mainAxisSize: MainAxisSize.min,
                  //     children: [
                  //       Icon(Icons.visibility, color: Colors.white70, size: 16),
                  // SizedBox(width: 4),
                  // Text(
                  //   '${} watching',
                  //   style: TextStyle(color: Colors.white70, fontSize: 12),
                  // ),
                  //     ],
                  //   ),
                  // ),
                  SizedBox(height: 50),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Decline button
                      GestureDetector(
                        onTap: _isConnecting ? null : _declineLivestream,
                        child: AnimatedOpacity(
                          opacity: _isConnecting ? 0.5 : 1.0,
                          duration: Duration(milliseconds: 200),
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.red.shade600,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 35,
                            ),
                          ),
                        ),
                      ),

                      // Join button with loading state
                      GestureDetector(
                        onTap: _isConnecting ? null : _joinLivestream,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: _isConnecting
                                ? Colors.purple.shade400
                                : Colors.purple.shade600,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purple.withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: _isConnecting
                              ? CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                )
                              : Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 45,
                                ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),

                  // Action labels
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Decline',
                        style: TextStyle(
                          color: _isConnecting
                              ? Colors.white38
                              : Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _isConnecting ? 'Connecting...' : 'Join Stream',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),

              // Loading overlay
              if (_isConnecting)
                AnimatedBuilder(
                  animation: _loadingAnimation,
                  builder: (context, child) {
                    return Container(
                      color: Colors.black.withOpacity(
                        0.3 * _loadingAnimation.value,
                      ),
                      child: Center(
                        child: FadeTransition(
                          opacity: _loadingAnimation,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 50,
                                height: 50,
                                child: CircularProgressIndicator(
                                  color: Colors.purple.shade300,
                                  strokeWidth: 4,
                                ),
                              ),
                              SizedBox(height: 20),
                              Text(
                                'Connecting to livestream...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Please wait while we connect you',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _joinLivestream() async {
    if (_isConnecting) return;

    setState(() {
      _isConnecting = true;
    });

    _loadingController.forward();

    try {
      final token = await AuthManager.getToken();
      String streamToken;
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/calls/live-stream/${widget.roomId}/join'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        streamToken = jsonDecode(response.body)['token'];
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
          userToken: streamToken,
        );

        final call = StreamVideo.instance.makeCall(
          callType: StreamCallType.liveStream(),
          id: jsonDecode(response.body)['liveStream']['roomId'],
        );

        final result = await call.getOrCreate();

        if (result.isSuccess) {
          // Set default behaviour for a livestream viewer
          final connectOptions = CallConnectOptions(
            camera: TrackOption.disabled(),
            microphone: TrackOption.disabled(),
          );

          // Our local app user can join and receive events
          final joinResult = await call.join(connectOptions: connectOptions);
          if (joinResult case Failure failure) {
            debugPrint('Not able to join the call: ${failure.error}');
            _showErrorDialog('Failed to join livestream. Please try again.');
            return;
          }

          // Navigate to the livestream screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LiveStreamScreen(livestreamCall: call),
            ),
          );
        } else {
          _showErrorDialog(
            'Failed to create livestream connection. Please try again.',
          );
        }
      } else {
        _showErrorDialog('Failed to join livestream. Please try again.');
      }
    } catch (e) {
      debugPrint('Error joining livestream: $e');
      _showErrorDialog('Failed to join livestream. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
        _loadingController.reset();
      }
    }
  }

  Future<void> _declineLivestream() async {
    if (_isConnecting) return;
    Navigator.pop(context);
  }

  void _showErrorDialog(String message) {
    if (mounted) {
      setState(() {
        _isConnecting = false;
      });
      _loadingController.reset();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey.shade900,
          title: Text('Error', style: TextStyle(color: Colors.white)),
          content: Text(message, style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK', style: TextStyle(color: Colors.purple)),
            ),
          ],
        ),
      );
    }
  }
}

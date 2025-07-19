// Full Screen Video Player Widget using Media Kit
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

// Full Screen Video Player Widget
class FullScreenVideoPlayer extends StatefulWidget {
  final File videoFile;
  final dynamic message; // Your message object type

  const FullScreenVideoPlayer({
    super.key,
    required this.videoFile,
    required this.message,
  });

  @override
  _FullScreenVideoPlayerState createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  late final Player _player;
  late final VideoController _controller;
  bool _isPlaying = false;
  bool _showControls = true;
  bool _isLoading = true;
  String? _errorMessage;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _fillScreen = false; // Toggle between fit and fill

  @override
  void initState() {
    super.initState();
    _initializeVideo();

    // Hide system UI for immersive experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Future<void> _initializeVideo() async {
    try {
      _player = Player();
      _controller = VideoController(_player);

      // Listen to player state changes
      _player.stream.playing.listen((bool playing) {
        if (mounted) {
          setState(() {
            _isPlaying = playing;
          });
        }
      });

      _player.stream.duration.listen((Duration duration) {
        if (mounted) {
          setState(() {
            _duration = duration;
          });
        }
      });

      _player.stream.position.listen((Duration position) {
        if (mounted) {
          setState(() {
            _position = position;
          });
        }
      });

      // Listen for errors
      _player.stream.error.listen((String error) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Playback error: $error';
            _isLoading = false;
          });
        }
      });

      // Open the video file
      await _player.open(Media('file://${widget.videoFile.path}'));

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading video: $e';
      });
    }
  }

  void _togglePlayPause() {
    _player.playOrPause();
  }

  void _showControlsTemporarily() {
    setState(() {
      _showControls = true;
    });

    // Hide controls after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      if (mounted && _isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  void _seekToPosition(double value) {
    final position = Duration(
      milliseconds: (value * _duration.inMilliseconds).round(),
    );
    _player.seek(position);
  }

  @override
  void dispose() {
    _player.dispose();

    // Restore system UI and orientation
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video Player - Full Screen
          Positioned.fill(
            child: GestureDetector(
              onTap: _showControlsTemporarily,
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, color: Colors.red, size: 64),
                          SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Go Back'),
                          ),
                        ],
                      ),
                    )
                  : Video(
                      controller: _controller,
                      fit: _fillScreen ? BoxFit.cover : BoxFit.contain,
                      controls: NoVideoControls,
                    ),
            ),
          ),
          // Controls Overlay
          if (_showControls && !_isLoading && _errorMessage == null)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: SafeArea(
                  child: Stack(
                    children: [
                      // Close button
                      Positioned(
                        top: 16,
                        left: 16,
                        child: IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 32,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),

                      // Fill/Fit screen toggle button
                      Positioned(
                        top: 16,
                        right: 16,
                        child: IconButton(
                          icon: Icon(
                            _fillScreen
                                ? Icons
                                      .fit_screen // Shows when in fill mode, tap to fit
                                : Icons
                                      .fullscreen, // Shows when in fit mode, tap to fill
                            color: Colors.white,
                            size: 32,
                          ),
                          onPressed: () {
                            setState(() {
                              _fillScreen = !_fillScreen;
                            });
                          },
                        ),
                      ),

                      // Play/Pause button
                      Center(
                        child: IconButton(
                          icon: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 64,
                          ),
                          onPressed: _togglePlayPause,
                        ),
                      ),

                      // Bottom controls
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Progress bar
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: Colors.white,
                                  inactiveTrackColor: Colors.white.withOpacity(
                                    0.3,
                                  ),
                                  thumbColor: Colors.white,
                                  overlayColor: Colors.white.withOpacity(0.2),
                                  trackHeight: 3.0,
                                  thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius: 6.0,
                                  ),
                                ),
                                child: Slider(
                                  value: _duration.inMilliseconds > 0
                                      ? _position.inMilliseconds /
                                            _duration.inMilliseconds
                                      : 0.0,
                                  onChanged: (value) {
                                    _seekToPosition(value);
                                  },
                                ),
                              ),
                              SizedBox(height: 8),
                              // Time display
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(_position),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    _formatDuration(_duration),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Video Thumbnail Generator using Media Kit
class VideoThumbnailWidget extends StatefulWidget {
  final File videoFile;
  final double width;
  final double height;

  const VideoThumbnailWidget({
    super.key,
    required this.videoFile,
    required this.width,
    required this.height,
  });

  @override
  _VideoThumbnailWidgetState createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<VideoThumbnailWidget> {
  late final Player _player;
  late final VideoController _controller;
  bool _initialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      _player = Player();
      _controller = VideoController(_player);

      _player.stream.error.listen((String error) {
        if (mounted) {
          setState(() {
            _hasError = true;
            _initialized = true;
          });
        }
      });

      await _player.open(Media('file://${widget.videoFile.path}'));

      // Seek to 1 second for thumbnail
      await _player.seek(Duration(seconds: 1));

      setState(() {
        _initialized = true;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _initialized = true;
      });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey[800],
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
          ),
        ),
      );
    }

    if (_hasError) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey[800],
        child: Center(
          child: Icon(Icons.video_file, color: Colors.grey[400], size: 32),
        ),
      );
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Video(
        controller: _controller,
        fit: BoxFit.cover,
        controls: NoVideoControls,
      ),
    );
  }
}

// Full Screen Video Player Widget
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

// Full Screen Video Player Widget
class FullScreenVideoPlayerIos extends StatefulWidget {
  final File videoFile;
  final dynamic message; // Your message object type

  const FullScreenVideoPlayerIos({
    super.key,
    required this.videoFile,
    required this.message,
  });

  @override
  _FullScreenVideoPlayerIosState createState() =>
      _FullScreenVideoPlayerIosState();
}

class _FullScreenVideoPlayerIosState extends State<FullScreenVideoPlayerIos> {
  late VideoPlayerController _controller;
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
      _controller = VideoPlayerController.file(widget.videoFile);
      await _controller.initialize();

      _controller.addListener(() {
        setState(() {
          _position = _controller.value.position;
          _duration = _controller.value.duration;
          _isPlaying = _controller.value.isPlaying;
        });
      });

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
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
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

  @override
  void dispose() {
    _isPlaying = false;
    _controller.dispose();

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
          // Video Player - Full Screen (IMPROVED)
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
                  : SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: FittedBox(
                        fit: _fillScreen ? BoxFit.cover : BoxFit.contain,
                        child: SizedBox(
                          width: _controller.value.size.width,
                          height: _controller.value.size.height,
                          child: VideoPlayer(_controller),
                        ),
                      ),
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
                              VideoProgressIndicator(
                                _controller,
                                allowScrubbing: true,
                                colors: VideoProgressColors(
                                  playedColor: Colors.white,
                                  bufferedColor: Colors.white.withOpacity(0.3),
                                  backgroundColor: Colors.white.withOpacity(
                                    0.1,
                                  ),
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

// Optional: Video Thumbnail Generator (if you want to show actual video thumbnails)
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
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    _controller = VideoPlayerController.file(widget.videoFile);
    await _controller.initialize();
    await _controller.seekTo(Duration(seconds: 1)); // Get frame at 1 second
    setState(() {
      _initialized = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
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

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: VideoPlayer(_controller),
    );
  }
}

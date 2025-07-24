// lib/features/chat/presentation/widgets/full_screen_url_video_player_ios.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class FullScreenUrlVideoPlayerIos extends StatefulWidget {
  final String videoUrl;
  final String? title;

  const FullScreenUrlVideoPlayerIos({
    super.key,
    required this.videoUrl,
    this.title,
  });

  @override
  _FullScreenUrlVideoPlayerIosState createState() =>
      _FullScreenUrlVideoPlayerIosState();
}

class _FullScreenUrlVideoPlayerIosState
    extends State<FullScreenUrlVideoPlayerIos> {
  late VideoPlayerController _controller;

  bool _isLoading = true;
  bool _showControls = true;
  bool _fillScreen = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeVideo();

    // Hide system UI for immersive experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: false,
          allowBackgroundPlayback: false,
        ),
      );

      // Listen to player state changes
      _controller.addListener(() {
        if (mounted) {
          setState(() {
            // Update state when controller changes
          });
        }
      });

      // Initialize the controller
      await _controller.initialize();

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
      if (mounted && _controller.value.isPlaying) {
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
      milliseconds: (value * _controller.value.duration.inMilliseconds).round(),
    );
    _controller.seekTo(position);
  }

  @override
  void dispose() {
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
                  : _controller.value.isInitialized
                  ? FittedBox(
                      fit: _fillScreen ? BoxFit.cover : BoxFit.contain,
                      child: SizedBox(
                        width: _controller.value.size.width,
                        height: _controller.value.size.height,
                        child: VideoPlayer(_controller),
                      ),
                    )
                  : Center(
                      child: CircularProgressIndicator(color: Colors.white),
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

                      // Title if provided
                      if (widget.title != null)
                        Positioned(
                          top: 16,
                          left: 64,
                          right: 64,
                          child: Text(
                            widget.title!,
                            style: TextStyle(color: Colors.white, fontSize: 16),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                      // Fill/Fit screen toggle button
                      Positioned(
                        top: 16,
                        right: 16,
                        child: IconButton(
                          icon: Icon(
                            _fillScreen ? Icons.fit_screen : Icons.fullscreen,
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
                            _controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
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
                                  trackHeight: 4.0,
                                  thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius: 8.0,
                                  ),
                                  overlayShape: RoundSliderOverlayShape(
                                    overlayRadius: 16.0,
                                  ),
                                  thumbColor: Colors.white,
                                  activeTrackColor: Colors.white,
                                  inactiveTrackColor: Colors.white.withOpacity(
                                    0.3,
                                  ),
                                  overlayColor: Colors.white.withOpacity(0.3),
                                ),
                                child: Slider(
                                  value:
                                      _controller.value.isInitialized &&
                                          _controller
                                                  .value
                                                  .duration
                                                  .inMilliseconds >
                                              0
                                      ? _controller
                                                .value
                                                .position
                                                .inMilliseconds /
                                            _controller
                                                .value
                                                .duration
                                                .inMilliseconds
                                      : 0.0,
                                  onChanged: _seekToPosition,
                                ),
                              ),

                              // Time indicators
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _controller.value.isInitialized
                                          ? _formatDuration(
                                              _controller.value.position,
                                            )
                                          : '00:00:00',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      _controller.value.isInitialized
                                          ? _formatDuration(
                                              _controller.value.duration,
                                            )
                                          : '00:00:00',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
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

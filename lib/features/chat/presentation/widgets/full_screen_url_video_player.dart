// lib/features/chat/presentation/widgets/full_screen_url_video_player.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class FullScreenUrlVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String? title;

  const FullScreenUrlVideoPlayer({
    super.key,
    required this.videoUrl,
    this.title,
  });

  @override
  _FullScreenUrlVideoPlayerState createState() =>
      _FullScreenUrlVideoPlayerState();
}

class _FullScreenUrlVideoPlayerState extends State<FullScreenUrlVideoPlayer> {
  late final Player _player;
  late final VideoController _controller;

  bool _isLoading = true;
  bool _isPlaying = false;
  bool _showControls = true;
  bool _fillScreen = false;
  String? _errorMessage;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializeVideo();

    // Hide system UI for immersive experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Future<void> _initializeVideo() async {
    try {
      _player = Player(
        configuration: PlayerConfiguration(
          // Try different audio configurations
          libass: false, // Disable subtitles rendering if not needed
          bufferSize: 32 * 1024 * 1024, // Increase buffer size
        ),
      );
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

      // Open the video URL
      await _player.open(Media(widget.videoUrl));

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
                                      _position.inMilliseconds > 0 &&
                                          _duration.inMilliseconds > 0
                                      ? _position.inMilliseconds /
                                            _duration.inMilliseconds
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
                                      _formatDuration(_position),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      _formatDuration(_duration),
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

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FullScreenFileImageViewer extends StatefulWidget {
  final File imageFile;
  final String? title;
  final List<File>?
  imageFiles; // Optional: for gallery mode with multiple images
  final int? initialIndex; // Optional: starting index for gallery mode

  const FullScreenFileImageViewer({
    super.key,
    required this.imageFile,
    this.title,
    this.imageFiles,
    this.initialIndex,
  });

  @override
  State<FullScreenFileImageViewer> createState() =>
      _FullScreenFileImageViewerState();
}

class _FullScreenFileImageViewerState extends State<FullScreenFileImageViewer> {
  late PageController _pageController;
  late int _currentIndex;
  bool _isGalleryMode = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex ?? 0;
    _isGalleryMode = widget.imageFiles != null && widget.imageFiles!.length > 1;
    _pageController = PageController(initialPage: _currentIndex);

    // Set full screen mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _showAppBar() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void _hideAppBar() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.5),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isGalleryMode)
            IconButton(
              icon: Icon(Icons.info_outline, color: Colors.white),
              onPressed: () {
                _showImageInfo();
              },
            ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          // Toggle app bar visibility
          if (SystemChrome.latestStyle?.statusBarBrightness ==
              Brightness.dark) {
            _hideAppBar();
          } else {
            _showAppBar();
          }
        },
        child: _isGalleryMode ? _buildGalleryView() : _buildSingleImageView(),
      ),
    );
  }

  Widget _buildSingleImageView() {
    return Center(
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Image.file(
          widget.imageFile,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.white, size: 64),
                  SizedBox(height: 16),
                  Text(
                    'Unable to load image',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGalleryView() {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          itemCount: widget.imageFiles!.length,
          itemBuilder: (context, index) {
            return Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.file(
                  widget.imageFiles![index],
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 64,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Unable to load image',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
        // Navigation arrows for gallery mode
        if (widget.imageFiles!.length > 1) ...[
          // Previous button
          if (_currentIndex > 0)
            Positioned(
              left: 20,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    _pageController.previousPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
          // Next button
          if (_currentIndex < widget.imageFiles!.length - 1)
            Positioned(
              right: 20,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
        ],
        // Page indicator dots
        if (widget.imageFiles!.length > 1)
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.imageFiles!.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentIndex
                        ? Colors.white
                        : Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showImageInfo() {
    final currentFile = widget.imageFiles![_currentIndex];
    final fileStat = currentFile.statSync();
    final fileSize = (fileStat.size / 1024 / 1024).toStringAsFixed(2); // MB

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.8),
        title: Text('Image Info', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'File: ${currentFile.path.split('/').last}',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 8),
            Text('Size: $fileSize MB', style: TextStyle(color: Colors.white)),
            SizedBox(height: 8),
            Text(
              'Modified: ${fileStat.modified.toString().split('.').first}',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// Usage Examples:

// Single image viewer:
// Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (context) => FullScreenFileImageViewer(
//       imageFile: File('path/to/image.jpg'),
//       title: 'My Image',
//     ),
//   ),
// );

// Gallery mode with multiple images:
// Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (context) => FullScreenFileImageViewer(
//       imageFile: imageFiles[0], // This parameter is still required but not used in gallery mode
//       imageFiles: imageFiles, // List of File objects
//       initialIndex: 0, // Starting index
//       title: 'My Gallery',
//     ),
//   ),
// );

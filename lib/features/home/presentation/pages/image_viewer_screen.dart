import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../components/social_text.dart';
import '../../../../constants.dart';
import '../../../../size_config.dart';

class ImageViewerScreen extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String authorName;
  final String authorHandle;
  final String authorImageUrl;
  final String content;
  final DateTime postTime;

  const ImageViewerScreen({
    super.key,
    required this.images,
    this.initialIndex = 0,
    required this.authorName,
    required this.authorHandle,
    required this.authorImageUrl,
    required this.content,
    required this.postTime,
  });

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    // Set status bar to transparent
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Reset status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              // Image viewer section
              Expanded(
                flex: 3,
                child: SizedBox(
                  width: double.infinity,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemCount: widget.images.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.all(8.0),
                        child: InteractiveViewer(
                          minScale: 0.5,
                          maxScale: 4.0,
                          child: Center(
                            child: Image.network(
                              widget.images[index],
                              fit: BoxFit.contain,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value:
                                            loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                            : null,
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons.error,
                                    color: Colors.white,
                                    size: 50,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Post content section
              Expanded(
                flex: 1,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: const BoxDecoration(color: Colors.black),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Author info
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(
                                widget.authorImageUrl.isEmpty
                                    ? 'https://via.placeholder.com/40'
                                    : widget.authorImageUrl,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.authorName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    '@${widget.authorHandle}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Post content
                        SocialText(
                          text: widget.content,
                          baseStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Post time
                        Text(
                          _formatDateTime(widget.postTime),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Bottom slider indicators (dots)
          if (widget.images.length > 1)
            Positioned(
              bottom: getProportionateScreenHeight(203),
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.images.length,
                  (index) => AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(
                      horizontal: getProportionateScreenWidth(2),
                    ),
                    height: getProportionateScreenHeight(6),
                    width: getProportionateScreenWidth(6),
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? kLightPurple
                          : kLightPurple.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(
                        getProportionateScreenWidth(3),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  PreferredSizeWidget _buildAppBar() {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final iconColor = isDarkMode ? kWhite : kBlack;
    return AppBar(
      title: Text(
        "Post",
        style: TextStyle(
          fontSize: getProportionateScreenHeight(24),
          fontWeight: FontWeight.w500,
        ),
      ),
      centerTitle: false,
      actions: [
        Padding(
          padding: EdgeInsets.only(right: getProportionateScreenWidth(22)),
          child: InkWell(
            onTap: () {},
            child: SvgPicture.asset(
              "assets/icons/more-vertical.svg",
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              width: getProportionateScreenWidth(24),
              height: getProportionateScreenHeight(24),
            ),
          ),
        ),
      ],
    );
  }
}

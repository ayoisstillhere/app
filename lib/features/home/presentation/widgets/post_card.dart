import 'package:app/features/home/presentation/pages/post_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;

import 'package:app/components/social_text.dart';
import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:app/features/profile/presentation/pages/profile_screen.dart';

import '../../../../components/nav_page.dart';
import '../../../../constants.dart';
import '../../../../services/auth_manager.dart';
import '../../../../size_config.dart';
import '../../../chat/presentation/widgets/full_screen_url_video_player.dart';
import '../pages/image_viewer_screen.dart';
import '../pages/write_comment_screen.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class PostCard extends StatefulWidget {
  PostCard({
    super.key,
    required this.dividerColor,
    required this.iconColor,
    required this.authorName,
    required this.authorHandle,
    required this.imageUrl,
    required this.postTime,
    required this.likes,
    required this.comments,
    required this.reposts,
    required this.bookmarks,
    required this.content,
    this.pictures = const [],
    this.forSearch = false,
    required this.currentUser,
    required this.postId,
    this.notClickable = false,
    required this.isLiked,
    required this.isReposted,
    required this.isSaved,
    this.onCommentAdded,
    // Make sure these are properly set
    this.isReply = false,
    this.replyingToHandle,
  });

  final Color dividerColor;
  final Color iconColor;
  final String authorName;
  final String authorHandle;
  final String imageUrl;
  final DateTime postTime;
  int likes;
  final int comments;
  int reposts;
  int bookmarks;
  final String content;
  final List<dynamic> pictures;
  final bool forSearch;
  final UserEntity currentUser;
  final String postId;
  final bool notClickable;
  bool isLiked;
  bool isReposted;
  bool isSaved;
  final VoidCallback? onCommentAdded;
  // New properties for reply functionality
  final bool isReply;
  final String? replyingToHandle;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  // Add this computed property to your PostCard class
  bool get isReply => widget.isReply || (widget.replyingToHandle != null);
  late PageController _pageController;
  int _currentPage = 0;
  final List<Player?> _videoPlayers = [];
  final List<VideoController?> _videoControllers = [];
  bool get myPost => widget.currentUser.username == widget.authorHandle;

  // Check if URL is a video based on file extension
  bool _isVideoUrl(String url) {
    final videoExtensions = [
      'mp4',
      'mov',
      'avi',
      'mkv',
      'webm',
      'm4v',
      '3gp',
      'flv',
    ];
    final uri = Uri.parse(url);
    final extension = uri.pathSegments.isNotEmpty
        ? uri.pathSegments.last.split('.').last.toLowerCase()
        : '';
    return videoExtensions.contains(extension);
  }

  // Get media items from pictures list
  List<Map<String, dynamic>> get _mediaItems {
    return widget.pictures.map((pic) {
      final url = pic as String;
      return {'url': url, 'type': _isVideoUrl(url) ? 'video' : 'image'};
    }).toList();
  }

  void _onLike() async {
    final token = await AuthManager.getToken();
    final wasLiked = widget.isLiked;

    setState(() {
      if (wasLiked) {
        widget.likes--;
      } else {
        widget.likes++;
      }
      widget.isLiked = !widget.isLiked;
    });

    if (wasLiked) {
      await http.delete(
        Uri.parse("$baseUrl/api/v1/posts/${widget.postId}/like"),
        headers: {"Authorization": "Bearer $token"},
      );
    } else {
      await http.post(
        Uri.parse("$baseUrl/api/v1/posts/${widget.postId}/like"),
        headers: {"Authorization": "Bearer $token"},
      );
    }
  }

  void _onRepost() async {
    final token = await AuthManager.getToken();
    final wasReposted = widget.isReposted;

    setState(() {
      if (wasReposted) {
        widget.reposts--;
      } else {
        widget.reposts++;
      }
      widget.isReposted = !widget.isReposted;
    });

    if (wasReposted) {
      await http.delete(
        Uri.parse("$baseUrl/api/v1/posts/${widget.postId}/repost"),
        headers: {"Authorization": "Bearer $token"},
      );
    } else {
      await http.post(
        Uri.parse("$baseUrl/api/v1/posts/${widget.postId}/repost"),
        headers: {"Authorization": "Bearer $token"},
      );
    }
  }

  void _onSave() async {
    final token = await AuthManager.getToken();
    final wasSaved = widget.isSaved;

    setState(() {
      if (wasSaved) {
        widget.bookmarks--;
      } else {
        widget.bookmarks++;
      }
      widget.isSaved = !widget.isSaved;
    });

    if (wasSaved) {
      await http.delete(
        Uri.parse("$baseUrl/api/v1/posts/${widget.postId}/save"),
        headers: {"Authorization": "Bearer $token"},
      );
    } else {
      await http.post(
        Uri.parse("$baseUrl/api/v1/posts/${widget.postId}/save"),
        headers: {"Authorization": "Bearer $token"},
      );
    }
  }

  Future<void> _deletePost() async {
    final token = await AuthManager.getToken();
    final response = await http.delete(
      Uri.parse("$baseUrl/api/v1/posts/${widget.postId}"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 204) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NavPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Failed to delete post. Please try again.",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  void _openImageViewer(int initialIndex) {
    // Filter only images for the image viewer
    final imageUrls = _mediaItems
        .where((item) => item['type'] == 'image')
        .map((item) => item['url'] as String)
        .toList();

    if (imageUrls.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageViewerScreen(
            images: imageUrls,
            initialIndex: initialIndex,
            authorName: widget.authorName,
            authorHandle: widget.authorHandle,
            authorImageUrl: widget.imageUrl,
            content: widget.content,
            postTime: widget.postTime,
          ),
        ),
      );
    }
  }

  void _initializeVideoControllers() {
    // Clear any existing players
    _disposeVideoControllers();

    // Create new players for each video
    for (var item in _mediaItems) {
      if (item['type'] == 'video') {
        final player = Player();
        final controller = VideoController(player);

        _videoPlayers.add(player);
        _videoControllers.add(controller);

        // Initialize the player with the video URL
        player.open(Media(item['url']));
        player.pause();
      } else {
        // Add null for non-video items to maintain index alignment
        _videoPlayers.add(null);
        _videoControllers.add(null);
      }
    }
  }

  void _disposeVideoControllers() {
    for (var player in _videoPlayers) {
      if (player != null) {
        player.dispose();
      }
    }
    _videoPlayers.clear();
    _videoControllers.clear();
  }

  Widget _buildMediaItem(Map<String, dynamic> mediaItem, int index) {
    final isVideo = mediaItem['type'] == 'video';
    final url = mediaItem['url'] as String;

    if (isVideo) {
      final player = _videoPlayers[index];
      final controller = _videoControllers[index];

      return GestureDetector(
        onTap: () {
          // Navigate to full screen URL video player
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FullScreenUrlVideoPlayer(
                videoUrl: url,
                title: widget.content,
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              getProportionateScreenWidth(10),
            ),
            color: Colors.black,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Video thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  getProportionateScreenWidth(10),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: controller != null
                      ? Video(
                          controller: controller,
                          fit: BoxFit.contain,
                          controls: NoVideoControls,
                        )
                      : Center(child: CircularProgressIndicator()),
                ),
              ),
              // Play button indicator
              Center(
                child: Icon(
                  Icons.play_circle_fill,
                  size: 64,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Image handling (keep your existing code for images)
      return GestureDetector(
        onTap: () => _openImageViewer(index),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(getProportionateScreenWidth(10)),
          child: Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(
                    getProportionateScreenWidth(10),
                  ),
                ),
                child: Icon(Icons.error, color: Colors.red),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(
                    getProportionateScreenWidth(10),
                  ),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (_mediaItems.isNotEmpty) {
      _initializeVideoControllers();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _disposeVideoControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (widget.notClickable) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return PostDetailsScreen(
                postId: widget.postId,
                currentUser: widget.currentUser,
              );
            },
          ),
        );
      },
      child: Container(
        width: widget.forSearch
            ? getProportionateScreenWidth(391)
            : double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: getProportionateScreenWidth(18),
          vertical: getProportionateScreenHeight(10),
        ),
        margin: EdgeInsets.only(top: getProportionateScreenHeight(6)),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: widget.dividerColor, width: 1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(
                          isVerified: true,
                          userName: widget.authorHandle,
                          currentUser: widget.currentUser,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: getProportionateScreenHeight(30),
                    width: getProportionateScreenWidth(30),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: widget.imageUrl.isEmpty
                            ? NetworkImage(defaultAvatar)
                            : NetworkImage(widget.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: getProportionateScreenWidth(10)),
                // Modified section to handle both regular posts and replies
                widget.isReply || (widget.replyingToHandle != null)
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                widget.authorName,
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: getProportionateScreenHeight(
                                        15,
                                      ),
                                    ),
                              ),
                              SizedBox(width: getProportionateScreenWidth(2)),
                              Text(
                                '@${widget.authorHandle}',
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .copyWith(
                                      fontWeight: FontWeight.normal,
                                      fontSize: getProportionateScreenHeight(
                                        13,
                                      ),
                                      color: kGreyHandleText,
                                    ),
                              ),
                              SizedBox(width: getProportionateScreenWidth(2)),
                              Text(
                                '.',
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .copyWith(
                                      fontWeight: FontWeight.normal,
                                      fontSize: getProportionateScreenHeight(
                                        13,
                                      ),
                                      color: kGreyHandleText,
                                    ),
                              ),
                              SizedBox(width: getProportionateScreenWidth(2)),
                              Text(
                                _formatTime(widget.postTime),
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: getProportionateScreenHeight(
                                        12,
                                      ),
                                      color: kGreyTimeText,
                                    ),
                              ),
                            ],
                          ),
                          SizedBox(height: getProportionateScreenHeight(2)),
                          if (widget.replyingToHandle != null)
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'replying to ',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(fontWeight: FontWeight.w500),
                                  ),
                                  TextSpan(
                                    text: '@${widget.replyingToHandle}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: kAccentColor,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      )
                    : Row(
                        children: [
                          Text(
                            widget.authorName,
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: getProportionateScreenHeight(15),
                                ),
                          ),
                          SizedBox(width: getProportionateScreenWidth(2)),
                          Text(
                            '@${widget.authorHandle}',
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  fontWeight: FontWeight.normal,
                                  fontSize: getProportionateScreenHeight(13),
                                  color: kGreyHandleText,
                                ),
                          ),
                          SizedBox(width: getProportionateScreenWidth(2)),
                          Text(
                            '.',
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  fontWeight: FontWeight.normal,
                                  fontSize: getProportionateScreenHeight(13),
                                  color: kGreyHandleText,
                                ),
                          ),
                          SizedBox(width: getProportionateScreenWidth(2)),
                          Text(
                            _formatTime(widget.postTime),
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: getProportionateScreenHeight(12),
                                  color: kGreyTimeText,
                                ),
                          ),
                        ],
                      ),
                Spacer(),
                myPost
                    ? PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'Delete Post') {
                            await _deletePost();
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem<String>(
                            value: 'Delete Post',
                            child: Text(
                              'Delete Post',
                              style: TextStyle(
                                fontSize: getProportionateScreenWidth(15),
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: SvgPicture.asset(
                          "assets/icons/more-vertical.svg",
                          height: getProportionateScreenHeight(17),
                          width: getProportionateScreenWidth(17),
                          colorFilter: ColorFilter.mode(
                            widget.iconColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      )
                    : SvgPicture.asset(
                        "assets/icons/more-vertical.svg",
                        height: getProportionateScreenHeight(17),
                        width: getProportionateScreenWidth(17),
                        colorFilter: ColorFilter.mode(
                          widget.iconColor,
                          BlendMode.srcIn,
                        ),
                      ),
              ],
            ),
            SizedBox(height: getProportionateScreenHeight(5)),
            Padding(
              padding: EdgeInsets.only(
                left: getProportionateScreenWidth(37),
                right: getProportionateScreenWidth(10),
              ),
              child: SocialText(
                text: widget.content,
                baseStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontSize: getProportionateScreenHeight(15),
                ),
                onHashtagTap: (p0) {},
                onMentionTap: (p0) {},
              ),
            ),
            _mediaItems.isEmpty
                ? Container()
                : SizedBox(height: getProportionateScreenHeight(10)),
            _mediaItems.isEmpty
                ? Container()
                : _mediaItems.length == 1
                ? Padding(
                    padding: EdgeInsets.only(
                      left: getProportionateScreenWidth(37),
                      right: getProportionateScreenWidth(10),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: getProportionateScreenHeight(193),
                      child: _buildMediaItem(_mediaItems[0], 0),
                    ),
                  )
                : Column(
                    children: [
                      Container(
                        height: getProportionateScreenHeight(193),
                        margin: EdgeInsets.only(
                          left: getProportionateScreenWidth(37),
                          right: getProportionateScreenWidth(10),
                        ),
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (int page) {
                            setState(() {
                              _currentPage = page;
                            });
                          },
                          itemCount: _mediaItems.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.only(
                                right: getProportionateScreenWidth(5),
                              ),
                              child: _buildMediaItem(_mediaItems[index], index),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: getProportionateScreenHeight(12)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _mediaItems.length,
                          (index) => AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            margin: EdgeInsets.symmetric(
                              horizontal: getProportionateScreenWidth(2),
                            ),
                            height: getProportionateScreenHeight(6),
                            width: getProportionateScreenWidth(6),
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? kLightPurple
                                  : kLightPurple.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(
                                getProportionateScreenWidth(3),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
            SizedBox(height: getProportionateScreenHeight(24)),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(37),
                vertical: getProportionateScreenHeight(5),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: getProportionateScreenWidth(36.55),
                    child: Row(
                      children: [
                        widget.isLiked
                            ? InkWell(
                                onTap: _onLike,
                                child: SvgPicture.asset(
                                  "assets/icons/heart_red.svg",
                                  height: getProportionateScreenHeight(20),
                                  width: getProportionateScreenWidth(20),
                                ),
                              )
                            : InkWell(
                                onTap: _onLike,
                                child: SvgPicture.asset(
                                  "assets/icons/heart.svg",
                                  height: getProportionateScreenHeight(20),
                                  width: getProportionateScreenWidth(20),
                                  colorFilter: ColorFilter.mode(
                                    widget.iconColor,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                        Spacer(),
                        Text('${widget.likes}'),
                      ],
                    ),
                  ),
                  Spacer(),
                  SizedBox(
                    width: getProportionateScreenWidth(36.55),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () async {
                            // Navigate to WriteCommentScreen
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WriteCommentScreen(
                                  currentUser: widget.currentUser,
                                  postId: widget.postId,
                                  authorProfileImage: widget.imageUrl,
                                  authorName: widget.authorName,
                                  media: [],
                                  content: widget.content,
                                  createdAt:
                                      widget.postTime, // Pass the current user
                                ),
                              ),
                            );

                            // If comment was posted successfully, you might want to refresh the post
                            if (result == true) {
                              // Optionally refresh the post data or increment comment count
                              // You can call a callback function here to update the parent widget
                              if (widget.onCommentAdded != null) {
                                widget.onCommentAdded!();
                              }
                            }
                          },
                          child: SvgPicture.asset(
                            "assets/icons/chats.svg",
                            height: getProportionateScreenHeight(20),
                            width: getProportionateScreenWidth(20),
                            colorFilter: ColorFilter.mode(
                              widget.iconColor,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        Spacer(),
                        Text('${widget.comments}'),
                      ],
                    ),
                  ),
                  Spacer(),
                  SizedBox(
                    width: getProportionateScreenWidth(36.55),
                    child: Row(
                      children: [
                        widget.isReposted
                            ? InkWell(
                                onTap: _onRepost,
                                child: SvgPicture.asset(
                                  "assets/icons/repeat_green.svg",
                                  height: getProportionateScreenHeight(20),
                                  width: getProportionateScreenWidth(20),
                                ),
                              )
                            : InkWell(
                                onTap: _onRepost,
                                child: SvgPicture.asset(
                                  "assets/icons/repost.svg",
                                  height: getProportionateScreenHeight(20),
                                  width: getProportionateScreenWidth(20),
                                  colorFilter: ColorFilter.mode(
                                    widget.iconColor,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                        Spacer(),
                        Text('${widget.reposts}'),
                      ],
                    ),
                  ),
                  Spacer(),
                  SizedBox(
                    width: getProportionateScreenWidth(36.55),
                    child: Row(
                      children: [
                        widget.isSaved
                            ? InkWell(
                                onTap: _onSave,
                                child: Icon(
                                  Icons.bookmark,
                                  size: getProportionateScreenHeight(20),
                                  color: kLightPurple,
                                ),
                              )
                            : InkWell(
                                onTap: _onSave,
                                child: SvgPicture.asset(
                                  "assets/icons/bookmark.svg",
                                  height: getProportionateScreenHeight(20),
                                  width: getProportionateScreenWidth(20),
                                  colorFilter: ColorFilter.mode(
                                    widget.iconColor,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                        Spacer(),
                        Text('${widget.bookmarks}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: getProportionateScreenHeight(10)),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }
}

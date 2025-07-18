import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:video_compress/video_compress.dart';

import 'package:app/size_config.dart';

import '../../../../constants.dart';
import '../../../../services/auth_manager.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key, required this.profileImage});
  final String profileImage;

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _postController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;
  List<File> selectedImages = [];
  List<File> selectedVideos = [];
  Map<String, VideoPlayerController> videoControllers = {};

  @override
  void initState() {
    super.initState();
    _postController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _postController.removeListener(() {});
    _postController.dispose();
    // Dispose video controllers
    for (var controller in videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<File> compressImage(File file) async {
    final compressedBytes = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: 50, // adjust as needed
    );

    final compressedFile = File('${file.path}_compressed.jpg')
      ..writeAsBytesSync(compressedBytes!);
    return compressedFile;
  }

  Future<File> compressVideo(File file) async {
    final compressedVideo = await VideoCompress.compressVideo(
      file.path,
      quality: VideoQuality.MediumQuality,
      deleteOrigin: false,
      includeAudio: true,
    );

    if (compressedVideo != null) {
      return File(compressedVideo.path!);
    }
    return file; // Return original if compression fails
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          isLoading = true;
        });

        List<File> compressedImages = [];
        for (XFile image in images) {
          File originalFile = File(image.path);
          File compressedFile = await compressImage(originalFile);
          compressedImages.add(compressedFile);
        }

        setState(() {
          selectedImages.addAll(compressedImages);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Error picking images: $e',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  Future<void> _pickVideoFromGallery() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        setState(() {
          isLoading = true;
        });

        File originalVideoFile = File(video.path);

        // Compress video
        File compressedVideoFile = await compressVideo(originalVideoFile);

        // Initialize video controller for preview
        VideoPlayerController controller = VideoPlayerController.file(
          compressedVideoFile,
        );
        await controller.initialize();

        setState(() {
          selectedVideos.add(compressedVideoFile);
          videoControllers[compressedVideoFile.path] = controller;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Error picking video: $e',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          isLoading = true;
        });

        File originalFile = File(image.path);
        File compressedFile = await compressImage(originalFile);

        setState(() {
          selectedImages.add(compressedFile);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Error taking photo: $e',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  Future<void> _pickVideoFromCamera() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
      if (video != null) {
        setState(() {
          isLoading = true;
        });

        File originalVideoFile = File(video.path);

        // Compress video
        File compressedVideoFile = await compressVideo(originalVideoFile);

        // Initialize video controller for preview
        VideoPlayerController controller = VideoPlayerController.file(
          compressedVideoFile,
        );
        await controller.initialize();

        setState(() {
          selectedVideos.add(compressedVideoFile);
          videoControllers[compressedVideoFile.path] = controller;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Error recording video: $e',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
  }

  void _removeVideo(int index) {
    final videoFile = selectedVideos[index];
    final controller = videoControllers[videoFile.path];
    if (controller != null) {
      controller.dispose();
      videoControllers.remove(videoFile.path);
    }
    setState(() {
      selectedVideos.removeAt(index);
    });
  }

  void _showMediaOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery Images'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: Icon(Icons.video_library),
                title: Text('Gallery Videos'),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideoFromGallery();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: Icon(Icons.videocam),
                title: Text('Camera Video'),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideoFromCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _createPost() async {
    if (_postController.text.isEmpty &&
        selectedImages.isEmpty &&
        selectedVideos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Please add some content, images, or videos',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final token = await AuthManager.getToken();
      final uri = Uri.parse('$baseUrl/api/v1/posts');

      var request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['content'] = _postController.text.trim();

      // Add images with proper MIME type detection
      for (int i = 0; i < selectedImages.length; i++) {
        final file = selectedImages[i];
        final mimeType =
            lookupMimeType(file.path) ?? 'application/octet-stream';
        final mimeSplit = mimeType.split('/');

        request.files.add(
          http.MultipartFile(
            'media',
            file.readAsBytes().asStream(),
            file.lengthSync(),
            filename: file.path.split('/').last,
            contentType: MediaType(mimeSplit[0], mimeSplit[1]),
          ),
        );
      }

      // Add videos with proper MIME type detection
      for (int i = 0; i < selectedVideos.length; i++) {
        final file = selectedVideos[i];
        final mimeType = lookupMimeType(file.path) ?? 'video/mp4';
        final mimeSplit = mimeType.split('/');

        request.files.add(
          http.MultipartFile(
            'media',
            file.readAsBytes().asStream(),
            file.lengthSync(),
            filename: file.path.split('/').last,
            contentType: MediaType(mimeSplit[0], mimeSplit[1]),
          ),
        );
      }

      // Add empty links field if no links
      request.files.add(
        http.MultipartFile.fromBytes("links", [], filename: ""),
      );

      final response = await request.send();

      if (response.statusCode == 201) {
        Navigator.pop(context);
      } else {
        final responseBody = await response.stream.bytesToString();
        final errorMessage = jsonDecode(
          responseBody,
        )['message'].toString().replaceAll(RegExp(r'\[|\]'), '');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(errorMessage, style: TextStyle(color: Colors.white)),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Error creating post: $e',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _buildVideoPreview(File videoFile, int index) {
    final controller = videoControllers[videoFile.path];
    if (controller == null) return Container();

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              getProportionateScreenWidth(10),
            ),
            color: Colors.black,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              getProportionateScreenWidth(10),
            ),
            child: AspectRatio(
              aspectRatio: 1.0, // Force a square aspect ratio for the container
              child: Center(
                child: controller.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: controller.value.aspectRatio,
                        child: VideoPlayer(controller),
                      )
                    : CircularProgressIndicator(),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 5,
          left: 5,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${(controller.value.duration.inMinutes).toString().padLeft(2, '0')}:${(controller.value.duration.inSeconds % 60).toString().padLeft(2, '0')}',
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ),
        Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          right: 0,
          child: Center(
            child: Icon(
              Icons.play_circle_fill,
              color: Colors.white70,
              size: 40,
            ),
          ),
        ),
        Positioned(
          top: 5,
          right: 5,
          child: InkWell(
            onTap: () => _removeVideo(index),
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final iconColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kWhite
        : kBlack;
    final dividerColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kGreyInputFillDark
        : kGreyInputBorder;
    final textAreaColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kBlack
        : Colors.transparent;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(getProportionateScreenHeight(70)),
        child: AppBar(
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: getProportionateScreenHeight(12),
              ),
              child: SvgPicture.asset(
                "assets/icons/x.svg",
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
            ),
          ),
          title: Text(
            "New Post",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: getProportionateScreenWidth(20),
            ),
          ),
          centerTitle: false,
          shape: Border(bottom: BorderSide(color: dividerColor, width: 1)),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SizedBox(height: getProportionateScreenHeight(17)),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: getProportionateScreenWidth(14),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(getProportionateScreenWidth(12)),
                    height: getProportionateScreenHeight(182),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: textAreaColor,
                      border: Border.all(color: dividerColor, width: 1),
                      borderRadius: BorderRadius.circular(
                        getProportionateScreenWidth(10),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: getProportionateScreenHeight(34),
                              width: getProportionateScreenWidth(34),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: widget.profileImage.isEmpty
                                      ? NetworkImage(defaultAvatar)
                                      : NetworkImage(widget.profileImage),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: getProportionateScreenWidth(10)),
                            Expanded(
                              child: TextFormField(
                                controller: _postController,
                                decoration: InputDecoration(
                                  hintText: "what's on your mind?",
                                  hintStyle: TextStyle(
                                    fontSize: getProportionateScreenWidth(16),
                                    color: kGreyFormHint,
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  fillColor: Colors.transparent,
                                  filled: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                maxLines: 3,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        Row(
                          children: [
                            InkWell(
                              onTap: _showMediaOptions,
                              child: SvgPicture.asset(
                                "assets/icons/post_image.svg",
                                height: getProportionateScreenHeight(18),
                                width: getProportionateScreenWidth(18),
                              ),
                            ),
                            SizedBox(width: getProportionateScreenWidth(26)),
                            InkWell(
                              onTap: _showMediaOptions,
                              child: SvgPicture.asset(
                                "assets/icons/post_camera.svg",
                                height: getProportionateScreenHeight(18),
                                width: getProportionateScreenWidth(18),
                              ),
                            ),
                            SizedBox(width: getProportionateScreenWidth(26)),
                            InkWell(
                              onTap: () {},
                              child: SvgPicture.asset(
                                "assets/icons/post_link.svg",
                                height: getProportionateScreenHeight(18),
                                width: getProportionateScreenWidth(18),
                              ),
                            ),
                            Spacer(),
                            InkWell(
                              onTap: _createPost,
                              child: Container(
                                height: getProportionateScreenHeight(30),
                                width: getProportionateScreenWidth(50),
                                decoration: BoxDecoration(
                                  color:
                                      (_postController.text.isNotEmpty ||
                                          selectedImages.isNotEmpty ||
                                          selectedVideos.isNotEmpty)
                                      ? kLightPurple
                                      : kLightPurple.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    "Send",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: kBlack,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Display selected media
                if (selectedImages.isNotEmpty || selectedVideos.isNotEmpty)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(getProportionateScreenWidth(14)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Selected Media (${selectedImages.length + selectedVideos.length})",
                            style: TextStyle(
                              fontSize: getProportionateScreenWidth(16),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: getProportionateScreenHeight(10)),
                          Expanded(
                            child: GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing:
                                        getProportionateScreenWidth(10),
                                    mainAxisSpacing:
                                        getProportionateScreenHeight(10),
                                    childAspectRatio: 1,
                                  ),
                              itemCount:
                                  selectedImages.length + selectedVideos.length,
                              itemBuilder: (context, index) {
                                if (index < selectedImages.length) {
                                  // Display image
                                  return Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            getProportionateScreenWidth(10),
                                          ),
                                          image: DecorationImage(
                                            image: FileImage(
                                              selectedImages[index],
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 5,
                                        right: 5,
                                        child: InkWell(
                                          onTap: () => _removeImage(index),
                                          child: Container(
                                            padding: EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  // Display video
                                  final videoIndex =
                                      index - selectedImages.length;
                                  return _buildVideoPreview(
                                    selectedVideos[videoIndex],
                                    videoIndex,
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

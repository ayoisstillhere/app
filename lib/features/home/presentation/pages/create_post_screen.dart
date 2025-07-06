import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

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

  @override
  void initState() {
    super.initState();
    _postController.addListener(() {
      setState(() {});
    });
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

  void _removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
  }

  Future<void> _createPost() async {
    if (_postController.text.isEmpty && selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Please add some content or images',
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

  @override
  void dispose() {
    _postController.removeListener(() {});
    _postController.dispose();
    super.dispose();
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
                                  image: NetworkImage(widget.profileImage),
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
                              onTap: _pickImageFromGallery,
                              child: SvgPicture.asset(
                                "assets/icons/post_image.svg",
                                height: getProportionateScreenHeight(18),
                                width: getProportionateScreenWidth(18),
                              ),
                            ),
                            SizedBox(width: getProportionateScreenWidth(26)),
                            InkWell(
                              onTap: _pickImageFromCamera,
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
                                          selectedImages.isNotEmpty)
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
                // Display selected images
                if (selectedImages.isNotEmpty)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(getProportionateScreenWidth(14)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Selected Images (${selectedImages.length})",
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
                              itemCount: selectedImages.length,
                              itemBuilder: (context, index) {
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

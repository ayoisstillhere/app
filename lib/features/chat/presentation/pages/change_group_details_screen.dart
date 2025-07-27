import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../../../../components/default_button.dart';
import '../../../../components/nav_page.dart';
import '../../../../constants.dart';
import '../../../../services/auth_manager.dart';
import '../../../../size_config.dart';

class ChangeGroupDetailsScreen extends StatefulWidget {
  const ChangeGroupDetailsScreen({
    super.key,
    required this.currentName,
    required this.chatId,
    this.currentImageUrl,
  });
  final String currentName;
  final String chatId;
  final String? currentImageUrl;

  @override
  State<ChangeGroupDetailsScreen> createState() =>
      _ChangeGroupDetailsScreenState();
}

class _ChangeGroupDetailsScreenState extends State<ChangeGroupDetailsScreen> {
  late TextEditingController _controller;
  bool _isLoading = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Future<File> compressImage(File file) async {
  //   final compressedBytes = await FlutterImageCompress.compressWithFile(
  //     file.absolute.path,
  //     quality: 85, // adjust as needed
  //   );

  //   final compressedFile = File('${file.path}_compressed.jpg')
  //     ..writeAsBytesSync(compressedBytes!);
  //   return compressedFile;
  // }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final File imageFile = File(image.path);
        // final File compressedImage = await compressImage(imageFile);
        setState(() {
          _selectedImage = imageFile;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Failed to pick image: $e',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  Future<void> _saveChanges() async {
    final nameChanged = _controller.text.trim() != widget.currentName;
    final imageChanged = _selectedImage != null;

    if (!nameChanged && !imageChanged) {
      // No changes made
      Navigator.pop(context);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final token = await AuthManager.getToken();

      // Create multipart request
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/api/v1/chat/conversations/${widget.chatId}'),
      );

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';

      // Add name field
      request.fields['name'] = _controller.text.trim();

      // Add image if selected
      if (_selectedImage != null) {
        final multipartFile = await http.MultipartFile.fromPath(
          'groupImage',
          _selectedImage!.path,
        );
        request.files.add(multipartFile);
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Handle response
      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return NavPage();
            },
          ),
        );
      } else {
        // Return error result
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Failed to update Group Details, Please Contact Admin',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating Group Details: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildProfilePictureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Profile Picture"),
        SizedBox(height: getProportionateScreenHeight(12)),
        Center(
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: getProportionateScreenWidth(100),
              height: getProportionateScreenWidth(100),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: kGreySearchInput, width: 2),
                color: Colors.grey[200],
              ),
              child: _selectedImage != null
                  ? ClipOval(
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                        width: getProportionateScreenWidth(100),
                        height: getProportionateScreenWidth(100),
                      ),
                    )
                  : widget.currentImageUrl != null
                  ? ClipOval(
                      child: Image.network(
                        widget.currentImageUrl!,
                        fit: BoxFit.cover,
                        width: getProportionateScreenWidth(100),
                        height: getProportionateScreenWidth(100),
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderAvatar();
                        },
                      ),
                    )
                  : _buildPlaceholderAvatar(),
            ),
          ),
        ),
        SizedBox(height: getProportionateScreenHeight(8)),
        Center(
          child: Text(
            "Tap to change picture",
            style: TextStyle(
              fontSize: getProportionateScreenHeight(12),
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderAvatar() {
    return Icon(
      Icons.group,
      size: getProportionateScreenWidth(50),
      color: Colors.grey[400],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            appBar: _buildAppBar(),
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: getProportionateScreenWidth(25),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: getProportionateScreenHeight(23)),
                    Text(
                      "Change Group Details",
                      style: TextStyle(
                        fontSize: getProportionateScreenHeight(20),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: getProportionateScreenHeight(32)),
                    _buildProfilePictureSection(),
                    SizedBox(height: getProportionateScreenHeight(24)),
                    Text("Name"),
                    SizedBox(height: getProportionateScreenHeight(6)),
                    TextField(
                      controller: _controller,
                      maxLines: 1,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: kGreySearchInput),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: kGreySearchInput),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: kGreySearchInput),
                        ),
                        fillColor: Colors.transparent,
                      ),
                    ),
                    Spacer(),
                    DefaultButton(text: "Save Changes", press: _saveChanges),
                    SizedBox(height: getProportionateScreenHeight(44)),
                  ],
                ),
              ),
            ),
          );
  }

  PreferredSizeWidget _buildAppBar() {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final iconColor = isDarkMode ? kWhite : kBlack;
    final dividerColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kGreyInputFillDark
        : kGreyInputBorder;
    return AppBar(
      title: Text(
        "Group Details",
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
              "assets/icons/edit.svg",
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              width: getProportionateScreenWidth(24),
              height: getProportionateScreenHeight(24),
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(getProportionateScreenHeight(20)),
        child: Container(
          width: double.infinity,
          height: 1,
          color: dividerColor,
        ),
      ),
    );
  }
}

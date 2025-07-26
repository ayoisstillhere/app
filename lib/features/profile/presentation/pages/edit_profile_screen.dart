import 'package:app/components/nav_page.dart';
import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import '../../../../constants.dart';
import '../../../../services/auth_manager.dart';
import '../../../../size_config.dart';
import 'edit_field_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool userDataLoaded = false;
  late final UserEntity currentUser;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  Future<void> getCurrentUser() async {
    UserEntity? user = await AuthManager.getCurrentUser();
    if (mounted) {
      setState(() {
        currentUser = user!;
        userDataLoaded = true;
      });
    }
  }

  Future<void> uploadImage(File file, String endpoint) async {
    final token = await AuthManager.getToken();
    final uri = Uri.parse('$baseUrl$endpoint');
    // Determine the MIME type (e.g., image/png)
    final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
    final mimeSplit = mimeType.split('/');
    var request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(
        http.MultipartFile(
          'file',
          file.readAsBytes().asStream(),
          file.lengthSync(),
          filename: file.path.split('/').last,
          contentType: MediaType(mimeSplit[0], mimeSplit[1]),
        ),
      );
    final response = await request.send();
    if (response.statusCode != 200) {
      final responseBody = await response.stream.bytesToString();
      throw Exception(
        'Failed to upload image: ${response.statusCode} - $responseBody',
      );
    }
  }

  void _showImagePickerMenu(bool isBanner, TapDownDetails details) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        details.globalPosition & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: [
        const PopupMenuItem<String>(
          value: 'camera',
          child: Row(
            children: [
              Icon(Icons.camera_alt),
              SizedBox(width: 8),
              Text('Take Photo'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'gallery',
          child: Row(
            children: [
              Icon(Icons.photo_library),
              SizedBox(width: 8),
              Text('Choose Existing Photo'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value != null) {
        if (value == 'camera') {
          _pickImage(ImageSource.camera, isBanner);
        } else if (value == 'gallery') {
          _pickImage(ImageSource.gallery, isBanner);
        }
      }
    });
  }

  Future<File?> _cropImage(File imageFile, bool isBanner) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio: isBanner
            ? const CropAspectRatio(ratioX: 3, ratioY: 1) // Banner aspect ratio
            : const CropAspectRatio(ratioX: 1, ratioY: 1), // Square for profile
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: isBanner ? 'Crop Banner Image' : 'Crop Profile Image',
            toolbarColor: kAccentColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: isBanner
                ? CropAspectRatioPreset.ratio3x2
                : CropAspectRatioPreset.square,
            lockAspectRatio: true,
            aspectRatioPresets: [
              if (isBanner) ...[
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio16x9,
              ] else ...[
                CropAspectRatioPreset.square,
              ],
            ],
            hideBottomControls: false,
            cropGridRowCount: 3,
            cropGridColumnCount: 3,
            cropGridStrokeWidth: 2,
            cropGridColor: kAccentColor,
            activeControlsWidgetColor: kAccentColor,
          ),
          IOSUiSettings(
            title: isBanner ? 'Crop Banner Image' : 'Crop Profile Image',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            aspectRatioPickerButtonHidden: true,
            rotateButtonsHidden: false,
            resetButtonHidden: false,
            aspectRatioPresets: [
              if (isBanner) ...[
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio16x9,
              ] else ...[
                CropAspectRatioPreset.square,
              ],
            ],
          ),
          WebUiSettings(context: context),
        ],
      );

      if (croppedFile != null) {
        return File(croppedFile.path);
      }
      return null;
    } catch (e) {
      print('Error cropping image: $e');
      return null;
    }
  }

  Future<void> _pickImage(ImageSource source, bool isBanner) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: isBanner ? 1200 : 800,
        maxHeight: isBanner ? 400 : 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);

        // Show cropping interface
        File? croppedFile = await _cropImage(imageFile, isBanner);

        if (croppedFile != null) {
          String endpoint = isBanner
              ? '/api/v1/user/upload-banner-image'
              : '/api/v1/user/upload-profile-image';

          // Show loading indicator
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const Center(child: CircularProgressIndicator());
            },
          );

          await uploadImage(croppedFile, endpoint);

          // Hide loading indicator
          if (mounted) {
            Navigator.of(context).pop();
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isBanner
                    ? 'Banner updated successfully'
                    : 'Profile image updated successfully',
              ),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => NavPage(page: 3)),
          );
        }
        // If user cancelled cropping, do nothing
      }
    } catch (e) {
      // Hide loading indicator if it's showing
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildProfileHeader() {
    return SizedBox(
      height: getProportionateScreenHeight(200),
      child: Stack(
        children: [
          // Banner Image
          SizedBox(
            height: getProportionateScreenHeight(150),
            width: double.infinity,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: kGreySearchInput,
                    image: currentUser.bannerImage!.isEmpty
                        ? DecorationImage(
                            image: NetworkImage(currentUser.bannerImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: currentUser.bannerImage!.isEmpty
                      ? Center(
                          child: Icon(
                            Icons.image,
                            size: getProportionateScreenHeight(50),
                            color: Colors.grey[600],
                          ),
                        )
                      : null,
                ),
                // Banner overlay and edit icon
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                    child: Center(
                      child: GestureDetector(
                        onTapDown: (details) =>
                            _showImagePickerMenu(true, details),
                        child: Container(
                          padding: EdgeInsets.all(
                            getProportionateScreenWidth(12),
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: SvgPicture.asset(
                            "assets/icons/edit.svg",
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                            width: getProportionateScreenWidth(16),
                            height: getProportionateScreenHeight(16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Profile Image
          Positioned(
            bottom: 0,
            left: getProportionateScreenWidth(25),
            child: SizedBox(
              width: getProportionateScreenWidth(100),
              height: getProportionateScreenWidth(100),
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        width: 4,
                      ),
                      color: kGreySearchInput,
                      image: currentUser.profileImage!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(currentUser.profileImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: currentUser.profileImage!.isEmpty
                        ? Center(
                            child: Icon(
                              Icons.person,
                              size: getProportionateScreenHeight(40),
                              color: Colors.grey[600],
                            ),
                          )
                        : null,
                  ),
                  // Profile image overlay and edit icon
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.3),
                      ),
                      child: Center(
                        child: GestureDetector(
                          onTapDown: (details) =>
                              _showImagePickerMenu(false, details),
                          child: Container(
                            padding: EdgeInsets.all(
                              getProportionateScreenWidth(8),
                            ),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: SvgPicture.asset(
                              "assets/icons/edit.svg",
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                              width: getProportionateScreenWidth(16),
                              height: getProportionateScreenHeight(16),
                            ),
                          ),
                        ),
                      ),
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

  // Navigation methods for each field
  void _navigateToEditName() async {
    final result = await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EditFieldScreen(
          title: "Name",
          currentValue: currentUser.fullName,
          fieldType: FieldType.name,
        ),
      ),
    );
    if (result != null) {
      await getCurrentUser();
    }
  }

  void _navigateToEditUserName() async {
    final result = await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EditFieldScreen(
          title: "Username",
          currentValue: currentUser.username,
          fieldType: FieldType.username,
        ),
      ),
    );
    if (result != null) {
      await getCurrentUser();
    }
  }

  void _navigateToEditEmail() async {
    final result = await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EditFieldScreen(
          title: "Email",
          currentValue: currentUser.email,
          fieldType: FieldType.email,
        ),
      ),
    );
    if (result != null) {
      await getCurrentUser();
    }
  }

  void _navigateToEditBio() async {
    final result = await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EditFieldScreen(
          title: "Bio",
          currentValue: currentUser.bio,
          fieldType: FieldType.bio,
        ),
      ),
    );
    if (result != null) {
      await getCurrentUser();
    }
  }

  void _navigateToEditLocation() async {
    final result = await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EditFieldScreen(
          title: "Location",
          currentValue: currentUser.location,
          fieldType: FieldType.location,
        ),
      ),
    );
    if (result != null) {
      await getCurrentUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    return userDataLoaded
        ? Scaffold(
            appBar: _buildAppBar(),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile header with banner and profile image
                    _buildProfileHeader(),
                    SizedBox(height: getProportionateScreenHeight(23)),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: getProportionateScreenWidth(25),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldContainer(
                            label: "Name",
                            value: currentUser.fullName,
                            onChangeTap: _navigateToEditName,
                          ),
                          SizedBox(height: getProportionateScreenHeight(15)),
                          _buildFieldContainer(
                            label: "Username",
                            value: currentUser.username,
                            onChangeTap: _navigateToEditUserName,
                          ),
                          SizedBox(height: getProportionateScreenHeight(15)),
                          _buildFieldContainer(
                            label: "Bio",
                            value: currentUser.bio,
                            onChangeTap: _navigateToEditBio,
                          ),
                          SizedBox(height: getProportionateScreenHeight(15)),
                          _buildFieldContainer(
                            label: "Location",
                            value: currentUser.location,
                            onChangeTap: _navigateToEditLocation,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : const Center(child: CircularProgressIndicator());
  }

  Widget _buildFieldContainer({
    required String label,
    required String value,
    required VoidCallback onChangeTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: getProportionateScreenHeight(14),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: getProportionateScreenHeight(6)),
        Container(
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: kGreySearchInput),
            borderRadius: BorderRadius.circular(8),
          ),
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: getProportionateScreenWidth(10),
            vertical: getProportionateScreenHeight(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: getProportionateScreenHeight(14),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              InkWell(
                onTap: onChangeTap,
                child: Text(
                  "edit",
                  style: TextStyle(
                    color: kAccentColor,
                    fontSize: getProportionateScreenHeight(12),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
        "Profile",
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

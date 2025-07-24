import 'dart:io';

import 'package:app/components/default_button.dart';
import 'package:app/components/nav_page.dart';
import 'package:app/services/auth_manager.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../../constants.dart';
import '../../../../services/secret_chat_encryption_service.dart';
import '../../../../size_config.dart';
import '../widgets/form_header.dart';
import 'package:http_parser/http_parser.dart'; // Required for MediaType
import 'package:mime/mime.dart'; // Optional: For detecting MIME type dynamically

class ProfileImageSelectScreen extends StatefulWidget {
  const ProfileImageSelectScreen({super.key});

  @override
  State<ProfileImageSelectScreen> createState() =>
      _ProfileImageSelectScreenState();
}

class _ProfileImageSelectScreenState extends State<ProfileImageSelectScreen> {
  File? _selectedProfileImage;
  File? _selectedBannerImage;
  bool isLoading = false; // Add loading state

  Future<void> _uploadImagesAndContinue() async {
    setState(() {
      isLoading = true; // Set loading to true
    });

    try {
      if (_selectedProfileImage != null) {
        // final compressedFile = await compressImage(_selectedProfileImage!);

        await uploadImage(_selectedProfileImage!, '/api/v1/user/upload-profile-image');
      }

      if (_selectedBannerImage != null) {
        // final compressedFile = await compressImage(_selectedBannerImage!);
        await uploadImage(_selectedBannerImage!, '/api/v1/user/upload-banner-image');
      }
      final encryptionService = SecretChatEncryptionService();
      await encryptionService.ensureKeyPairExists();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => NavPage()),
        (route) => false, // This removes all previous routes
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Failed to upload image(s). Please try again',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    } finally {
      setState(() {
        isLoading = false; // Set loading to false
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: MediaQuery.of(context).platformBrightness == Brightness.dark
            ? BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.0, 0.4],
                  colors: [
                    Color(0xFF27744A),
                    Color(0xFF214F36),
                    Color(0xFF0A0A0A),
                  ],
                ),
              )
            : BoxDecoration(),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsetsGeometry.symmetric(
                horizontal: getProportionateScreenWidth(25),
              ),
              child: Column(
                children: <Widget>[
                  SizedBox(height: getProportionateScreenHeight(56.4)),
                  FormHeader(
                    isSignUp: false,
                    title: 'Profile',
                    subtitle: 'Edit your profile details',
                  ),
                  SizedBox(height: getProportionateScreenHeight(58.5)),
                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(
                      horizontal: getProportionateScreenWidth(74),
                    ),
                    child: Row(
                      children: [
                        Column(
                          children: [
                            InkWell(
                              onTap: isLoading
                                  ? null
                                  : () {
                                      _pickProfileImageFromGallery();
                                    }, // Disable when loading
                              child: Container(
                                width: getProportionateScreenWidth(84),
                                height: getProportionateScreenHeight(84),
                                padding: EdgeInsets.symmetric(
                                  horizontal: getProportionateScreenWidth(24),
                                  vertical: getProportionateScreenHeight(24),
                                ),
                                decoration: _selectedProfileImage == null
                                    ? BoxDecoration(
                                        border: Border.all(
                                          color: kGreyInputBorder,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(
                                            getProportionateScreenWidth(10),
                                          ),
                                        ),
                                      )
                                    : BoxDecoration(
                                        border: Border.all(
                                          color: kGreyInputBorder,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(
                                            getProportionateScreenWidth(10),
                                          ),
                                        ),
                                        image: DecorationImage(
                                          image: FileImage(
                                            _selectedProfileImage!,
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                child: _selectedProfileImage == null
                                    ? SvgPicture.asset(
                                        'assets/icons/picture_icon.svg',
                                      )
                                    : null,
                              ),
                            ),
                            SizedBox(height: getProportionateScreenHeight(11)),
                            Text(
                              'Profile image',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        Spacer(),
                        Column(
                          children: [
                            InkWell(
                              onTap: isLoading
                                  ? null
                                  : () {
                                      _pickBannerImageFromGallery();
                                    }, // Disable when loading
                              child: Container(
                                width: getProportionateScreenWidth(84),
                                height: getProportionateScreenHeight(84),
                                padding: EdgeInsets.symmetric(
                                  horizontal: getProportionateScreenWidth(24),
                                  vertical: getProportionateScreenHeight(24),
                                ),
                                decoration: _selectedBannerImage == null
                                    ? BoxDecoration(
                                        border: Border.all(
                                          color: kGreyInputBorder,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(
                                            getProportionateScreenWidth(10),
                                          ),
                                        ),
                                      )
                                    : BoxDecoration(
                                        border: Border.all(
                                          color: kGreyInputBorder,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(
                                            getProportionateScreenWidth(10),
                                          ),
                                        ),
                                        image: DecorationImage(
                                          image: FileImage(
                                            _selectedBannerImage!,
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                child: _selectedBannerImage == null
                                    ? SvgPicture.asset(
                                        'assets/icons/picture_icon.svg',
                                      )
                                    : null,
                              ),
                            ),
                            SizedBox(height: getProportionateScreenHeight(11)),
                            Text(
                              'Banner',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: getProportionateScreenHeight(43.5)),
                  isLoading
                      ? Center(
                          child: SizedBox(
                            height: getProportionateScreenHeight(45),
                            width: getProportionateScreenWidth(45),
                            child: const CircularProgressIndicator(),
                          ),
                        )
                      : DefaultButton(
                          text: 'Continue',
                          press: _uploadImagesAndContinue,
                        ),
                  SizedBox(height: getProportionateScreenHeight(16)),
                  isLoading
                      ? SizedBox(
                          height: getProportionateScreenHeight(45),
                        ) // Maintain spacing
                      : SkipButon(
                          text: 'Skip',
                          press: () async {
                            setState(() {
                              isLoading = true; // Set loading to true
                            });
                            final encryptionService =
                                SecretChatEncryptionService();
                            await encryptionService.ensureKeyPairExists();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NavPage(),
                              ),
                              (route) =>
                                  false, // This removes all previous routes
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future _pickProfileImageFromGallery() async {
    final returnedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (returnedImage == null) {
      return;
    }
    setState(() {
      _selectedProfileImage = File(returnedImage.path);
    });
  }

  Future _pickBannerImageFromGallery() async {
    final returnedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (returnedImage == null) {
      return;
    }
    setState(() {
      _selectedBannerImage = File(returnedImage.path);
    });
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

class SkipButon extends StatelessWidget {
  const SkipButon({super.key, required this.text, required this.press});
  final String text;
  final void Function() press;

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kDarkPurple
        : kLightPurple;
    // final textColor =
    //     MediaQuery.of(context).platformBrightness == Brightness.dark
    //     ? kWhite
    //     : kBlack;
    return GestureDetector(
      onTap: press,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: primaryColor, width: 1.0),
          borderRadius: BorderRadius.circular(getProportionateScreenWidth(8)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: getProportionateScreenWidth(18),
            vertical: getProportionateScreenHeight(10),
          ),
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;

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
  bool isLoading = false;

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
                                  hintText: "what’s on your mind?",
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
                            SvgPicture.asset(
                              "assets/icons/post_image.svg",
                              height: getProportionateScreenHeight(18),
                              width: getProportionateScreenWidth(18),
                            ),
                            SizedBox(width: getProportionateScreenWidth(26)),
                            SvgPicture.asset(
                              "assets/icons/post_camera.svg",
                              height: getProportionateScreenHeight(18),
                              width: getProportionateScreenWidth(18),
                            ),
                            SizedBox(width: getProportionateScreenWidth(26)),
                            SvgPicture.asset(
                              "assets/icons/post_link.svg",
                              height: getProportionateScreenHeight(18),
                              width: getProportionateScreenWidth(18),
                            ),
                            Spacer(),
                            InkWell(
                              onTap: () async {
                                setState(() {
                                  isLoading = true;
                                });
                                if (_postController.text.isNotEmpty) {
                                  final token = await AuthManager.getToken();
                                  final request = http.MultipartRequest(
                                    "POST",
                                    Uri.parse("$baseUrl/api/v1/posts"),
                                  );
                                  request.headers["Authorization"] =
                                      "Bearer $token";
                                  request.fields["content"] = _postController
                                      .text
                                      .trim();
                                  request.files.add(
                                    http.MultipartFile.fromBytes(
                                      "links",
                                      [],
                                      filename: "",
                                    ),
                                  );
                                  request.files.add(
                                    http.MultipartFile.fromBytes(
                                      "media",
                                      [],
                                      filename: "",
                                    ),
                                  );
                                  final response = await request.send();
                                  if (response.statusCode == 201) {
                                    Navigator.pop(context);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Colors.red,
                                        content: Text(
                                          jsonDecode(
                                            response.reasonPhrase!,
                                          )['message'].toString().replaceAll(
                                            RegExp(r'\[|\]'),
                                            '',
                                          ),
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    );
                                  }
                                  if (mounted) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                }
                              },
                              child: Container(
                                height: getProportionateScreenHeight(30),
                                width: getProportionateScreenWidth(50),
                                decoration: BoxDecoration(
                                  color: _postController.text.isNotEmpty
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
              ],
            ),
    );
  }
}

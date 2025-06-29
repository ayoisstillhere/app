import 'package:app/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../constants.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _postController = TextEditingController();

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
      body: Column(
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
                            image: NetworkImage(
                              "https://images.unsplash.com/photo-1508002366005-75a695ee2d17?q=80&w=736&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                            ),
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
                        onTap: () {},
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

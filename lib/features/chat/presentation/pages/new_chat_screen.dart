import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../constants.dart';
import '../../../../size_config.dart';
import '../widgets/chat_suggestion_tile.dart';
import 'group_chat_screen.dart';

class NewChatScreen extends StatelessWidget {
  const NewChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final iconColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kWhite
        : kBlack;
    final circleColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kGreyInputFillDark
        : Colors.transparent;
    final circleBorder =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kGreySearchInput
        : kGreyInputBorder;
    final dividerColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kGreyInputFillDark
        : kGreyInputBorder;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Messages",
          style: TextStyle(
            fontSize: getProportionateScreenHeight(24),
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: getProportionateScreenWidth(22)),
            child: SizedBox(
              height: getProportionateScreenHeight(24),
              width: getProportionateScreenWidth(24),
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
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: getProportionateScreenHeight(30)),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(16),
              ),
              child: TextFormField(
                decoration: _buildChatSearchFieldDecoration(context),
              ),
            ),
            SizedBox(height: getProportionateScreenHeight(36)),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GroupChatScreen(),
                  ),
                );
              },
              child: Padding(
                padding: EdgeInsetsGeometry.symmetric(
                  horizontal: getProportionateScreenWidth(30),
                ),
                child: Row(
                  children: [
                    Container(
                      height: getProportionateScreenHeight(64),
                      width: getProportionateScreenWidth(64),
                      padding: EdgeInsets.symmetric(
                        horizontal: getProportionateScreenWidth(20),
                        vertical: getProportionateScreenHeight(20),
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: circleColor,
                        border: Border.all(color: circleBorder, width: 1.0),
                      ),
                      child: SvgPicture.asset(
                        "assets/icons/users-round.svg",
                        colorFilter: ColorFilter.mode(
                          iconColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    SizedBox(width: getProportionateScreenWidth(14)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Group Chat",
                          style: TextStyle(
                            fontSize: getProportionateScreenHeight(15),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "Add multiple people",
                          style: TextStyle(
                            fontSize: getProportionateScreenHeight(12),
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: getProportionateScreenHeight(47)),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(18),
              ),
              child: Text(
                "Suggested",
                style: TextStyle(
                  fontSize: getProportionateScreenHeight(12),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: getProportionateScreenHeight(27)),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: mockListTile.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsetsGeometry.symmetric(
                    horizontal: getProportionateScreenWidth(18),
                  ),
                  child: ChatSuggestionTile(
                    dividerColor: dividerColor,
                    image: mockListTile[index]["image"],
                    name: mockListTile[index]["name"],
                    handle: mockListTile[index]["handle"],
                    isSelected: false,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildChatSearchFieldDecoration(BuildContext context) {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(getProportionateScreenWidth(30)),
        borderSide: BorderSide(
          color: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? kGreySearchInput
              : kGreyInputBorder,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(getProportionateScreenWidth(30)),
        borderSide: BorderSide(
          color: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? kGreySearchInput
              : kGreyInputBorder,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(getProportionateScreenWidth(30)),
        borderSide: BorderSide(
          color: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? kGreySearchInput
              : kGreyInputBorder,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(getProportionateScreenWidth(30)),
        borderSide: BorderSide(
          color: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? kGreySearchInput
              : kGreyInputBorder,
        ),
      ),
      fillColor: MediaQuery.of(context).platformBrightness == Brightness.dark
          ? kGreySearchInput
          : null,
      filled: MediaQuery.of(context).platformBrightness == Brightness.dark,
      prefixIcon: Padding(
        padding: EdgeInsets.all(getProportionateScreenHeight(14)),
        child: Text(
          "To:",
          style: TextStyle(
            fontSize: getProportionateScreenHeight(12),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      hintText: "Search ",
      hintStyle: TextStyle(
        fontSize: getProportionateScreenHeight(13),
        fontWeight: FontWeight.w500,
        color: kGreyDarkInputBorder,
      ),
    );
  }
}

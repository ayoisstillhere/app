import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../constants.dart';
import '../../../../size_config.dart';
import '../widgets/chat_suggestion_tile.dart';

class GroupChatScreen extends StatefulWidget {
  const GroupChatScreen({super.key});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController groupNameController = TextEditingController();
  final List<Map<String, dynamic>> selectedUsers = [];

  void toggleUserSelection(Map<String, dynamic> user) {
    setState(() {
      if (selectedUsers.contains(user)) {
        selectedUsers.remove(user);
      } else {
        selectedUsers.add(user);
      }
    });
  }

  void removeSelectedUser(Map<String, dynamic> user) {
    setState(() {
      selectedUsers.remove(user);
    });
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "New Group",
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
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Group Name Section
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: getProportionateScreenWidth(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: getProportionateScreenHeight(30)),
                    Text(
                      "Group name",
                      style: TextStyle(
                        fontSize: getProportionateScreenHeight(14),
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    SizedBox(height: getProportionateScreenHeight(16)),
                    TextFormField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.transparent,
                        hintText: "Enter group name",
                      ),
                      controller: groupNameController,
                    ),
                    SizedBox(height: getProportionateScreenHeight(16)),
                  ],
                ),
              ),

              // Search Field
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: getProportionateScreenWidth(16),
                ),
                child: TextFormField(
                  decoration: _buildChatSearchFieldDecoration(context),
                ),
              ),

              SizedBox(height: getProportionateScreenHeight(16)),

              // Selected Users Horizontal List
              if (selectedUsers.isNotEmpty)
                Container(
                  height: getProportionateScreenHeight(80),
                  padding: EdgeInsets.symmetric(
                    horizontal: getProportionateScreenWidth(16),
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: selectedUsers.length,
                    itemBuilder: (context, index) {
                      final user = selectedUsers[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          right: getProportionateScreenWidth(22),
                        ),
                        child: _buildSelectedUserChip(user),
                      );
                    },
                  ),
                ),

              SizedBox(height: getProportionateScreenHeight(16)),

              // Suggested Section
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

              SizedBox(height: getProportionateScreenHeight(16)),

              // Suggested Users List
              Expanded(
                child: ListView.builder(
                  itemCount: mockListTile.length,
                  itemBuilder: (context, index) {
                    final user = mockListTile[index];
                    bool isSelected = selectedUsers.contains(user);
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: getProportionateScreenWidth(18),
                      ),
                      child: GestureDetector(
                        onTap: () => toggleUserSelection(user),
                        child: ChatSuggestionTile(
                          dividerColor: dividerColor,
                          image: user["image"],
                          name: user["name"],
                          handle: user["handle"],
                          isSelected: isSelected,
                          showCheckbox: true,
                          onSelectionChanged: (selected) {
                            if (selected) {
                              toggleUserSelection(user);
                            } else {
                              removeSelectedUser(user);
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // Create Group Button
          if (selectedUsers.isNotEmpty)
            Positioned(
              bottom: getProportionateScreenHeight(33),
              left: getProportionateScreenWidth(33),
              right: getProportionateScreenWidth(33),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: kLightPurple,
                  padding: EdgeInsets.symmetric(
                    vertical: getProportionateScreenHeight(16),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      getProportionateScreenWidth(12),
                    ),
                  ),
                ),
                child: Text(
                  "Create Group Chat",
                  style: TextStyle(
                    color: kBlack,
                    fontSize: getProportionateScreenHeight(16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedUserChip(Map<String, dynamic> user) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: getProportionateScreenHeight(62),
              width: getProportionateScreenWidth(62),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(user["image"]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: -4,
              right: -4,
              child: GestureDetector(
                onTap: () => removeSelectedUser(user),
                child: SvgPicture.asset(
                  "assets/icons/remove.svg",
                  height: getProportionateScreenHeight(23),
                  width: getProportionateScreenWidth(23),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          width: getProportionateScreenWidth(62),
          child: Text(
            user["name"],
            style: TextStyle(
              fontSize: getProportionateScreenHeight(12),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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

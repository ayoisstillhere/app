import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  Future<void> getCurrentUser() async {
    UserEntity? user = await AuthManager.getCurrentUser();
    if (mounted) {
      setState(() {
        currentUser = user!; // This line causes the error if called twice
        userDataLoaded = true;
      });
    }
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
      // Refresh user data after edit
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
      // Refresh user data after edit
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
      // Refresh user data after edit
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
      // Refresh user data after edit
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
      // Refresh user data after edit
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
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: getProportionateScreenWidth(25),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: getProportionateScreenHeight(23)),
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
                      // _buildFieldContainer(
                      //   label: "Email",
                      //   value: currentUser.email,
                      //   onChangeTap: _navigateToEditEmail,
                      // ),
                      // SizedBox(height: getProportionateScreenHeight(15)),
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
              ),
            ),
          )
        : const Center(child: CircularProgressIndicator());
  }

  // Refactored method to build field containers
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
                  "change",
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

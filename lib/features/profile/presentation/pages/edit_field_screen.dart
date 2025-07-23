// Generic edit field screen
import 'dart:convert';

import 'package:app/components/default_button.dart';
import 'package:app/components/nav_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;

import '../../../../constants.dart';
import '../../../../services/auth_manager.dart';
import '../../../../size_config.dart';

class EditFieldScreen extends StatefulWidget {
  final String title;
  final String currentValue;
  final FieldType fieldType;

  const EditFieldScreen({
    super.key,
    required this.title,
    required this.currentValue,
    required this.fieldType,
  });

  @override
  State<EditFieldScreen> createState() => _EditFieldScreenState();
}

class _EditFieldScreenState extends State<EditFieldScreen> {
  late TextEditingController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_controller.text.trim() == widget.currentValue) {
      // No changes made
      Navigator.pop(context);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Here you would call your API to update the user data
      // Example:
      // await AuthManager.updateUserField(widget.fieldType, _controller.text.trim());
      final updatedValue = _controller.text.trim();
      final token = await AuthManager.getToken();

      String key = "";
      if (widget.fieldType == FieldType.name) {
        key = "fullName";
      } else if (widget.fieldType == FieldType.email) {
        key = "email";
      } else if (widget.fieldType == FieldType.bio) {
        key = "bio";
      } else if (widget.fieldType == FieldType.username) {
        key = "username";
      } else if (widget.fieldType == FieldType.location) {
        key = "location";
      }

      final response = await http.put(
        Uri.parse('$baseUrl/api/v1/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({key: updatedValue}),
      );

      // Return success result
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
              'Failed to update ${widget.fieldType.name}',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating ${widget.fieldType.name}: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
                      "Enter a new profile ${widget.fieldType.name}",
                      style: TextStyle(
                        fontSize: getProportionateScreenHeight(20),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: getProportionateScreenHeight(32)),
                    TextField(
                      controller: _controller,
                      maxLines: widget.fieldType == FieldType.bio ? 3 : 1,
                      keyboardType: widget.fieldType == FieldType.email
                          ? TextInputType.emailAddress
                          : TextInputType.text,
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
                    DefaultButton(
                      text: "Change ${widget.title}",
                      press: _saveChanges,
                    ),
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
        "Profile ${widget.title}",
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

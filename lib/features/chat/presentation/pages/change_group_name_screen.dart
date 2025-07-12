import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;

import '../../../../components/default_button.dart';
import '../../../../components/nav_page.dart';
import '../../../../constants.dart';
import '../../../../services/auth_manager.dart';
import '../../../../size_config.dart';

class ChangeGroupNameScreen extends StatefulWidget {
  const ChangeGroupNameScreen({
    super.key,
    required this.currentName,
    required this.chatId,
  });
  final String currentName;
  final String chatId;

  @override
  State<ChangeGroupNameScreen> createState() => _ChangeGroupNameScreenState();
}

class _ChangeGroupNameScreenState extends State<ChangeGroupNameScreen> {
  late TextEditingController _controller;
  bool _isLoading = false;

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

  Future<void> _saveChanges() async {
    if (_controller.text.trim() == widget.currentName) {
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

      final response = await http.put(
        Uri.parse('$baseUrl/api/v1/chat/conversations/${widget.chatId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"name": updatedValue}),
      );

      // Return success result
      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const NavPage();
            },
          ),
        );
      } else {
        // Return error result
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Failed to update Group Name',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating Group Name: $e')));
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
                      "Change Group Name",
                      style: TextStyle(
                        fontSize: getProportionateScreenHeight(20),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: getProportionateScreenHeight(32)),
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
                    DefaultButton(text: "Change Name", press: _saveChanges),
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
    return AppBar(
      title: Text(
        "Group Name",
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
    );
  }
}

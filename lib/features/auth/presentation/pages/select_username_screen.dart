import 'dart:convert';

import 'package:app/features/auth/presentation/pages/profile_image_select_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../components/default_button.dart';
import '../../../../constants.dart';
import '../../../../services/auth_manager.dart';
import '../../../../size_config.dart';
import '../widgets/form_header.dart';

class SelectUsernameScreen extends StatefulWidget {
  const SelectUsernameScreen({super.key});

  @override
  State<SelectUsernameScreen> createState() => _SelectUsernameScreenState();
}

class _SelectUsernameScreenState extends State<SelectUsernameScreen> {
  final usernameFormKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    usernameController = TextEditingController();
    nameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    usernameController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labelColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kWhite
        : kGreyFormLabel;
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
                  SizedBox(height: getProportionateScreenHeight(76.91)),
                  FormHeader(
                    isSignUp: false,
                    title: 'Select A Username',
                    subtitle: 'see what username is available',
                  ),
                  SizedBox(height: getProportionateScreenHeight(32)),
                  Form(
                    key: usernameFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Username",
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(
                                fontWeight: FontWeight.w500,
                                color: labelColor,
                              ),
                        ),
                        SizedBox(height: getProportionateScreenHeight(6)),
                        TextFormField(
                          controller: usernameController,
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            hintText: "Enter your username",
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your username';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: getProportionateScreenHeight(20)),
                        Text(
                          "Name",
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(
                                fontWeight: FontWeight.w500,
                                color: labelColor,
                              ),
                        ),
                        SizedBox(height: getProportionateScreenHeight(6)),
                        TextFormField(
                          controller: nameController,
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            hintText: "Enter your name",
                            hintStyle: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  color: kGreyFormHint,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: getProportionateScreenHeight(54)),
                        DefaultButton(
                          press: () async {
                            if (usernameFormKey.currentState!.validate()) {
                              usernameFormKey.currentState!.save();
                              final token = await AuthManager.getToken();
                              final response = await http.put(
                                Uri.parse('$baseUrl/api/v1/user/profile'),
                                headers: {
                                  'Content-Type': 'application/json',
                                  'Authorization': 'Bearer $token',
                                },
                                body: jsonEncode({
                                  'username': usernameController.text.trim(),
                                  'fullName': nameController.text.trim(),
                                }),
                              );

                              if (response.statusCode == 200) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ProfileImageSelectScreen(),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text(
                                      jsonDecode(response.body)['message']
                                          .toString()
                                          .replaceAll(RegExp(r'\[|\]'), ''),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          text: 'Continue',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

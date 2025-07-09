import 'dart:convert';

import 'package:app/features/auth/presentation/pages/reset_password_screen.dart';
import 'package:app/features/auth/presentation/pages/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../components/default_button.dart';
import '../../../../constants.dart';
import '../../../../size_config.dart';
import '../widgets/form_header.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _forgotPasswordFormKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
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
                  SizedBox(height: getProportionateScreenHeight(48)),
                  FormHeader(
                    isSignUp: true,
                    title: 'Forgot Password?',
                    subtitle: 'Enter your email',
                  ),
                  SizedBox(height: getProportionateScreenHeight(32)),
                  Form(
                    key: _forgotPasswordFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Email",
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(
                                fontWeight: FontWeight.w500,
                                color: labelColor,
                              ),
                        ),
                        SizedBox(height: getProportionateScreenHeight(6)),
                        TextFormField(
                          controller: emailController,
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            hintText: "Enter your Email",
                          ),
                          validator: validateEmail,
                        ),
                        SizedBox(height: getProportionateScreenHeight(16)),
                        DefaultButton(
                          press: () async {
                            if (_forgotPasswordFormKey.currentState!
                                .validate()) {
                              _forgotPasswordFormKey.currentState!.save();
                              final response = await http.post(
                                Uri.parse(
                                  '$baseUrl/api/v1/auth/forgot-password',
                                ),
                                headers: {'Content-Type': 'application/json'},
                                body: jsonEncode({
                                  'email': emailController.text.trim(),
                                }),
                              );
                              if (response.statusCode == 200) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Password reset link sent to your email.",
                                    ),
                                  ),
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ResetPasswordScreen(
                                      email: emailController.text.trim(),
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          text: 'Continue with email',
                        ),
                        SizedBox(height: getProportionateScreenHeight(32)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account?",
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .copyWith(fontWeight: FontWeight.w500),
                            ),
                            SizedBox(width: getProportionateScreenWidth(4)),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignInScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                "Log in",
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: kLightPurple,
                                    ),
                              ),
                            ),
                          ],
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

  // Email validator function
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    // Regular expression for email validation
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null; // Return null if validation passes
  }
}

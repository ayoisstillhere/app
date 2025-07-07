import 'dart:convert';

import 'package:app/constants.dart';
import 'package:app/features/auth/presentation/pages/sign_up_screen.dart';
import 'package:app/features/auth/presentation/widgets/google_button.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../components/default_button.dart';
import '../../../../components/nav_page.dart';
import '../../../../services/auth_manager.dart';
import '../../../../size_config.dart';
import '../widgets/custom_check_box.dart';
import '../widgets/form_header.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _signinFormKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                  SizedBox(height: getProportionateScreenHeight(48)),
                  FormHeader(
                    isSignUp: false,
                    title: 'Log in to your account',
                    subtitle: 'Welcome back! Please enter your details.',
                  ),
                  SizedBox(height: getProportionateScreenHeight(32)),
                  Form(
                    key: _signinFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Email or Username",
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(
                                fontWeight: FontWeight.w500,
                                color: labelColor,
                              ),
                        ),
                        SizedBox(height: getProportionateScreenHeight(6)),
                        TextFormField(
                          controller: _emailController,
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            hintText: "Enter your Email",
                          ),
                          validator: validateEmail,
                        ),
                        SizedBox(height: getProportionateScreenHeight(20)),
                        Text(
                          "Password",
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(
                                fontWeight: FontWeight.w500,
                                color: labelColor,
                              ),
                        ),
                        SizedBox(height: getProportionateScreenHeight(6)),
                        TextFormField(
                          obscureText: true,
                          controller: _passwordController,
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            hintText: "••••••••",
                            hintStyle: Theme.of(context).textTheme.bodyLarge!
                                .copyWith(color: kGreyFormHint),
                          ),
                          validator: validatePassword,
                        ),
                        SizedBox(height: getProportionateScreenHeight(24)),
                        Row(
                          children: [
                            CustomCheckbox(),
                            SizedBox(width: getProportionateScreenWidth(8)),
                            Text(
                              "Remember Me",
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            Spacer(),
                            Text(
                              "Forgot Password",
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: kLightPurple,
                                  ),
                            ),
                          ],
                        ),
                        SizedBox(height: getProportionateScreenHeight(24)),
                        // Inside the DefaultButton press callback in sign_in_screen.dart
                        DefaultButton(
                          press: () async {
                            if (_signinFormKey.currentState!.validate()) {
                              _signinFormKey.currentState!.save();
                              final response = await http.post(
                                Uri.parse('$baseUrl/api/v1/auth/login'),
                                headers: {'Content-Type': 'application/json'},
                                body: jsonEncode({
                                  'emailOrUsername': _emailController.text
                                      .trim(),
                                  'password': _passwordController.text.trim(),
                                }),
                              );
                              if (response.statusCode == 200) {
                                final responseData = jsonDecode(response.body);
                                final token = responseData['access_token'];
                                final refreshToken =
                                    responseData['refresh_token'];

                                // Use AuthManager instead of SharedPreferences
                                await AuthManager.setToken(token);
                                await AuthManager.setRefreshToken(refreshToken);

                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => const NavPage(),
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
                          text: 'Sign In',
                        ),
                        SizedBox(height: getProportionateScreenHeight(16)),
                        GoogleButton(press: () {}, isSignin: true),
                        SizedBox(height: getProportionateScreenHeight(32)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .copyWith(fontWeight: FontWeight.w500),
                            ),
                            SizedBox(width: getProportionateScreenWidth(4)),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignUpScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                "Sign Up",
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
    // final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    // if (!emailRegExp.hasMatch(value)) {
    //   return 'Please enter a valid email address';
    // }

    return null; // Return null if validation passes
  }

  // Password validator function
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    // // Check for at least one uppercase letter
    // if (!value.contains(RegExp(r'[A-Z]'))) {
    //   return 'Password must contain at least one uppercase letter';
    // }

    // // Check for at least one number
    // if (!value.contains(RegExp(r'[0-9]'))) {
    //   return 'Password must contain at least one number';
    // }

    // // Check for at least one special character
    // if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
    //   return 'Password must contain at least one special character';
    // }

    return null; // Return null if validation passes
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../../../../components/default_button.dart';
import '../../../../constants.dart';
import '../../../../services/auth_manager.dart';
import '../../../../size_config.dart';
import '../cubit/google_login_cubit.dart';
import '../widgets/custom_check_box.dart';
import '../widgets/form_header.dart';
import '../widgets/google_button.dart';
import 'email_verification_screen.dart';
import 'select_username_screen.dart';
import 'sign_in_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isLoading = false;
  final _signupFormKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
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
      body: BlocProvider(
        create: (context) => GoogleSignInCubit(),
        child: BlocBuilder<GoogleSignInCubit, GoogleSignInAccount?>(
          builder: (context, account) {
            if (account != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(account.photoUrl ?? ''),
                      radius: 40,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Welcome, ${account.displayName}',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelectUsernameScreen(),
                          ),
                        );
                      },
                      child: Text('Continue with Setup'),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        context.read<GoogleSignInCubit>().signOut();
                      },
                      child: Text('Sign Out'),
                    ),
                  ],
                ),
              );
            } else {
              return Container(
                width: double.infinity,
                height: double.infinity,
                decoration:
                    MediaQuery.of(context).platformBrightness == Brightness.dark
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
                          SizedBox(height: getProportionateScreenHeight(31.5)),
                          FormHeader(
                            isSignUp: true,
                            title: 'Create an account',
                            subtitle: 'Join the conversation',
                          ),
                          SizedBox(height: getProportionateScreenHeight(32)),
                          Form(
                            key: _signupFormKey,
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
                                SizedBox(
                                  height: getProportionateScreenHeight(6),
                                ),
                                TextFormField(
                                  controller: _emailController,
                                  style: Theme.of(context).textTheme.bodyMedium!
                                      .copyWith(fontWeight: FontWeight.w500),
                                  decoration: InputDecoration(
                                    hintText: "Enter your Email",
                                  ),
                                  validator: validateEmail,
                                ),
                                SizedBox(
                                  height: getProportionateScreenHeight(20),
                                ),
                                Text(
                                  "Password",
                                  style: Theme.of(context).textTheme.bodyMedium!
                                      .copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: labelColor,
                                      ),
                                ),
                                SizedBox(
                                  height: getProportionateScreenHeight(6),
                                ),
                                TextFormField(
                                  obscureText: _isLoading ? true : _obscureText,
                                  controller: _passwordController,
                                  style: Theme.of(context).textTheme.bodyMedium!
                                      .copyWith(fontWeight: FontWeight.w500),
                                  decoration: InputDecoration(
                                    hintText: "••••••••",
                                    hintStyle: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(color: kGreyFormHint),
                                    suffixIcon: Padding(
                                      padding: const EdgeInsetsDirectional.only(
                                        end: 16,
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _obscureText = !_obscureText;
                                          });
                                        },
                                        child: SvgPicture.asset(
                                          'assets/icons/eye.svg',
                                          color: _obscureText
                                              ? kGreyFormHint
                                              : null,
                                        ),
                                      ),
                                    ),
                                  ),
                                  validator: validatePassword,
                                ),
                                SizedBox(
                                  height: getProportionateScreenHeight(16),
                                ),
                                _isLoading
                                    ? Center(
                                        child: SizedBox(
                                          height: getProportionateScreenHeight(
                                            45,
                                          ),
                                          width: getProportionateScreenWidth(
                                            45,
                                          ),
                                          child:
                                              const CircularProgressIndicator(),
                                        ),
                                      )
                                    : DefaultButton(
                                        press: () async {
                                          if (_isLoading) return;
                                          setState(() {
                                            _isLoading = true;
                                          });
                                          try {
                                            if (_signupFormKey.currentState!
                                                .validate()) {
                                              _signupFormKey.currentState!
                                                  .save();
                                              final response = await http.post(
                                                Uri.parse(
                                                  '$baseUrl/api/v1/auth/register',
                                                ),
                                                headers: {
                                                  'Content-Type':
                                                      'application/json',
                                                },
                                                body: jsonEncode({
                                                  'email': _emailController.text
                                                      .trim(),
                                                  'password':
                                                      _passwordController.text
                                                          .trim(),
                                                }),
                                              );
                                              if (response.statusCode == 201) {
                                                final responseData = jsonDecode(
                                                  response.body,
                                                );
                                                final token =
                                                    responseData['access_token'];
                                                final refreshToken =
                                                    responseData['refresh_token'];

                                                // Use AuthManager instead of SharedPreferences
                                                await AuthManager.setToken(
                                                  token,
                                                );
                                                await AuthManager.setRefreshToken(
                                                  refreshToken,
                                                );

                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        EmailVerificationScreen(
                                                          email:
                                                              _emailController
                                                                  .text
                                                                  .trim(),
                                                        ),
                                                  ),
                                                );
                                              } else {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    backgroundColor: Colors.red,
                                                    content: Text(
                                                      jsonDecode(
                                                            response.body,
                                                          )['message']
                                                          .toString()
                                                          .replaceAll(
                                                            RegExp(r'\[|\]'),
                                                            '',
                                                          ),
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                          } catch (e) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                backgroundColor: Colors.red,
                                                content: Text(
                                                  'An error occurred: $e',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            );
                                          } finally {
                                            setState(() {
                                              _isLoading = false;
                                            });
                                          }
                                        },
                                        text: 'Continue with email',
                                      ),
                                SizedBox(
                                  height: getProportionateScreenHeight(24),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: SvgPicture.asset(
                                    "assets/images/or.svg",
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                SizedBox(
                                  height: getProportionateScreenHeight(24),
                                ),
                                GoogleButton(
                                  press: () {
                                    context.read<GoogleSignInCubit>().signUp(
                                      context,
                                    );
                                  },
                                  isSignin: false,
                                ),
                                // SizedBox(height: getProportionateScreenHeight(12)),
                                // FacebookButton(press: () {}, isSignin: false),
                                // SizedBox(height: getProportionateScreenHeight(12)),
                                // AppleButton(press: () {}, isSignin: false),
                                SizedBox(
                                  height: getProportionateScreenHeight(32),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomCheckbox(),
                                    SizedBox(
                                      width: getProportionateScreenWidth(8),
                                    ),
                                    Text(
                                      "I agree to the Terms and Privacy Policy",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    Spacer(),
                                  ],
                                ),
                                SizedBox(
                                  height: getProportionateScreenHeight(32),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Already have an account?",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    SizedBox(
                                      width: getProportionateScreenWidth(4),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const SignInScreen(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        "Log in",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
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
              );
            }
          },
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

  // Password validator function
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    // Check for at least one uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    // Check for at least one number
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    // Check for at least one special character
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }

    return null; // Return null if validation passes
  }
}

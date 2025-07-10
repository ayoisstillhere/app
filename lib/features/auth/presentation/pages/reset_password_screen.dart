import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:app/components/default_button.dart';
import 'package:app/features/auth/presentation/pages/verification_successful_screen.dart';
import 'package:app/features/auth/presentation/widgets/form_header.dart';
import 'package:http/http.dart' as http;

import '../../../../constants.dart';
import '../../../../size_config.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, required this.email});
  final String email;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  bool isLoading = false; // Add loading state

  @override
  void dispose() {
    _tokenController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true; // Set loading to true
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "email": widget.email,
          "token": _tokenController.text,
          "newPassword": _newPasswordController.text,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationSuccessfulScreen(isChange: true),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              jsonDecode(
                response.body,
              )['message'].toString().replaceAll(RegExp(r'\[|\]'), ''),
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    } catch (e) {
      // Handle any errors (network issues, etc.)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'An error occurred. Please try again.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    } finally {
      setState(() {
        isLoading = false; // Set loading to false
      });
    }
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: getProportionateScreenHeight(64)),
                    FormHeader(
                      isSignUp: false,
                      title: 'Password Reset',
                      subtitle:
                          'An OTP (One-time Password) has been sent to your mail for verfication',
                    ),
                    SizedBox(height: getProportionateScreenHeight(32)),
                    Text(
                      "Token",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w500,
                        color: labelColor,
                      ),
                    ),
                    SizedBox(height: getProportionateScreenHeight(6)),
                    TextFormField(
                      controller: _tokenController,
                      enabled: !isLoading, // Disable when loading
                      decoration: InputDecoration(
                        hintText: 'Enter the token sent to your mail',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        hintStyle: Theme.of(
                          context,
                        ).textTheme.bodyLarge!.copyWith(color: kGreyFormHint),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter the token';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: getProportionateScreenHeight(20)),
                    Text(
                      "New Password",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w500,
                        color: labelColor,
                      ),
                    ),
                    SizedBox(height: getProportionateScreenHeight(6)),
                    TextFormField(
                      controller: _newPasswordController,
                      enabled: !isLoading, // Disable when loading
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Enter new password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        hintStyle: Theme.of(
                          context,
                        ).textTheme.bodyLarge!.copyWith(color: kGreyFormHint),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter the new password';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: getProportionateScreenHeight(32)),
                    isLoading
                        ? Center(
                            child: SizedBox(
                              height: getProportionateScreenHeight(45),
                              width: getProportionateScreenWidth(45),
                              child: const CircularProgressIndicator(),
                            ),
                          )
                        : DefaultButton(text: "Verify", press: _resetPassword),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

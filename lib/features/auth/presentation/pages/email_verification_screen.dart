import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:app/components/default_button.dart';
import 'package:app/features/auth/presentation/pages/verification_successful_screen.dart';
import 'package:app/features/auth/presentation/widgets/form_header.dart';
import 'package:http/http.dart' as http;

import '../../../../constants.dart';
import '../../../../size_config.dart';
import '../widgets/otp_text_form_field.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key, required this.email});
  final String email;

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final FocusNode _firstFocusNode = FocusNode();
  final FocusNode _secondFocusNode = FocusNode();
  final FocusNode _thirdFocusNode = FocusNode();
  final FocusNode _fourthFocusNode = FocusNode();
  final FocusNode _fifthFocusNode = FocusNode();
  final FocusNode _sixthFocusNode = FocusNode();

  TextEditingController _controller1 = TextEditingController();
  TextEditingController _controller2 = TextEditingController();
  TextEditingController _controller3 = TextEditingController();
  TextEditingController _controller4 = TextEditingController();
  TextEditingController _controller5 = TextEditingController();
  TextEditingController _controller6 = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller1 = TextEditingController();
    _controller2 = TextEditingController();
    _controller3 = TextEditingController();
    _controller4 = TextEditingController();
    _controller5 = TextEditingController();
    _controller6 = TextEditingController();
  }

  @override
  void dispose() {
    _firstFocusNode.dispose();
    _secondFocusNode.dispose();
    _thirdFocusNode.dispose();
    _fourthFocusNode.dispose();
    _fifthFocusNode.dispose();
    _sixthFocusNode.dispose();
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    _controller4.dispose();
    _controller5.dispose();
    _controller6.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  SizedBox(height: getProportionateScreenHeight(64)),
                  FormHeader(
                    isSignUp: false,
                    title: 'Email Verification',
                    subtitle:
                        'An OTP (One-time Password) has been sent to your mail for verfication',
                  ),
                  SizedBox(height: getProportionateScreenHeight(32)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: OtpTextFormField(
                          focusNode: _firstFocusNode,
                          nextFocusNode: _secondFocusNode,
                          controller: _controller1,
                        ),
                      ),
                      SizedBox(width: getProportionateScreenWidth(13.4)),
                      Expanded(
                        child: OtpTextFormField(
                          focusNode: _secondFocusNode,
                          nextFocusNode: _thirdFocusNode,
                          controller: _controller2,
                        ),
                      ),
                      SizedBox(width: getProportionateScreenWidth(13.4)),
                      Expanded(
                        child: OtpTextFormField(
                          focusNode: _thirdFocusNode,
                          nextFocusNode: _fourthFocusNode,
                          controller: _controller3,
                        ),
                      ),
                      SizedBox(width: getProportionateScreenWidth(13.4)),
                      Expanded(
                        child: OtpTextFormField(
                          focusNode: _fourthFocusNode,
                          nextFocusNode: _fifthFocusNode,
                          controller: _controller4,
                        ),
                      ),
                      SizedBox(width: getProportionateScreenWidth(13.4)),
                      Expanded(
                        child: OtpTextFormField(
                          focusNode: _fifthFocusNode,
                          nextFocusNode: _sixthFocusNode,
                          controller: _controller5,
                        ),
                      ),
                      SizedBox(width: getProportionateScreenWidth(13.4)),
                      Expanded(
                        child: OtpTextFormField(
                          focusNode: _sixthFocusNode,
                          controller: _controller6,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: getProportionateScreenHeight(155)),
                  DefaultButton(
                    text: "Verify",
                    press: () async {
                      final response = await http.post(
                        Uri.parse('$baseUrl/api/v1/auth/verify-email'),
                        headers: {'Content-Type': 'application/json'},
                        body: json.encode({
                          'email': widget.email,
                          'otp':
                              _controller1.text +
                              _controller2.text +
                              _controller3.text +
                              _controller4.text +
                              _controller5.text +
                              _controller6.text,
                        }),
                      );
                      if (response.statusCode == 200) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const VerificationSuccessfulScreen(),
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
                    },
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

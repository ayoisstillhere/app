import 'package:app/components/default_button.dart';
import 'package:app/features/auth/presentation/pages/verification_successful_screen.dart';
import 'package:app/features/auth/presentation/widgets/form_header.dart';
import 'package:flutter/material.dart';

import '../../../../size_config.dart';
import '../widgets/otp_text_form_field.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

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

  @override
  void dispose() {
    _firstFocusNode.dispose();
    _secondFocusNode.dispose();
    _thirdFocusNode.dispose();
    _fourthFocusNode.dispose();
    _fifthFocusNode.dispose();
    _sixthFocusNode.dispose();
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
                      ),
                    ),
                    SizedBox(width: getProportionateScreenWidth(13.4)),
                    Expanded(
                      child: OtpTextFormField(
                        focusNode: _secondFocusNode,
                        nextFocusNode: _thirdFocusNode,
                      ),
                    ),
                    SizedBox(width: getProportionateScreenWidth(13.4)),
                    Expanded(
                      child: OtpTextFormField(
                        focusNode: _thirdFocusNode,
                        nextFocusNode: _fourthFocusNode,
                      ),
                    ),
                    SizedBox(width: getProportionateScreenWidth(13.4)),
                    Expanded(
                      child: OtpTextFormField(
                        focusNode: _fourthFocusNode,
                        nextFocusNode: _fifthFocusNode,
                      ),
                    ),
                    SizedBox(width: getProportionateScreenWidth(13.4)),
                    Expanded(
                      child: OtpTextFormField(
                        focusNode: _fifthFocusNode,
                        nextFocusNode: _sixthFocusNode,
                      ),
                    ),
                    SizedBox(width: getProportionateScreenWidth(13.4)),
                    Expanded(
                      child: OtpTextFormField(focusNode: _sixthFocusNode),
                    ),
                  ],
                ),
                SizedBox(height: getProportionateScreenHeight(155)),
                DefaultButton(
                  text: "Verify",
                  press: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const VerificationSuccessfulScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

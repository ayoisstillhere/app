import 'package:app/components/default_button.dart';
import 'package:app/features/auth/presentation/pages/verification_successful_screen.dart';
import 'package:app/features/auth/presentation/widgets/form_header.dart';
import 'package:flutter/material.dart';

import '../../../../size_config.dart';
import '../widgets/otp_text_form_field.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

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
                    const Expanded(child: OtpTextFormField()),
                    SizedBox(width: getProportionateScreenWidth(13.4)),
                    const Expanded(child: OtpTextFormField()),
                    SizedBox(width: getProportionateScreenWidth(13.4)),
                    const Expanded(child: OtpTextFormField()),
                    SizedBox(width: getProportionateScreenWidth(13.4)),
                    const Expanded(child: OtpTextFormField()),
                    SizedBox(width: getProportionateScreenWidth(13.4)),
                    const Expanded(child: OtpTextFormField()),
                    SizedBox(width: getProportionateScreenWidth(13.4)),
                    const Expanded(child: OtpTextFormField()),
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

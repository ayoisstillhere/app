import 'package:app/features/auth/presentation/pages/sign_in_screen.dart';
import 'package:flutter/material.dart';

import 'package:app/features/auth/presentation/pages/select_username_screen.dart';

import '../../../../components/default_button.dart';
import '../../../../size_config.dart';
import '../widgets/form_header.dart';

class VerificationSuccessfulScreen extends StatelessWidget {
  VerificationSuccessfulScreen({super.key, this.isChange = false});
  bool? isChange;

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
                  title: 'Verification Successful',
                  subtitle:
                      'An OTP (One-time Password) has been sent to your mail for verfication',
                ),
                SizedBox(height: getProportionateScreenHeight(32)),
                Image.asset(
                  'assets/images/verification_successful.gif',
                  height: getProportionateScreenHeight(150),
                  width: getProportionateScreenWidth(150),
                ),
                SizedBox(height: getProportionateScreenHeight(57)),
                DefaultButton(
                  text: "Verify",
                  press: () {
                    if (isChange!) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignInScreen(),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SelectUsernameScreen(),
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
    );
  }
}

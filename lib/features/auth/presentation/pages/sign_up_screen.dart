import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../components/default_button.dart';
import '../../../../constants.dart';
import '../../../../size_config.dart';
import '../widgets/custom_check_box.dart';
import '../widgets/form_header.dart';
import '../widgets/google_button.dart';
import 'email_verification_screen.dart';
import 'sign_in_screen.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

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
                  stops: [0.0, 0.18, 0.4],
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
                SizedBox(height: getProportionateScreenHeight(31.5)),
                FormHeader(
                  isSignUp: true,
                  title: 'Create an account',
                  subtitle: 'Join the conversation',
                ),
                SizedBox(height: getProportionateScreenHeight(32)),
                Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Email",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w500,
                          color: labelColor,
                        ),
                      ),
                      SizedBox(height: getProportionateScreenHeight(6)),
                      TextFormField(
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: "Enter your Email",
                        ),
                      ),
                      SizedBox(height: getProportionateScreenHeight(20)),
                      Text(
                        "Password",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w500,
                          color: labelColor,
                        ),
                      ),
                      SizedBox(height: getProportionateScreenHeight(6)),
                      TextFormField(
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: "••••••••",
                          hintStyle: Theme.of(
                            context,
                          ).textTheme.bodyLarge!.copyWith(color: kGreyFormHint),
                        ),
                      ),
                      SizedBox(height: getProportionateScreenHeight(16)),
                      DefaultButton(
                        press: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const EmailVerificationScreen(),
                            ),
                          );
                        },
                        text: 'Continue with email',
                      ),
                      SizedBox(height: getProportionateScreenHeight(24)),
                      SizedBox(
                        width: double.infinity,
                        child: SvgPicture.asset(
                          "assets/images/or.svg",
                          fit: BoxFit.fill,
                        ),
                      ),
                      SizedBox(height: getProportionateScreenHeight(24)),
                      GoogleButton(press: () {}, isSignin: false),
                      // SizedBox(height: getProportionateScreenHeight(12)),
                      // FacebookButton(press: () {}, isSignin: false),
                      // SizedBox(height: getProportionateScreenHeight(12)),
                      // AppleButton(press: () {}, isSignin: false),
                      SizedBox(height: getProportionateScreenHeight(32)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomCheckbox(),
                          SizedBox(width: getProportionateScreenWidth(8)),
                          Text(
                            "I agree to the Terms and Privacy Policy",
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(fontWeight: FontWeight.w500),
                          ),
                          Spacer(),
                        ],
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
    );
  }
}

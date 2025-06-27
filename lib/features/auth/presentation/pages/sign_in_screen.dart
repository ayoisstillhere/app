import 'package:app/components/default_button.dart';
import 'package:app/constants.dart';
import 'package:app/features/auth/presentation/widgets/google_button.dart';
import 'package:flutter/material.dart';

import '../../../../size_config.dart';
import '../widgets/form_header.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

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
                FormHeader(),
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
                          hintStyle: Theme.of(context).textTheme.displayLarge!
                              .copyWith(color: kGreyFormHint),
                        ),
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
                      DefaultButton(press: () {}, text: 'Sign In'),
                      SizedBox(height: getProportionateScreenHeight(16)),
                      GoogleButton(press: () {}),
                      SizedBox(height: getProportionateScreenHeight(32)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(fontWeight: FontWeight.w500),
                          ),
                          SizedBox(width: getProportionateScreenWidth(4)),
                          Text(
                            "Sign Up",
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: kLightPurple,
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

class CustomCheckbox extends StatefulWidget {
  const CustomCheckbox({super.key});

  @override
  State<CustomCheckbox> createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: getProportionateScreenWidth(16),
      height: getProportionateScreenHeight(16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: kWhite, // Background color
          border: Border.all(
            color: kGreyInputBorder, // Border color
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(
            getProportionateScreenWidth(4),
          ), // Corner radius
        ),
        child: Checkbox(
          value: isChecked,
          onChanged: (bool? value) {
            setState(() {
              isChecked = value!;
            });
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(getProportionateScreenWidth(4)),
            ),
          ),
        ),
      ),
    );
  }
}

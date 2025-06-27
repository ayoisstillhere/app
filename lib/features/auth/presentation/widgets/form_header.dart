import 'package:flutter/material.dart';

import '../../../../constants.dart';
import '../../../../size_config.dart';

class FormHeader extends StatelessWidget {
  const FormHeader({super.key, required this.isSignin});

  final bool isSignin;

  @override
  Widget build(BuildContext context) {
    final subTextColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? isSignin
              ? kGreenAccent
              : kGreyText
        : kGreyFormSubtitle;
    return Column(
      children: <Widget>[
        SizedBox(height: getProportionateScreenHeight(48)),
        Container(
          decoration: BoxDecoration(color: kLightPurple),
          height: getProportionateScreenHeight(30),
          width: getProportionateScreenWidth(85),
        ),
        SizedBox(height: getProportionateScreenHeight(24)),
        Text(
          isSignin ? "Log in to your account" : "Create an account",
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w500),
        ),
        SizedBox(height: getProportionateScreenHeight(8)),
        Text(
          isSignin
              ? "Welcome back! Please enter your details."
              : "Add your details to create an account.",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontWeight: FontWeight.w400,
            color: subTextColor,
          ),
        ),
      ],
    );
  }
}

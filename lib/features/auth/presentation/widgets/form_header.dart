import 'package:flutter/material.dart';

import '../../../../constants.dart';
import '../../../../size_config.dart';

class FormHeader extends StatelessWidget {
  const FormHeader({
    super.key,
    required this.isSignUp,
    required this.title,
    required this.subtitle,
  });

  final bool isSignUp;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final subTextColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? isSignUp
              ? kGreenAccent
              : kGreyText
        : kGreyFormSubtitle;
    return Column(
      children: <Widget>[
        Image.asset(
          'assets/images/hira_logo.png',
          width: getProportionateScreenWidth(50),
          height: getProportionateScreenWidth(50),
        ),
        SizedBox(height: getProportionateScreenHeight(24)),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w500),
        ),
        SizedBox(height: getProportionateScreenHeight(8)),
        Text(
          subtitle,
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

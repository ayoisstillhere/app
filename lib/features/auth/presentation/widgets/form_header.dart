
import 'package:flutter/material.dart';

import '../../../../constants.dart';
import '../../../../size_config.dart';

class FormHeader extends StatelessWidget {
  const FormHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
          "Log in to your account",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayMedium!.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: getProportionateScreenHeight(8)),
        Text(
          "Welcome back!👋 Please enter your details.",
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w400),
        ),
      ],
    );
  }
}

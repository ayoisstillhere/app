import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../constants.dart';
import '../../../../size_config.dart';

class AppleButton extends StatelessWidget {
  const AppleButton({
    super.key,
    required this.press,
    required this.isSignin,
  });
  final void Function() press;
  final bool isSignin;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(getProportionateScreenWidth(8)),
          border: Border.all(color: kGreyInputBorder, width: 1.0),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: getProportionateScreenWidth(18),
            vertical: getProportionateScreenHeight(10),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(child: SvgPicture.asset("assets/icons/apple_icon.svg")),
                SizedBox(width: getProportionateScreenWidth(12)),
                Text(
                  isSignin ? "Sign in with Apple" : "Sign up with Apple",
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

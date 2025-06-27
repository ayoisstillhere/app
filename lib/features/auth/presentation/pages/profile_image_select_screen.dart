import 'package:app/components/default_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../constants.dart';
import '../../../../size_config.dart';
import '../widgets/form_header.dart';

class ProfileImageSelectScreen extends StatelessWidget {
  const ProfileImageSelectScreen({super.key});

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
                SizedBox(height: getProportionateScreenHeight(56.4)),
                FormHeader(
                  isSignUp: false,
                  title: 'Profile',
                  subtitle: 'Edit your profile details',
                ),
                SizedBox(height: getProportionateScreenHeight(58.5)),
                Padding(
                  padding: EdgeInsetsGeometry.symmetric(
                    horizontal: getProportionateScreenWidth(74),
                  ),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Container(
                            width: getProportionateScreenWidth(84),
                            height: getProportionateScreenHeight(84),
                            padding: EdgeInsets.symmetric(
                              horizontal: getProportionateScreenWidth(24),
                              vertical: getProportionateScreenHeight(24),
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: kGreyInputBorder),
                              borderRadius: BorderRadius.all(
                                Radius.circular(
                                  getProportionateScreenWidth(10),
                                ),
                              ),
                            ),
                            child: SvgPicture.asset(
                              'assets/icons/picture_icon.svg',
                            ),
                          ),
                          SizedBox(height: getProportionateScreenHeight(11)),
                          Text(
                            'Profile image',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      Spacer(),
                      Column(
                        children: [
                          Container(
                            width: getProportionateScreenWidth(84),
                            height: getProportionateScreenHeight(84),
                            padding: EdgeInsets.symmetric(
                              horizontal: getProportionateScreenWidth(24),
                              vertical: getProportionateScreenHeight(24),
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: kGreyInputBorder),
                              borderRadius: BorderRadius.all(
                                Radius.circular(
                                  getProportionateScreenWidth(10),
                                ),
                              ),
                            ),
                            child: SvgPicture.asset(
                              'assets/icons/picture_icon.svg',
                            ),
                          ),
                          SizedBox(height: getProportionateScreenHeight(11)),
                          Text(
                            'Banner',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: getProportionateScreenHeight(43.5)),
                DefaultButton(text: 'Continue', press: () {}),
                SizedBox(height: getProportionateScreenHeight(16)),
                SkipButon(text: 'Skip', press: () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SkipButon extends StatelessWidget {
  const SkipButon({super.key, required this.text, required this.press});
  final String text;
  final void Function() press;

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kDarkPurple
        : kLightPurple;
    // final textColor =
    //     MediaQuery.of(context).platformBrightness == Brightness.dark
    //     ? kWhite
    //     : kBlack;
    return GestureDetector(
      onTap: press,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: primaryColor, width: 1.0),
          borderRadius: BorderRadius.circular(getProportionateScreenWidth(8)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: getProportionateScreenWidth(18),
            vertical: getProportionateScreenHeight(10),
          ),
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}

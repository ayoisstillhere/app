import 'package:app/features/auth/presentation/pages/profile_image_select_screen.dart';
import 'package:flutter/material.dart';

import '../../../../components/default_button.dart';
import '../../../../constants.dart';
import '../../../../size_config.dart';
import '../widgets/form_header.dart';

class SelectUsernameScreen extends StatelessWidget {
  const SelectUsernameScreen({super.key});

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
                SizedBox(height: getProportionateScreenHeight(76.91)),
                FormHeader(
                  isSignUp: false,
                  title: 'Select A Username',
                  subtitle: 'see what username is available',
                ),
                SizedBox(height: getProportionateScreenHeight(32)),
                Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Username",
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
                          hintText: "Enter your username",
                        ),
                      ),
                      SizedBox(height: getProportionateScreenHeight(20)),
                      Text(
                        "Name",
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
                          hintText: "Enter your name",
                          hintStyle: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(
                                color: kGreyFormHint,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      SizedBox(height: getProportionateScreenHeight(54)),
                      DefaultButton(
                        press: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ProfileImageSelectScreen(),
                            ),
                          );
                        },
                        text: 'Continue',
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

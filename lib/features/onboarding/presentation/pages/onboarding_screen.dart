import 'package:app/constants.dart';
import 'package:app/size_config.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/Onboarding1.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                actions: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      right: getProportionateScreenWidth(34),
                    ),
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        "Skip",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: kWhite,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Spacer(),
              
            ],
          ),
        ),
      ),
    );
  }
}

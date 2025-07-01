import 'package:app/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'features/onboarding/presentation/pages/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const OnboardingScreen(
            title: "Connect Freely",
            subtitle:
                "Share your thoughts, ideas, and moments — without limits",
            bgImage: "assets/images/Onboarding1.png",
            currentPage: 0,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
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
        child: Column(
          children: [
            SizedBox(height: getProportionateScreenHeight(273)),
            Image.asset(
              "assets/images/hira_logo.png",
              height: getProportionateScreenHeight(83),
              width: getProportionateScreenWidth(83),
            ),
            SizedBox(height: getProportionateScreenHeight(18)),
            Text(
              "HIRA",
              style: TextStyle(
                fontSize: getProportionateScreenHeight(24),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: getProportionateScreenHeight(25)),
            Text(
              "Connect. Share. Grow.",
              style: TextStyle(
                fontSize: getProportionateScreenHeight(18),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

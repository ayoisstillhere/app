import 'package:app/components/default_button.dart';
import 'package:app/constants.dart';
import 'package:app/features/onboarding/presentation/widgets/slider_indicator.dart';
import 'package:app/size_config.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final String bgImage;
  final int currentPage;

  const OnboardingScreen({
    required this.title,
    required this.subtitle,
    required this.bgImage,
    required this.currentPage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(bgImage), fit: BoxFit.cover),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.center,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: 1)],
              stops: [0, 1],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(31),
              ),
              child: Column(
                children: [
                  AppBar(
                    automaticallyImplyLeading: false,
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "Skip",
                          style: Theme.of(context).textTheme.bodyLarge!
                              .copyWith(
                                color: kWhite,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge!.copyWith(
                      fontWeight: FontWeight.w700,
                      color: kWhite,
                    ),
                  ),
                  SizedBox(height: getProportionateScreenHeight(23)),
                  SizedBox(
                    height: getProportionateScreenHeight(34),
                    child: Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w400,
                        color: kWhite,
                      ),
                    ),
                  ),
                  SizedBox(height: getProportionateScreenHeight(48.32)),
                  SliderIndicator(currentPage: currentPage),
                  SizedBox(height: getProportionateScreenHeight(33.32)),
                  currentPage == 2
                      ? DefaultButton(text: "Get Started", press: () {})
                      : DefaultButton(
                          text: "Next",
                          press: () {
                            if (currentPage == 0) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const OnboardingScreen(
                                    title: "Post Live Update",
                                    subtitle:
                                        "Let your friends and followers know what is  on your mind at anytime",
                                    bgImage: "assets/images/Onboarding2.png",
                                    currentPage: 1,
                                  ),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const OnboardingScreen(
                                    title: "Larger Audience",
                                    subtitle:
                                        "Reach larger audiences with your content",
                                    bgImage: "assets/images/Onboarding3.png",
                                    currentPage: 2,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                  // SizedBox(height: getProportionateScreenHeight(50)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

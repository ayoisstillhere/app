import 'package:flutter/material.dart';

import '../widgets/body.dart';

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
    return Scaffold(
      body: Body(
        bgImage: bgImage,
        title: title,
        subtitle: subtitle,
        currentPage: currentPage,
      ),
    );
  }
}

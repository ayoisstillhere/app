import 'package:app/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:app/theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: theme(),
      home: const OnboardingScreen(
        title: "Connect Freely",
        subtitle: "Share your thoughts, ideas, and moments — without limits",
        bgImage: "assets/images/Onboarding1.png",
        currentPage: 0,
      ),
    );
  }
}

import 'package:app/components/nav_page.dart';
import 'package:app/services/auth_manager.dart';
import 'package:app/services/secret_chat_encryption_service.dart';
import 'package:app/services/deep_link_navigation_service.dart'; // Add this import
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
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _checkAuthAndNavigate();
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
            ? const BoxDecoration(
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
            : const BoxDecoration(),
        child: Column(
          children: [
            SizedBox(height: getProportionateScreenHeight(273)),
            Image.asset(
              "assets/images/hira_logo.png",
              height: getProportionateScreenHeight(83),
              width: getProportionateScreenWidth(83),
            ),
            SizedBox(height: getProportionateScreenHeight(6)),
            Text(
              "HIRA",
              style: TextStyle(
                fontSize: getProportionateScreenHeight(24),
                fontWeight: FontWeight.w500,
              ),
            ),
            // SizedBox(height: getProportionateScreenHeight(4)),
            Text(
              "...be heard",
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

  Future<void> _checkAuthAndNavigate() async {
    try {
      // Add a delay for splash screen display
      await Future.delayed(const Duration(seconds: 3));

      // Prevent multiple navigation attempts
      if (_hasNavigated || !mounted) return;

      // Check for stored token
      final token = await AuthManager.getToken();

      if (token != null && token.isNotEmpty) {
        // Try to refresh the token to ensure it's valid
        final refreshed = await AuthManager.refreshToken();

        if (refreshed) {
          // Token is valid, now ensure encryption keys exist
          final encryptionService = SecretChatEncryptionService();
          await encryptionService.ensureKeyPairExists();

          // Token is valid, navigate to main app
          _navigateToHome();
        } else {
          // Token refresh failed, user needs to login again
          _navigateToOnboarding();
        }
      } else {
        // No token found, user needs to login
        _navigateToOnboarding();
      }
    } catch (e) {
      // Handle any errors by navigating to onboarding
      debugPrint('Error during auth check: $e');
      _navigateToOnboarding();
    }
  }

  void _navigateToHome() async {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    // Navigate to main app
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => const NavPage()));

    // Handle initial deep link after navigation is complete
    // Add a small delay to ensure the navigation is complete
    await Future.delayed(const Duration(milliseconds: 500));

    // Now handle any initial deep link
    DeepLinkNavigationService.handleInitialLink();

    // Process any queued deep links
    DeepLinkNavigationService.onAppReady();
  }

  void _navigateToOnboarding() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const OnboardingScreen(
          title: "Connect Freely",
          subtitle: "Share your thoughts, ideas, and moments — without limits",
          bgImage: "assets/images/Onboarding1.png",
          currentPage: 0,
        ),
      ),
    );
  }
}

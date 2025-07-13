import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import '../services/auth_manager.dart';
import '../features/profile/presentation/pages/profile_screen.dart';

class DeepLinkNavigationService {
  static final _appLinks = AppLinks();
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // Queue to store pending deep links
  static final List<Uri> _pendingDeepLinks = [];
  static bool _isInitialized = false;

  static BuildContext? get context => navigatorKey.currentContext;

  /// Initialize deep link handling
  static void initialize() {
    if (_isInitialized) return;
    _isInitialized = true;

    // Listen for incoming deep links while app is running
    _appLinks.uriLinkStream.listen(
      (uri) {
        handleDeepLink(uri);
      },
      onError: (err) {
        debugPrint('Deep link error: $err');
      },
    );
  }

  /// Get initial deep link without handling it
  static Future<Uri?> getInitialLink() async {
    try {
      return await _appLinks.getInitialLink();
    } catch (e) {
      debugPrint('Error getting initial deep link: $e');
      return null;
    }
  }

  /// Handle initial deep link when app is launched
  static Future<void> handleInitialLink() async {
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        // Add a delay and retry mechanism
        await _waitForContextAndHandle(initialLink);
      }
    } catch (e) {
      debugPrint('Error handling initial deep link: $e');
    }
  }

  /// Wait for context to be available and handle the deep link
  static Future<void> _waitForContextAndHandle(Uri uri) async {
    int attempts = 0;
    const maxAttempts = 20; // 10 seconds total
    const delayMs = 500;

    while (attempts < maxAttempts) {
      if (context != null) {
        handleDeepLink(uri);
        return;
      }

      attempts++;
      await Future.delayed(Duration(milliseconds: delayMs));
    }

    // If context is still null after waiting, queue the deep link
    debugPrint('Context still null after waiting, queuing deep link: $uri');
    _pendingDeepLinks.add(uri);
  }

  /// Process queued deep links when context becomes available
  static void processQueuedDeepLinks() {
    if (context == null || _pendingDeepLinks.isEmpty) return;

    final pendingLinks = List<Uri>.from(_pendingDeepLinks);
    _pendingDeepLinks.clear();

    for (final uri in pendingLinks) {
      handleDeepLink(uri);
    }
  }

  /// Process deep link and navigate accordingly
  static void handleDeepLink(Uri uri) {
    debugPrint('Handling deep link: $uri');

    // If context is null, queue the deep link
    if (context == null) {
      debugPrint('Context is null, queuing deep link: $uri');
      _pendingDeepLinks.add(uri);
      return;
    }

    // Check if it's a profile deep link
    if (uri.pathSegments.isNotEmpty && uri.pathSegments[0] == 'profile') {
      if (uri.pathSegments.length > 1) {
        final username = uri.pathSegments[1];
        navigateToProfile(username);
      }
    } else {
      debugPrint('Invalid deep link: $uri');
    }

    // Add more deep link handlers here if needed
    // Example: posts, messages, etc.
  }

  /// Navigate to profile screen with better error handling
  static Future<void> navigateToProfile(String username) async {
    // Double-check context availability
    if (context == null) {
      debugPrint('Navigation context is null, queuing navigation');
      _pendingDeepLinks.add(Uri.parse('/profile/$username'));
      return;
    }

    try {
      // Check if user is logged in first
      final isLoggedIn = await isUserLoggedIn();
      if (!isLoggedIn) {
        _showErrorMessage('Please log in to view profiles');
        return;
      }

      // Show loading indicator
      showDialog(
        context: context!,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Get current user
      final currentUser = await AuthManager.getCurrentUser();

      // Hide loading indicator
      if (context != null) {
        Navigator.of(context!).pop();
      }

      if (currentUser == null) {
        _showErrorMessage('Please log in to view profiles');
        return;
      }

      // Navigate to profile screen
      if (context != null) {
        Navigator.push(
          context!,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(
              isVerified: true, // You might want to fetch this from API
              userName: username,
              currentUser: currentUser,
              isFromNav: false,
            ),
          ),
        );
      }
    } catch (e) {
      // Hide loading indicator if still showing
      if (context != null) {
        Navigator.of(context!).pop();
      }

      debugPrint('Error navigating to profile: $e');
      _showErrorMessage('Could not open profile. Please try again.');
    }
  }

  /// Show error message to user
  static void _showErrorMessage(String message) {
    if (context == null) {
      debugPrint('Cannot show error message, context is null: $message');
      return;
    }

    ScaffoldMessenger.of(context!).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Alternative method: Navigate and replace current screen
  static Future<void> navigateToProfileAndReplace(String username) async {
    if (context == null) {
      _pendingDeepLinks.add(Uri.parse('/profile/$username?replace=true'));
      return;
    }

    try {
      final isLoggedIn = await isUserLoggedIn();
      if (!isLoggedIn) {
        _showErrorMessage('Please log in to view profiles');
        return;
      }

      showDialog(
        context: context!,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final currentUser = await AuthManager.getCurrentUser();
      
      if (context != null) {
        Navigator.of(context!).pop();
      }

      if (currentUser == null) {
        _showErrorMessage('Please log in to view profiles');
        return;
      }

      // Replace current screen instead of pushing
      if (context != null) {
        Navigator.pushReplacement(
          context!,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(
              isVerified: true,
              userName: username,
              currentUser: currentUser,
              isFromNav: false,
            ),
          ),
        );
      }
    } catch (e) {
      if (context != null) Navigator.of(context!).pop();
      debugPrint('Error navigating to profile: $e');
      _showErrorMessage('Could not open profile. Please try again.');
    }
  }

  /// Clear navigation stack and go to profile
  static Future<void> navigateToProfileAndClearStack(String username) async {
    if (context == null) {
      _pendingDeepLinks.add(Uri.parse('/profile/$username?clearStack=true'));
      return;
    }

    try {
      final isLoggedIn = await isUserLoggedIn();
      if (!isLoggedIn) {
        _showErrorMessage('Please log in to view profiles');
        return;
      }

      final currentUser = await AuthManager.getCurrentUser();

      if (currentUser == null) {
        _showErrorMessage('Please log in to view profiles');
        return;
      }

      // Clear navigation stack and go to profile
      if (context != null) {
        Navigator.pushAndRemoveUntil(
          context!,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(
              isVerified: true,
              userName: username,
              currentUser: currentUser,
              isFromNav: false,
            ),
          ),
          (route) => false, // Remove all previous routes
        );
      }
    } catch (e) {
      debugPrint('Error navigating to profile: $e');
      _showErrorMessage('Could not open profile. Please try again.');
    }
  }

  /// Check if user is logged in
  static Future<bool> isUserLoggedIn() async {
    final token = await AuthManager.getToken();
    return token != null;
  }

  /// Call this method when your app's main widget is built
  static void onAppReady() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      processQueuedDeepLinks();
    });
  }
}
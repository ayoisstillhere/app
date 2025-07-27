// 2. Create a sharing service
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ProfileSharingService {
  static Future<void> shareProfile({
    required String username,
    required String fullName,
    String? profileImage,
  }) async {
    try {
      // Create deep link for your app
      final deepLink = 'hira://app/profile/$username';

      // Alternative: Use a custom URL scheme
      // final deepLink = 'https://hira.com/profile/$username';

      final shareText =
          '''
Check out $fullName's profile on Hira!
@$username

$deepLink

#Hira #Profile
''';

      // Use the new SharePlus.instance.share() method
      await SharePlus.instance.share(
        ShareParams(text: shareText, title: '$fullName\'s Profile'),
      );
    } catch (e) {
      debugPrint('Error sharing profile: $e');
      // Handle error appropriately
    }
  }
}

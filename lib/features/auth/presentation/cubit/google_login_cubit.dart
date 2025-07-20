import 'dart:convert';
import 'dart:io';

import 'package:app/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../../../../services/auth_manager.dart';

class GoogleSignInCubit extends Cubit<GoogleSignInAccount?> {
  final GoogleSignIn _googleSignIn;

  GoogleSignInCubit() : _googleSignIn = GoogleSignIn(), super(null);

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      // This prevents data loss on app updates
      sharedPreferencesName: 'FlutterSecureStorage',
      preferencesKeyPrefix: 'flutter_secure_storage_',
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Sign in with Google
  Future<void> signIn(BuildContext context) async {
    try {
      final account = await _googleSignIn.signIn();
      final GoogleSignInAuthentication auth = await account!.authentication;
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/auth/login-with-google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': account.email,
          'token': auth.idToken,
          'deviceId': await _secureStorage.read(key: "fcm_token"),
          'platform': Platform.isAndroid ? 'ANDROID' : 'IOS',
        }),
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final token = responseData['access_token'];
        final refreshToken = responseData['refresh_token'];

        // Use AuthManager instead of SharedPreferences
        await AuthManager.setToken(token);
        await AuthManager.setRefreshToken(refreshToken);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              jsonDecode(
                response.body,
              )['message'].toString().replaceAll(RegExp(r'\[|\]'), ''),
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
      emit(account);
    } catch (error) {
      emit(null);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    emit(null);
  }
}

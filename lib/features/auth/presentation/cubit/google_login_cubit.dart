import 'dart:convert';
import 'dart:io';

import 'package:app/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../../../../services/auth_manager.dart';
import '../../../../services/secret_chat_encryption_service.dart';

class GoogleSignInCubit extends Cubit<GoogleSignInAccount?> {
  final GoogleSignIn _googleSignIn;

  GoogleSignInCubit()
    : _googleSignIn = GoogleSignIn(scopes: ['email']),
      super(null);

  // Sign in with Google
  Future<void> signIn(BuildContext context) async {
    await AuthManager.logout();
    try {
      final account = await _googleSignIn.signIn();
      final GoogleSignInAuthentication auth = await account!.authentication;
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/auth/login-with-google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': account.email,
          'token': auth.idToken,
          'deviceId': await AuthManager.getFCMToken(),
          'platform': Platform.isAndroid ? 'ANDROID' : 'IOS',
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final token = responseData['access_token'];
        final refreshToken = responseData['refresh_token'];

        // Use AuthManager instead of SharedPreferences
        await AuthManager.setToken(token);
        await AuthManager.setRefreshToken(refreshToken);
        final encryptionService = SecretChatEncryptionService();
        await encryptionService.ensureKeyPairExists();
        emit(account);
      } else {
        emit(null);
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
    } catch (error) {
      emit(null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Error Signing In with Google",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  Future<void> signUp(BuildContext context) async {
    await AuthManager.logout();
    try {
      final account = await _googleSignIn.signIn();
      final GoogleSignInAuthentication auth = await account!.authentication;
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/auth/register-with-google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': account.email,
          'token': auth.idToken,
          'platform': Platform.isAndroid ? 'ANDROID' : 'IOS',
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final token = responseData['access_token'];
        final refreshToken = responseData['refresh_token'];

        // Use AuthManager instead of SharedPreferences
        await AuthManager.setToken(token);
        await AuthManager.setRefreshToken(refreshToken);
        final encryptionService = SecretChatEncryptionService();
        await encryptionService.ensureKeyPairExists();
        emit(account);
      } else {
        emit(null);
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
    } catch (error) {
      emit(null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Error Signing Up with Google",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    emit(null);
  }
}

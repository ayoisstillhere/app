import 'dart:convert';
import 'package:app/services/auth_manager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MessageReactionsService {
  static const String _baseUrl = 'https://api.hiraofficial.com/api/v1';

  static Future<bool> addReaction(String messageId, String emoji) async {
    try {
      final token = await AuthManager.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/messages/$messageId/reactions'),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'emoji': emoji}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        debugPrint(
          'Failed to add reaction: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error adding reaction: $e');
      return false;
    }
  }

  static Future<bool> removeReaction(String messageId, String emoji) async {
    try {
      final token = await AuthManager.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/messages/$messageId/reactions/$emoji/delete'),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 201) {
        return true;
      } else {
        debugPrint(
          'Failed to remove reaction: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error removing reaction: $e');
      return false;
    }
  }
}

// Add to auth_manager.dart or create a new file like api_client.dart
import 'package:app/services/auth_manager.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';

class ApiClient {
  static Future<http.Response> authenticatedRequest(
    String method,
    String endpoint,
    {Map<String, String>? headers, Object? body}
  ) async {
    final token = await AuthManager.getToken();
    final allHeaders = {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
      ...?headers,
    };
    
    http.Response response;
    final url = Uri.parse("$baseUrl$endpoint");
    
    // Make the request based on method
    switch (method) {
      case 'GET':
        response = await http.get(url, headers: allHeaders);
        break;
      case 'POST':
        response = await http.post(url, headers: allHeaders, body: body);
        break;
      case 'PUT':
        response = await http.put(url, headers: allHeaders, body: body);
        break;
      case 'DELETE':
        response = await http.delete(url, headers: allHeaders);
        break;
      default:
        throw Exception('Unsupported HTTP method');
    }
    
    // If token expired (401), try to refresh and retry the request once
    if (response.statusCode == 401) {
      final refreshed = await AuthManager.refreshToken();
      if (refreshed) {
        // Update token in headers and retry
        final newToken = await AuthManager.getToken();
        allHeaders["Authorization"] = "Bearer $newToken";
        
        // Retry the request
        switch (method) {
          case 'GET':
            return await http.get(url, headers: allHeaders);
          case 'POST':
            return await http.post(url, headers: allHeaders, body: body);
          case 'PUT':
            return await http.put(url, headers: allHeaders, body: body);
          case 'DELETE':
            return await http.delete(url, headers: allHeaders);
          default:
            throw Exception('Unsupported HTTP method');
        }
      }
    }
    
    return response;
  }
}
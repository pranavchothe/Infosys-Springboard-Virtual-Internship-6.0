import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatbotApiService {
  static const String baseUrl = "http://127.0.0.1:8000";

  Future<String> sendMessage(String message, int recordId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("access_token");

      if (token == null) {
        throw Exception("Not authenticated");
      }

      final response = await http.post(
        Uri.parse("$baseUrl/chat"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "message": message,
          "record_id": recordId,
        }),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map && decoded["reply"] != null) {
          return decoded["reply"].toString();
        } else {
          throw Exception("Invalid chatbot response format");
        }
      } else if (response.statusCode == 401) {
        throw Exception("Unauthorized. Please login again.");
      } else {
        throw Exception(
          "Chat failed (${response.statusCode})",
        );
      }
    } catch (e) {
      throw Exception("Chatbot request failed: $e");
    }
  }
}

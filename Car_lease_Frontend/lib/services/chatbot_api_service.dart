import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatbotApiService {
  static const String baseUrl = "http://127.0.0.1:8000";

  Future<String> sendMessage(String message, int recordId) async {
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
      final data = jsonDecode(response.body);
      return data["reply"];
    } else {
      throw Exception("Chat failed");
    }
  }
}

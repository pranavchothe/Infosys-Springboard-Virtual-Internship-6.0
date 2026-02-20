import 'dart:convert';
import 'package:http/http.dart' as http;

class DealerChatService {
  static const String baseUrl = "http://127.0.0.1:8000";

  static Future<String> sendMessage({
    required int leaseId,
    required String message,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/dealer-chat"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "lease_id": leaseId,
        "message": message,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["reply"];
    } else {
      throw Exception("Dealer chat failed");
    }
  }

  static Future<List<dynamic>> loadHistory(int leaseId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/dealer-chat/$leaseId"),
    );

    return jsonDecode(response.body);
  }
}

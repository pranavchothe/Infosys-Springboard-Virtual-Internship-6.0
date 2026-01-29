import 'dart:convert';
import 'package:http/http.dart' as http;
import 'chatbot_context.dart';

class AIChatService {
  static const baseUrl = "http://127.0.0.1:8000";

  Future<String> sendMessage(String message) async {
    final car = ChatBotContext.currentCar;

    final response = await http.post(
      Uri.parse("$baseUrl/ai-chat"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "message": message,
        "car_context": car,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["reply"];
    } else {
      return "AI service unavailable";
    }
  }
}

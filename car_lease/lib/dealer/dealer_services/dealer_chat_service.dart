import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
class DealerChatService {
  
  static const String baseUrl = "http://127.0.0.1:8000";

  // LOAD CHAT HISTORY
  static Future<List<dynamic>> loadHistory(int leaseId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/dealer-chat/$leaseId"),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load chat history");
    }

    return jsonDecode(res.body);
  }

  
  // SEND CUSTOMER MESSAGE
  // --------------------------------
  static Future<void> sendMessage({
    required int leaseId,
    required String message,
  }) async {

    final response = await http.post(
      Uri.parse("http://127.0.0.1:8000/dealer-chat"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "lease_id": leaseId,
        "message": message,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to send message");
    }
  }


  // DEALER REPLY
 
  static Future<void> sendDealerReply({
    required int leaseId,
    required String message,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("dealer_token");

      print("Dealer token: $token");

      final response = await http.post(
        Uri.parse("$baseUrl/dealer-chat/reply"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "lease_id": leaseId,
          "message": message,
        }),
      );

      print("Dealer reply status: ${response.statusCode}");
      print("Dealer reply body: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception("Failed to send dealer reply");
      }
    } catch (e) {
      print("Dealer reply error: $e");
      rethrow;
    }
  }



  // MARK MESSAGES AS READ
  static Future<void> markMessagesRead(int leaseId) async {
    final res = await http.post(
      Uri.parse("$baseUrl/dealer-chat/mark-read/$leaseId"),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to mark messages as read");
    }
  }

  
  // GET DEALER ONLINE STATUS
  static Future<bool> getDealerStatus() async {
    final res = await http.get(
      Uri.parse("$baseUrl/dealer/status"),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to fetch dealer status");
    }

    final data = jsonDecode(res.body);
    return data["online"] == true;
  }

 
  // DEALER HEARTBEAT =-
  
  static Future<void> sendDealerHeartbeat() async {
    final res = await http.post(
      Uri.parse("$baseUrl/dealer/status/heartbeat"),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to send dealer heartbeat");
    }
  }


 
  // DEALER DASHBOARD
 
  static Future<List<dynamic>> loadDealerDashboard() async {
    final res = await http.get(
      Uri.parse("$baseUrl/dealer/dashboard"),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load dealer dashboard");
    }

    return jsonDecode(res.body);
  }


  static Future<void> sendHeartbeat() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("dealer_token");

    await http.post(
      Uri.parse("http://127.0.0.1:8000/dealer/status/heartbeat"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );
  }

  static Future<List<String>> getAiSuggestion({
    required int leaseId,
    required String dealerMessage,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");

    final response = await http.post(
      Uri.parse("http://127.0.0.1:8000/dealer-chat/ai-suggestion"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "lease_id": leaseId,
        "dealer_message": dealerMessage,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final raw = (data["suggestion"] ?? "").toString().trim();

      print("AI RAW STRING CLEAN: $raw");

      if (raw.isEmpty) return [];

      // If single sentence (no new lines)
      if (!raw.contains("\n")) {
        return [raw.replaceAll('"', '')];
      }

      final lines = raw
          .split("\n")
          .map((e) => e.replaceAll(RegExp(r'^[•\-\*\d\.\s]+'), '').trim())
          .where((e) => e.isNotEmpty)
          .toList();

      return lines;
    }

    return [];
  }

}


import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DealerLeaseService {
  static const String baseUrl =
      "http://127.0.0.1:8000";

  Future<List<dynamic>> getDealerLeases() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("dealer_token");

    final response = await http.get(
      Uri.parse("$baseUrl/dealer/leases"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          "Failed with status ${response.statusCode}");
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HistoryService {
  static const String baseUrl = "http://127.0.0.1:8000";

  static Future<List<Map<String, dynamic>>> fetchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");

    if (token == null) return [];

    final response = await http.get(
      Uri.parse("$baseUrl/lease/history"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      return [];
    }

    final List data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data);
  }

  static Future<Map<String, dynamic>?> fetchResultById(int id) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("access_token");
  if (token == null) return null;

  final response = await http.get(
    Uri.parse("$baseUrl/lease/$id"),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  if (response.statusCode != 200) {
    return null;
  }

  return jsonDecode(response.body);
}

}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/analysis_result.dart';

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000";

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("access_token");
  }

  Map<String, String> _headers(String? token) {
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  /// FETCH HISTORY
  Future<List<AnalysisResult>> getHistory() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/history"),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded is List) {
        return decoded
            .map((e) => AnalysisResult.fromJson(e))
            .toList();
      } else {
        throw Exception("Invalid history response format");
      }
    } else {
      throw Exception(
        "Failed to fetch history (${response.statusCode})",
      );
    }
  }

  /// FETCH SINGLE RECORD
  Future<AnalysisResult> getHistoryById(int id) async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/history/$id"),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return AnalysisResult.fromJson(decoded);
      } else {
        throw Exception("Invalid record response format");
      }
    } else {
      throw Exception(
        "Failed to load record (${response.statusCode})",
      );
    }
  }
}

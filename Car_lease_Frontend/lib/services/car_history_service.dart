import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CarHistoryService {
  static const String baseUrl = "http://127.0.0.1:8000"; 
  

  Future<Map<String, dynamic>> fetchCarFullHistory(String vin) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");
    print("DEBUG CAR HISTORY TOKEN: $token");


    if (token == null) {
      throw Exception("User not logged in. Token not found.");
    }

    final url = Uri.parse("$baseUrl/car-full-history");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "vin": vin,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized. Please login again.");
    } else {
      throw Exception(
        "Failed to fetch car history: ${response.statusCode} ${response.body}",
      );
    }
  }
}

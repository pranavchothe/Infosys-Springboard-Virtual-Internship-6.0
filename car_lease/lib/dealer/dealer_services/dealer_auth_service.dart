import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DealerAuthService {
  
  static const String baseUrl = "http://127.0.0.1:8000";

  // =============================
  // REGISTER DEALER
  // =============================
  Future<String?> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/dealer-auth/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        return null; // SUCCESS
      } else {
        final data = jsonDecode(response.body);
        return data["detail"] ?? "Registration failed";
      }
    } catch (e) {
      return "Connection error. Please check backend.";
    }
  }

  // =============================
  // LOGIN DEALER
  // =============================
  Future<String?> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/dealer-auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final prefs = await SharedPreferences.getInstance();

        await prefs.setString("dealer_token", data["access_token"]);
        await prefs.setInt("dealer_id", data["dealer_id"]);
        await prefs.setString("dealer_name", data["name"]);

        return null; // SUCCESS
      } else {
        final data = jsonDecode(response.body);
        return data["detail"] ?? "Invalid credentials";
      }
    } catch (e) {
      return "Connection error. Please check backend.";
    }
  }

  // =============================
  // GET DEALER TOKEN
  // =============================
  static Future<String?> getDealerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("dealer_token");
  }

  // =============================
  // GET DEALER NAME
  // =============================
  static Future<String?> getDealerName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("dealer_name");
  }

  // =============================
  // GET DEALER ID
  // =============================
  static Future<int?> getDealerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("dealer_id");
  }

  // =============================
  // LOGOUT DEALER
  // =============================
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("dealer_token");
    await prefs.remove("dealer_id");
    await prefs.remove("dealer_name");
  }

  // =============================
  // CHECK IF DEALER LOGGED IN
  // =============================
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("dealer_token") != null;
  }

  // =============================
  // AUTH HEADER HELPER
  // =============================
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getDealerToken();

    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const baseUrl = "http://127.0.0.1:8000";

  Future<bool> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
      }),
    );

    return response.statusCode == 200;
  }

  Future<bool> login(String email, String password) async {
  final response = await http.post(
    Uri.parse("$baseUrl/auth/login"),
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "email": email,
      "password": password,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("access_token", data["access_token"]);

    return true;
  }

  return false;
}

}
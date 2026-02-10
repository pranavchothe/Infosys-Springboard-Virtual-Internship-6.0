import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/login_screen.dart';

class AuthService {
  static const String baseUrl = "http://127.0.0.1:8000";

  // ================= REGISTER =================
  Future<bool> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/register"),
        headers: const {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("Register error: $e");
      return false;
    }
  }

  // ================= LOGIN =================
  Future<bool> login(String email, String password) async {
  try {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: const {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();

      //SAVE TOKEN
      await prefs.setString(
        "access_token",
        decoded["access_token"],
      );

      // SAVE NAME
      if (decoded["name"] != null) {
        await prefs.setString("user_name", decoded["name"]);
      }

      // SAVE EMAIL
      await prefs.setString("user_email", email);
      return true;
    }

    return false;
  } catch (e) {
    debugPrint("Login error: $e");
    return false;
  }
}



  // ================= LOGOUT =================
  static Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    // Remove JWT
    await prefs.remove("access_token");

    // Clear navigation stack and go to login
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // ================= GET TOKEN =================
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("access_token");
  }

  // ================= CHECK LOGIN =================
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}

import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000";

  Future<Map<String, dynamic>?> uploadBytes(
    Uint8List bytes, String filename) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("access_token");

  if (token == null) return null;

  var request =
      http.MultipartRequest("POST", Uri.parse("$baseUrl/upload"));

  request.headers["Authorization"] = "Bearer $token";
  request.files.add(
    http.MultipartFile.fromBytes(
      "file",
      bytes,
      filename: filename,
    ),
  );

  var response = await request.send();
  final body = await response.stream.bytesToString();

  if (response.statusCode == 200) {
  return jsonDecode(body);
} else {
  print("Upload failed: ${response.statusCode}");
  print("Response body: $body");  
  return null;
}

}


  Future<List<dynamic>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");

    final response = await http.get(
      Uri.parse("$baseUrl/history"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return List<dynamic>.from(
          jsonDecode(await response.bodyBytes.toString()));
    } else {
      return [];
    }
  }
}

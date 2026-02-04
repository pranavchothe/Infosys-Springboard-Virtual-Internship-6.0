import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UploadService {
  static const String baseUrl = "http://127.0.0.1:8000";

  Future<Map<String, dynamic>?> uploadLeaseBytes(
    Uint8List bytes,
    String filename,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");

    if (token == null) {
      throw Exception("Not authenticated");
    }

    final request =
        http.MultipartRequest("POST", Uri.parse("$baseUrl/upload"));

    request.headers["Authorization"] = "Bearer $token";

    request.files.add(
      http.MultipartFile.fromBytes(
        "file",
        bytes,
        filename: filename,
      ),
    );

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return jsonDecode(body);
    } else {
      throw Exception("Upload failed");
    }
  }
}

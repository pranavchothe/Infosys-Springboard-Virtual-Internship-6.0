import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UploadService {
  static const String baseUrl = "http://127.0.0.1:8000";
  
  Future<Map<String, dynamic>> uploadLeaseBytes(
    Uint8List fileBytes,
    String fileName,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");


    if (token == null) {
      throw Exception("User not logged in. Token not found.");
    }

    final uri = Uri.parse("$baseUrl/upload");

    final request = http.MultipartRequest("POST", uri);

    // Add Authorization header
    request.headers["Authorization"] = "Bearer $token";

    // Add file using bytes (works on Web)
    request.files.add(
      http.MultipartFile.fromBytes(
        "file",
        fileBytes,
        filename: fileName,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized. Please login again.");
    } else {
      throw Exception(
        "Upload failed: ${response.statusCode} ${response.body}",
      );
    }
  }
}

import 'dart:typed_data';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'result_screen.dart';
import 'processing_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  Uint8List? pdfBytes;
  String? fileName;

  final String baseUrl = "http://127.0.0.1:8000";

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("access_token");
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        pdfBytes = result.files.single.bytes;
        fileName = result.files.single.name;
      });
    }
  }

  void _showProcessing(int step) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ProcessingDialog(currentStep: step),
    );
  }

  Future<void> _sendPdfToBackend() async {
    if (pdfBytes == null || fileName == null) return;

    try {
      _showProcessing(0);
      await Future.delayed(const Duration(milliseconds: 300));

      final token = await _getToken();
      if (token == null) return;

      Navigator.pop(context);
      _showProcessing(1);

      final uri = Uri.parse("$baseUrl/upload");
      final request = http.MultipartRequest("POST", uri);
      request.headers["Authorization"] = "Bearer $token";

      request.files.add(
        http.MultipartFile.fromBytes(
          "file",
          pdfBytes!,
          filename: fileName,
          contentType: MediaType("application", "pdf"),
        ),
      );

      Navigator.pop(context);
      _showProcessing(2);

      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();

      Navigator.pop(context);
      _showProcessing(3);
      await Future.delayed(const Duration(milliseconds: 300));

      if (streamedResponse.statusCode == 200) {
        final decoded = json.decode(responseBody);
        Navigator.pop(context);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              result: Map<String, dynamic>.from(decoded ?? {}),
            ),
          ),
        );
      } else {
        Navigator.pop(context);
      }
    } catch (_) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Stack(
        children: [
          /// BACKGROUND IMAGE
            Positioned.fill(
              child: Image.asset(
                "assets/images/galaxy_bg.png",
                fit: BoxFit.cover,
              ),
            ),

            /// DARK OVERLAY (for readability)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.65),
              ),
            ),

          /// MAIN CONTENT
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  /// TITLE
                  const Text(
                    "Upload Your Car Lease for Smart Analysis",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "Upload your lease agreement PDF for an AI-powered review and analysis.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// UPLOAD CARD
                  GestureDetector(
                    onTap: _pickPdf,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 36),
                      decoration: BoxDecoration(
                        color: const Color(0xFF020617),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white24,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.cloud_upload_outlined,
                            color: Color(0xFF60A5FA),
                            size: 60,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Drag & Drop or Select File",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _pickPdf,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE11D48),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 28, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              "Browse Files",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (fileName != null) ...[
                            const SizedBox(height: 14),
                            Text(
                              fileName!,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ]
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// FEATURES ROW
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 28,
                    runSpacing: 24,
                    children: const [
                      _FeatureItem(
                        icon: Icons.search,
                        title: "Deep Lease Analysis",
                        subtitle:
                            "Detect hidden fees and unfair clauses",
                      ),
                      _FeatureItem(
                        icon: Icons.smart_toy,
                        title: "AI Negotiation",
                        subtitle:
                            "Dealer & customer role-play negotiation",
                      ),
                      _FeatureItem(
                        icon: Icons.history,
                        title: "Car History Check",
                        subtitle:
                            "Accident, insurance & ownership insights",
                      ),
                      _FeatureItem(
                        icon: Icons.warning_amber,
                        title: "Risk Alerts",
                        subtitle:
                            "Identify legally risky terms",
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  if (pdfBytes != null)
                    SizedBox(
                      width: 280,
                      child: ElevatedButton(
                        onPressed: _sendPdfToBackend,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE11D48),
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "Analyze Lease with AI",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// FEATURE ITEM WIDGET
class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

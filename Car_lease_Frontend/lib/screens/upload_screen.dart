import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';
import 'car_history_test.dart';
import 'result_screen.dart';
import '../services/upload_service.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  Uint8List? fileBytes;
  String? fileName;

  bool loading = false;
  String? message;

  final uploadService = UploadService();

  // 🔹 Pick PDF file (Web-safe)
  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        fileBytes = result.files.single.bytes;
        fileName = result.files.single.name;
        message = null;
      });
    }
  }

  // 🔹 Upload and navigate to ResultScreen
  Future<void> uploadAndAnalyze() async {
    if (fileBytes == null || fileName == null) {
      setState(() {
        message = "Please select a PDF file first.";
      });
      return;
    }

    setState(() {
      loading = true;
      message = null;
    });

    try {
      final response = await uploadService.uploadLeaseBytes(
        fileBytes!,
        fileName!,
      );

      print("UPLOAD RESPONSE: $response");

      if (!mounted) return;

      // 🔹 Navigate to your existing ResultScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(result: response),
        ),
      );

    } catch (e) {
      setState(() {
        message = "Upload failed: $e";
      });
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  // 🔹 Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("access_token");

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Car Lease Analyzer"),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              const Text(
                "Upload Lease Document",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Pick File Button
              ElevatedButton.icon(
                onPressed: pickFile,
                icon: const Icon(Icons.attach_file),
                label: const Text("Select PDF File"),
              ),

              const SizedBox(height: 12),

              // Show selected file name
              if (fileName != null)
                Text(
                  "Selected: $fileName",
                  textAlign: TextAlign.center,
                ),

              const SizedBox(height: 20),

              // Upload Button
              ElevatedButton.icon(
                onPressed: loading ? null : uploadAndAnalyze,
                icon: const Icon(Icons.cloud_upload),
                label: const Text("Upload & Analyze"),
              ),

              const SizedBox(height: 24),

              // Car History Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CarHistoryTestScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.directions_car),
                label: const Text("Car History"),
              ),

              const SizedBox(height: 24),

              if (loading)
                const Center(child: CircularProgressIndicator()),

              const SizedBox(height: 12),

              if (message != null)
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: message!.toLowerCase().contains("failed")
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

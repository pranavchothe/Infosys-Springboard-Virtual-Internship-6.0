import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/upload_service.dart';
import 'processing_screen.dart';
import 'result_screen.dart';
import 'login_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  Uint8List? fileBytes;
  String? fileName;

  bool loading = false;
  String? message;

  final uploadService = UploadService();

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

  Future<void> uploadAndAnalyze() async {
    if (fileBytes == null) {
      setState(() => message = "Please select a PDF file first.");
      return;
    }

    setState(() {
      loading = true;
      message = null;
    });

    final proceed = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProcessingScreen()),
    );

    if (proceed != true) {
      setState(() => loading = false);
      return;
    }

    final response = await uploadService.uploadLeaseBytes(
      fileBytes!,
      fileName!,
    );

    if (!mounted) return;

    final recordId = response?["record_id"] ?? response?["id"];

    if (recordId == null) {
      setState(() {
        loading = false;
        message = "Analysis completed but record could not be loaded.";
      });
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          result: response!,
          recordId: recordId,
        ),
      ),
    );

    setState(() => loading = false);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("access_token");

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Lease"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.upload_file, size: 64),
                  const SizedBox(height: 16),

                  Text(
                    "Upload Lease Document",
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),

                  Text(
                    "Securely upload your car lease PDF for AI analysis",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 24),

                  OutlinedButton.icon(
                    onPressed: pickFile,
                    icon: const Icon(Icons.attach_file),
                    label: const Text("Select PDF File"),
                  ),

                  if (fileName != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      fileName!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: loading ? null : uploadAndAnalyze,
                      icon: const Icon(Icons.analytics),
                      label: const Text("Analyze Lease"),
                    ),
                  ),

                  if (loading) ...[
                    const SizedBox(height: 16),
                    const CircularProgressIndicator(),
                  ],

                  if (message != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      message!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

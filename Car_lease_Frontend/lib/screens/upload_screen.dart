import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';
import 'history_screen.dart';
import 'result_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  Uint8List? fileBytes;
  String? fileName;
  bool loading = false;
  String status = "";

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'txt'],
    );

    if (result != null) {
      setState(() {
        fileBytes = result.files.single.bytes;
        fileName = result.files.single.name;
        status = "Selected: $fileName";
      });
    }
  }

  void _uploadFile() async {
    if (fileBytes == null || fileName == null) {
      setState(() => status = "Please select a file first.");
      return;
    }

    setState(() {
      loading = true;
      status = "Analyzing your lease...";
    });

    final result =
        await ApiService().uploadBytes(fileBytes!, fileName!);

    setState(() => loading = false);

    if (result != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(result: result),
        ),
      );
    } else {
      setState(() => status = "Upload failed.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Car Lease Analyzer"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Upload your lease document",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "We’ll extract key terms and negotiation tips.",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.folder_open),
                      label: const Text("Pick File"),
                      onPressed: _pickFile,
                    ),
                    const SizedBox(height: 12),
                    if (fileName != null)
                      Text(
                        fileName!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.analytics),
                label: loading
                    ? const Text("Analyzing...")
                    : const Text("Analyze Lease"),
                onPressed: loading ? null : _uploadFile,
              ),
            ),

            const SizedBox(height: 16),
            Text(status, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

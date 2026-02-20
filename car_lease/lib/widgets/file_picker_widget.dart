import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FilePickerWidget extends StatelessWidget {
  final ValueChanged<String> onFileSelected;

  const FilePickerWidget({
    super.key,
    required this.onFileSelected,
  });

  Future<void> pickFile() async {
    final FilePickerResult? result =
        await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null) return;

    final file = result.files.single;

    if (file.path != null) {
      onFileSelected(file.path!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: pickFile,
      icon: const Icon(Icons.upload_file),
      label: const Text("Select Lease PDF"),
    );
  }
}

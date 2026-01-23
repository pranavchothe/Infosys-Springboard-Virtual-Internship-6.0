import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Analysis History")),
      body: FutureBuilder<List<dynamic>>(
        future: ApiService().getHistory(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final history = snapshot.data!;

          if (history.isEmpty) {
            return const Center(
              child: Text("No previous analyses"),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];

              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: const Icon(Icons.description,
                      color: Colors.indigo),
                  title: Text(item["filename"] ?? ""),
                  subtitle: const Text("Tap to view details"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

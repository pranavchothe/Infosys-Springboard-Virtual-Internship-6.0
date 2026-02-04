import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'car_history_screen.dart';

class UploadHistoryScreen extends StatefulWidget {
  const UploadHistoryScreen({super.key});

  @override
  State<UploadHistoryScreen> createState() => _UploadHistoryScreenState();
}

class _UploadHistoryScreenState extends State<UploadHistoryScreen> {
  final ApiService apiService = ApiService();
  bool loading = true;
  List<dynamic> history = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  // ================= LOAD HISTORY =================
  Future<void> loadHistory() async {
    try {
      final data = await apiService.getHistory();

      if (!mounted) return;

      setState(() {
        history = data;
        loading = false;
      });

      // Auto-refresh if processing is still ongoing
      final hasProcessing = data.any(
        (item) => item["car_full_history"] == null,
      );

      if (hasProcessing) {
        Future.delayed(const Duration(seconds: 5), loadHistory);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Uploaded Leases")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : history.isEmpty
              ? _emptyState(theme)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final record = history[index];
                    final carHistory = record["car_full_history"];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(Icons.description),
                        title: Text(
                          record["filename"] ?? "Unknown file",
                          style: theme.textTheme.bodyLarge,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text("VIN: ${record["vin"] ?? "-"}"),
                            Text("Uploaded: ${record["created_at"] ?? "-"}"),
                            if (carHistory == null)
                              const Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Text(
                                  "Car history processing…",
                                  style: TextStyle(
                                    color: Colors.orangeAccent,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: carHistory == null
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CarHistoryScreen(
                                    vin: record["vin"],
                                    carHistory: carHistory,
                                  ),
                                  ),
                                );
                              },
                      ),
                    );
                  },
                ),
    );
  }

  Widget _emptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history, size: 64),
          const SizedBox(height: 16),
          Text(
            "No uploads yet",
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            "Upload a lease to see history here",
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

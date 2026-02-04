import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  final int? recordId; // ✅ OPTIONAL

  const HistoryScreen({super.key, this.recordId});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List historyList = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    final api = ApiService();
    final data = await api.getHistory();

    setState(() {
      // ✅ If recordId exists → show ONLY that car
      // ✅ Else → show ALL uploads
      historyList = widget.recordId == null
          ? data
          : data
              .where((item) => item["id"] == widget.recordId)
              .toList();

      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSingleCarView = widget.recordId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isSingleCarView ? "This Car’s History" : "Upload History",
        ),
      ),
      body: loading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.primaryColor,
              ),
            )
          : historyList.isEmpty
              ? _emptyState(theme)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: historyList.length,
                  itemBuilder: (context, index) {
                    final item = historyList[index];

                    final status =
                        (item['status'] ?? 'processed').toString();
                    final vin = item['vin'] ?? 'Unknown VIN';
                    final createdAt = item['created_at'] ?? '';

                    return _historyCard(
                      context: context,
                      vin: vin,
                      date: createdAt,
                      status: status,
                    );
                  },
                ),
    );
  }

  // ================= HISTORY CARD =================
  Widget _historyCard({
    required BuildContext context,
    required String vin,
    required String date,
    required String status,
  }) {
    final theme = Theme.of(context);
    final statusColor = _statusColor(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: ListTile(
        leading: const Icon(Icons.directions_car),
        title: Text(
          vin,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          "Uploaded: $date",
          style: theme.textTheme.bodyMedium,
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status.toUpperCase(),
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  // ================= STATUS COLOR =================
  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'risk':
      case 'warning':
        return Colors.orangeAccent;
      case 'failed':
        return Colors.redAccent;
      default:
        return Colors.greenAccent;
    }
  }

  // ================= EMPTY STATE =================
  Widget _emptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history, size: 60),
          const SizedBox(height: 16),
          Text(
            "No history yet",
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            "Upload a lease to see analysis history here",
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

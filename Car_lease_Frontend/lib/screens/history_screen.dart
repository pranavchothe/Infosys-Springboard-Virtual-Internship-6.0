import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/analysis_result.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  HistoryScreenState createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen> {
  final ApiService apiService = ApiService();

  List<AnalysisResult> historyList = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  // PUBLIC REFRESH METHOD
  Future<void> refresh() async {
    if (!mounted) return;
    setState(() => loading = true);
    await fetchHistory();
  }

  Future<void> fetchHistory() async {
    try {
      final data = await apiService.getHistory();
      if (!mounted) return;

      setState(() {
        historyList = data;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        /// BACKGROUND IMAGE
        Positioned.fill(
          child: Image.asset(
            "assets/images/galaxy_bg.png",
            fit: BoxFit.cover,
          ),
        ),

        /// DARK OVERLAY
        Positioned.fill(
          child: Container(color: Colors.black.withOpacity(0.65)),
        ),

        SafeArea(
          child: historyList.isEmpty
              ? _emptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: historyList.length,
                  itemBuilder: (context, index) {
                    final item = historyList[index];

                    final Color statusColor =
                        item.status.toLowerCase().contains("clean")
                            ? Colors.greenAccent
                            : item.status.toLowerCase().contains("minor")
                                ? Colors.orangeAccent
                                : Colors.redAccent;

                    return _glass(
                      child: Row(
                        children: [
                          /// ICON
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.directions_car,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(width: 14),

                          /// VIN + DATE
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.vin,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Uploaded: ${item.createdAt.toLocal().toString().split(' ')[0]}",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// STATUS PILL
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              item.status.toUpperCase(),
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  /// EMPTY STATE
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.history, size: 60, color: Colors.white70),
          SizedBox(height: 16),
          Text(
            "No history yet",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Upload a lease to see analysis history here",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  /// GLASS CONTAINER
  Widget _glass({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: child,
    );
  }
}

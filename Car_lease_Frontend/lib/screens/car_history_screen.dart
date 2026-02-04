import 'package:flutter/material.dart';

class CarHistoryScreen extends StatelessWidget {
  final String vin;
  final dynamic carHistory;

  const CarHistoryScreen({
    super.key,
    required this.vin,
    required this.carHistory,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Car History"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // ================= VIN CARD =================
            Card(
              child: ListTile(
                leading: const Icon(Icons.confirmation_number),
                title: const Text("Vehicle VIN"),
                subtitle: Text(vin),
              ),
            ),

            const SizedBox(height: 16),

            // ================= HISTORY CONTENT =================
            if (carHistory is Map && carHistory.isNotEmpty)
              ...carHistory.entries.map<Widget>((entry) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(
                      entry.key.toString(),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      entry.value.toString(),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                );
              }).toList()
            else
              Center(
                child: Text(
                  "No car history available",
                  style: theme.textTheme.bodyMedium,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

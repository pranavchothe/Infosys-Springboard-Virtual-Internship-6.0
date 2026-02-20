import 'package:flutter/material.dart';
import '../models/analysis_result.dart';

class LeaseComparisonScreen extends StatelessWidget {
  final List<AnalysisResult> leases;

  const LeaseComparisonScreen({
    super.key,
    required this.leases,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text("Lease Comparison"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _row("VIN", (l) => l.vin),
            _row("Status", (l) => l.status),
            _row("Monthly Payment", (l) => "₹${l.monthlyPayment}"),
            _row("Fairness Score", (l) => "${l.fairnessScore}%"),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String Function(AnalysisResult) getter) {
    return Card(
      color: Colors.white.withOpacity(0.08),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(
              width: 120,
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...leases.map(
              (l) => Expanded(
                child: Text(
                  getter(l),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

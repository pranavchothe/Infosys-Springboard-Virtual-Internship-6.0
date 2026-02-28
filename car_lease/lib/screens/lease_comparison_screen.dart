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

     if (leases.isNotEmpty) {
        print("DEBUG ANALYSIS DATA:");
        print(leases.first.analysisData);
      }
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

          _sectionTitle("Basic Info"),
          _row("VIN", (l) => l.vin),
          _row("Vehicle", (l) => "${l.maker} ${l.modelName} (${l.vehicleYear})"),
          _row("Status", (l) => l.status),

          _sectionTitle("Financial Comparison"),
          _row("Base Monthly", (l) => l.baseMonthly),
          _row("Total Monthly", (l) => l.totalMonthly),
          _row("Total Payments", (l) => l.totalPayments),
          _row("Residual Value", (l) => l.residualValue),
          _row("Purchase Option", (l) => l.purchaseOption),

          _sectionTitle("Lease Terms"),
          _row("Lease Duration", (l) => l.leaseDuration),
          _row("Payment Terms", (l) => l.paymentTerms),

          _sectionTitle("Risk & Fairness"),
          _row("Fairness Score", (l) => "${l.fairnessScore ?? 0}%"),
          _row("Red Flags", (l) => l.redFlagCount.toString()),
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

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
}

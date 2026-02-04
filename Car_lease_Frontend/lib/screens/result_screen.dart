import 'dart:convert';
import 'package:flutter/material.dart';
import 'history_screen.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;
  final int recordId;

  const ResultScreen({
    super.key,
    required this.result,
    required this.recordId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // ---------- SAFE ANALYSIS PARSE ----------
    Map<String, dynamic> analysis = {};

    final rawAnalysis = result["analysis_result"];

    if (rawAnalysis is String) {
      try {
        analysis = jsonDecode(rawAnalysis);
      } catch (_) {
        analysis = {};
      }
    } else if (rawAnalysis is Map) {
      analysis = Map<String, dynamic>.from(rawAnalysis);
    }

    final parties = Map<String, dynamic>.from(analysis["parties"] ?? {});
    final lease = Map<String, dynamic>.from(analysis["lease_details"] ?? {});
    final vehicle = Map<String, dynamic>.from(analysis["vehicle_details"] ?? {});
    final financials = Map<String, dynamic>.from(analysis["financials"] ?? {});
    final penalties = Map<String, dynamic>.from(analysis["penalties"] ?? {});

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lease Analysis"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ================= VEHICLE SUMMARY =================
          Card(
            child: ListTile(
              leading: const Icon(Icons.directions_car),
              title: Text(
                vehicle["model"] ?? "Vehicle Details",
                style: theme.textTheme.titleLarge,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (vehicle["maker"] != null)
                    Text("Manufacturer: ${vehicle["maker"]}"),
                  if (vehicle["year"] != null)
                    Text("Year: ${vehicle["year"]}"),
                  if (vehicle["vehicle_id_number"] != null)
                    Text("VIN: ${vehicle["vehicle_id_number"]}"),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          _sectionTitle("Parties", theme),
          _infoCard("Lessor", parties["lessor"]),
          _infoCard("Lessee", parties["lessee"]),

          const SizedBox(height: 16),

          _sectionTitle("Lease Terms", theme),
          _infoCard("Start Date", lease["start_date"]),
          _infoCard("End Date", lease["end_date"]),
          _infoCard("Duration", lease["lease_duration"]),
          _infoCard("Rent Amount", lease["rent_amount"]),
          _infoCard("Payment Terms", lease["payment_terms"]),

          const SizedBox(height: 16),

          _sectionTitle("Financial Overview", theme),
          _infoCard("Base Monthly Payment", financials["base_monthly_payment"]),
          _infoCard("Total Monthly Payment", financials["total_monthly_payment"]),
          _infoCard("Total of Payments", financials["total_of_payments"]),
          _infoCard("Residual Value", financials["residual_value"]),
          _infoCard("Purchase Option Price", financials["purchase_option_price"]),

          const SizedBox(height: 16),

          _sectionTitle("Penalties & Risks", theme),
          _infoCard(
            "Early Termination Charge",
            penalties["early_termination_charge"],
          ),
          _infoCard(
            "Late Payment Fee",
            penalties["late_payment_fee"],
          ),
          _infoCard(
            "Excess Wear Charges",
            penalties["excess_wear_charges"],
          ),

          const SizedBox(height: 30),

          // ================= CTA =================
          ElevatedButton.icon(
            icon: const Icon(Icons.history),
            label: const Text("View This Car’s History"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HistoryScreen(recordId: recordId),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ================= SECTION TITLE =================
  Widget _sectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: theme.textTheme.titleLarge,
      ),
    );
  }

  // ================= INFO CARD =================
  Widget _infoCard(String label, dynamic value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(label),
        subtitle: Text(
          value != null && value.toString().isNotEmpty
              ? value.toString()
              : "Not available",
        ),
      ),
    );
  }
}

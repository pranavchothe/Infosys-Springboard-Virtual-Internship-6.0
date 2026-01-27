import 'dart:convert';
import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;

  const ResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    // 🔹 Force-convert main analysis map safely
    Map<String, dynamic> analysis = {};

    final rawAnalysis = result["analysis_result"];

    if (rawAnalysis is String) {
      // It is JSON text → decode
      try {
        analysis = jsonDecode(rawAnalysis);
      } catch (e) {
        analysis = {};
      }
    } else if (rawAnalysis is Map) {
      // It is already a Map → convert
      analysis = Map<String, dynamic>.from(rawAnalysis);
    } else {
      analysis = {};
    }

    // 🔹 Safely extract nested maps
    final Map<String, dynamic> parties =
        (analysis["parties"] is Map)
            ? Map<String, dynamic>.from(analysis["parties"])
            : {};

    final Map<String, dynamic> leaseDetails =
        (analysis["lease_details"] is Map)
            ? Map<String, dynamic>.from(analysis["lease_details"])
            : {};

    final Map<String, dynamic> vehicle =
        (analysis["vehicle_details"] is Map)
            ? Map<String, dynamic>.from(analysis["vehicle_details"])
            : {};

    final Map<String, dynamic> financials =
        (analysis["financials"] is Map)
            ? Map<String, dynamic>.from(analysis["financials"])
            : {};

    final Map<String, dynamic> penalties =
        (analysis["penalties"] is Map)
            ? Map<String, dynamic>.from(analysis["penalties"])
            : {};

    // 👤 Parties
    final lessor = parties["lessor"];
    final lessee = parties["lessee"];

    // 📄 Lease Details
    final startDate = leaseDetails["start_date"];
    final endDate = leaseDetails["end_date"];
    final leaseDuration = leaseDetails["lease_duration"];
    final rentAmount = leaseDetails["rent_amount"];
    final paymentTerms = leaseDetails["payment_terms"];

    // 🚗 Vehicle Details
    final maker = vehicle["maker"];
    final model = vehicle["model"];
    final year = vehicle["year"];
    final bodyStyle = vehicle["body_style"];
    final color = vehicle["color"];
    final vin = vehicle["vehicle_id_number"];
    final registration = vehicle["registration_number"];

    // 💰 Financials
    final baseMonthly = financials["base_monthly_payment"];
    final totalMonthly = financials["total_monthly_payment"];
    final totalOfPayments = financials["total_of_payments"];
    final residualValue = financials["residual_value"];
    final purchaseOption = financials["purchase_option_price"];

    // ⚠️ Penalties
    final earlyTermination = penalties["early_termination_charge"];
    final lateFee = penalties["late_payment_fee"];
    final excessWear = penalties["excess_wear_charges"];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lease Analysis"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [

            // 🔹 General Info (Top Summary)
            if (vin != null)
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: const Icon(Icons.confirmation_number, color: Colors.indigo),
                  title: const Text(
                    "Vehicle VIN",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(vin.toString()),
                ),
              ),

            // 👤 Parties
            _sectionTitle("Parties"),
            _infoCard(Icons.person, "Lessor", lessor),
            _infoCard(Icons.person_outline, "Lessee", lessee),

            // 📄 Lease Details
            _sectionTitle("Lease Details"),
            _infoCard(Icons.date_range, "Start Date", startDate),
            _infoCard(Icons.event, "End Date", endDate),
            _infoCard(Icons.timelapse, "Lease Duration", leaseDuration),
            _infoCard(Icons.attach_money, "Rent Amount", rentAmount),
            _infoCard(Icons.schedule, "Payment Terms", paymentTerms),

            // 🚗 Vehicle Details
            _sectionTitle("Vehicle Details"),
            _infoCard(Icons.directions_car, "Maker", maker),
            _infoCard(Icons.directions_car_filled, "Model", model),
            _infoCard(Icons.calendar_today, "Year", year),
            _infoCard(Icons.car_rental, "Body Style", bodyStyle),
            _infoCard(Icons.color_lens, "Color", color),
            _infoCard(Icons.app_registration, "Registration Number", registration),

            // 💰 Financials
            _sectionTitle("Financials"),
            _infoCard(Icons.payments, "Base Monthly Payment", baseMonthly),
            _infoCard(Icons.payments_outlined, "Total Monthly Payment", totalMonthly),
            _infoCard(Icons.summarize, "Total of Payments", totalOfPayments),
            _infoCard(Icons.savings, "Residual Value", residualValue),
            _infoCard(Icons.shopping_cart, "Purchase Option Price", purchaseOption),

            // ⚠️ Penalties
            _sectionTitle("Penalties"),
            _infoCard(Icons.warning, "Early Termination Charge", earlyTermination),
            _infoCard(Icons.money_off, "Late Payment Fee", lateFee),
            _infoCard(Icons.build, "Excess Wear Charges", excessWear),
          ],
        ),
      ),
    );
  }

  // 🔹 Section Title Widget
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.indigo,
        ),
      ),
    );
  }

  // 🔹 Info Card Widget (null-safe, production-safe)
  Widget _infoCard(IconData icon, String title, dynamic value) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.indigo),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          value != null && value.toString().trim().isNotEmpty
              ? value.toString()
              : "Not available",
          style: const TextStyle(color: Colors.black87),
        ),
      ),
    );
  }
}

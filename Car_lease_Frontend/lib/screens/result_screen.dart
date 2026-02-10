import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'home_screen.dart';
import '../services/auth_service.dart';
import 'car_history_screen.dart';
import '../widgets/ai_chatbot.dart';



class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;

  const ResultScreen({super.key, required this.result});

  String _safeString(dynamic value) {
    if (value == null) return "Not available";
    if (value is String && value.trim().isEmpty) return "Not available";
    return value.toString();
  }

  /// Generate a PDF report
  Future<void> _printPdf(BuildContext context) async {
    final pdf = pw.Document();

    final lease =
        Map<String, dynamic>.from(result["analysis_result"] ?? {});
    final leaseDetails =
        Map<String, dynamic>.from(lease["lease_details"] ?? {});
    final vehicle =
        Map<String, dynamic>.from(lease["vehicle_details"] ?? {});
    final financials =
        Map<String, dynamic>.from(lease["financials"] ?? {});
    final penalties =
        Map<String, dynamic>.from(lease["penalties"] ?? {});
    final fairness =
        Map<String, dynamic>.from(result["fairness_analysis"] ?? {});

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text(
            "Lease Analysis Report",
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 16),

          _pdfSection("Fairness Score", [
            "Score: ${fairness["fairness_score"] ?? "N/A"}",
            "Verdict: ${fairness["classification"] ?? "N/A"}",
          ]),

          _pdfSection("Parties", [
            "Lessor: ${lease["parties"]?["lessor"] ?? "N/A"}",
            "Lessee: ${lease["parties"]?["lessee"] ?? "N/A"}",
          ]),

          _pdfSection("Lease Details", [
            "Start Date: ${leaseDetails["start_date"] ?? "N/A"}",
            "End Date: ${leaseDetails["end_date"] ?? "N/A"}",
            "Duration: ${leaseDetails["lease_duration"] ?? "N/A"}",
            "Payment Terms: ${leaseDetails["payment_terms"] ?? "N/A"}",
          ]),

          _pdfSection("Vehicle Details", [
            "Maker: ${vehicle["maker"] ?? vehicle["make"] ?? "N/A"}",
            "Model: ${vehicle["model"] ?? "N/A"}",
            "Year: ${vehicle["year"] ?? "N/A"}",
            "VIN: ${vehicle["vehicle_id_number"] ?? "N/A"}",
          ]),

          _pdfSection("Financials", [
            "Base Monthly: ${financials["base_monthly_payment"] ?? "N/A"}",
            "Total Monthly: ${financials["total_monthly_payment"] ?? "N/A"}",
            "Total Payments: ${financials["total_of_payments"] ?? "N/A"}",
            "Residual Value: ${financials["residual_value"] ?? "N/A"}",
          ]),

          _pdfSection("Penalties", [
            "Early Termination: ${penalties["early_termination_charge"] ?? "N/A"}",
            "Late Fee: ${penalties["late_payment_fee"] ?? "N/A"}",
            "Excess Wear: ${penalties["excess_wear_charges"] ?? "N/A"}",
          ]),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  pw.Widget _pdfSection(String title, List<String> lines) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 14),
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 6),
        ...lines.map(
          (line) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Text(line),
          ),
        ),
      ],
    );
  }



  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> lease =
        Map<String, dynamic>.from(result["analysis_result"] ?? {});
    final Map<String, dynamic> leaseDetails =
        Map<String, dynamic>.from(lease["lease_details"] ?? {});
    final Map<String, dynamic> vehicle =
        Map<String, dynamic>.from(lease["vehicle_details"] ?? {});
    final Map<String, dynamic> financials =
        Map<String, dynamic>.from(lease["financials"] ?? {});
    final Map<String, dynamic> penalties =
        Map<String, dynamic>.from(lease["penalties"] ?? {});

    final Map<String, dynamic> fairness =
        Map<String, dynamic>.from(result["fairness_analysis"] ?? {});
    final double fairnessScore =
        fairness["fairness_score"] != null
            ? (fairness["fairness_score"] as num).toDouble()
            : 0;

    final String fairnessVerdict =
        fairness["classification"]?.toString() ?? "Unknown";

    final parties = lease["parties"] ?? {};
    final lessor = _safeString(parties["lessor"]);
    final lessee = _safeString(parties["lessee"]);

    final maker = _safeString(
      vehicle["make"] ??
          vehicle["maker"] ??
          vehicle["manufacturer"] ??
          vehicle["brand"],
    );

    return Scaffold(
      body: Stack(
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
            child: Container(
              color: Colors.black.withOpacity(0.65),
            ),
          ),

          /// MAIN CONTENT
          SafeArea(
            child: Column(
              children: [

                /// APP BAR
                _topBar(context),

                Expanded(
                  child: Stack(
                    children: [

                      SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            _fairnessGauge(
                              score: fairnessScore,
                              verdict: fairnessVerdict,
                            ),

                            _section("Parties"),
                            _glassTile(Icons.business, "Lessor", lessor),
                            _glassTile(Icons.person, "Lessee", lessee),

                            _section("Lease Details"),
                            _glassTile(Icons.calendar_today, "Start Date",
                                leaseDetails["start_date"]),
                            _glassTile(Icons.event, "End Date",
                                leaseDetails["end_date"]),
                            _glassTile(Icons.timelapse, "Lease Duration",
                                leaseDetails["lease_duration"]),
                            _glassTile(Icons.currency_rupee, "Rent Amount",
                                financials["base_monthly_payment"]?.toString()),
                            _glassTile(Icons.schedule, "Payment Terms",
                                leaseDetails["payment_terms"]),

                            _section("Vehicle Details"),
                            _glassTile(Icons.directions_car, "Maker", maker),
                            _glassTile(Icons.car_rental, "Model",
                                vehicle["model"]),
                            _glassTile(Icons.calendar_view_month, "Year",
                                vehicle["year"]?.toString()),
                            _glassTile(Icons.format_paint, "Body Style",
                                vehicle["body_style"]),
                            _glassTile(Icons.color_lens, "Color",
                                vehicle["color"]),
                            _glassTile(Icons.confirmation_number, "VIN",
                                vehicle["vehicle_id_number"]),
                            _glassTile(Icons.badge, "Registration Number",
                                vehicle["registration_number"]),

                            _section("Financials"),
                            _glassTile(Icons.payments,
                                "Base Monthly Payment",
                                financials["base_monthly_payment"]?.toString()),
                            _glassTile(Icons.money,
                                "Total Monthly Payment",
                                financials["total_monthly_payment"]?.toString()),
                            _glassTile(Icons.account_balance_wallet,
                                "Total of Payments",
                                financials["total_of_payments"]?.toString()),
                            _glassTile(Icons.savings, "Residual Value",
                                financials["residual_value"]?.toString()),
                            _glassTile(Icons.shopping_cart,
                                "Purchase Option Price",
                                financials["purchase_option_price"]?.toString()),

                            _section("Penalties"),
                            _glassTile(Icons.warning,
                                "Early Termination Charge",
                                penalties["early_termination_charge"]),
                            _glassTile(Icons.timer_off,
                                "Late Payment Fee",
                                penalties["late_payment_fee"]),
                            _glassTile(Icons.build,
                                "Excess Wear Charges",
                                penalties["excess_wear_charges"]),

                            const SizedBox(height: 24),

                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                                minimumSize:
                                    const Size(double.infinity, 50),
                              ),
                              onPressed: () {
                                final String vin =
                                    vehicle["vehicle_id_number"] ??
                                    vehicle["vin"] ??
                                    "N/A";

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CarHistoryScreen(
                                      vin: vin,
                                    ),
                                  ),
                                );
                              },
                              child: const Text("View Car Full History"),
                            ),

                            const SizedBox(height: 12),

                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                minimumSize:
                                    const Size(double.infinity, 50),
                              ),
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const HomeScreen()),
                                  (route) => false,
                                );
                              },
                              child: const Text("Return to Home"),
                            ),

                            const SizedBox(height: 80),
                          ],
                        ),
                      ),

                      /// AI CHATBOT
                      AIChatBot(
                        recordId: result["record_id"], 
                        analysisResultMap: result["analysis_result"],
                        fairnessAnalysisMap: result["fairness_analysis"],
                        carHistoryMap: result["car_full_history"],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// TOP BAR
Widget _topBar(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    child: Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),

        const Text(
          "Lease Results",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),

        const Spacer(),

        /// PRINT BUTTON (VISIBLE)
        ElevatedButton.icon(
          onPressed: () {
            _printPdf(context);
          },
          icon: const Icon(Icons.print, size: 18),
          label: const Text("Print Report"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.25),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 20, // width
              vertical: 10,   // height
            ),
            minimumSize: const Size(0, 36), 
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),

        const SizedBox(width: 6),

        /// 3-DOT MENU
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          color: const Color(0xFF1E293B),
          onSelected: (value) {
            if (value == "logout") {
              AuthService.logout(context);
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: "logout",
              child: Row(
                children: [
                  Icon(Icons.logout, size: 18),
                  SizedBox(width: 8),
                  Text("Logout"),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

  /// 🔹 FAIRNESS GAUGE (GLASS)
  Widget _fairnessGauge({
    required double score,
    required String verdict,
  }) {
    final Color color =
        score >= 80 ? Colors.greenAccent : Colors.lightGreen;

    return _glassContainer(
      child: Column(
        children: [
          const Text("Fairness Score",
              style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: SfRadialGauge(
              axes: [
                RadialAxis(
                  minimum: 0,
                  maximum: 100,
                  showTicks: false,
                  showLabels: false,
                  axisLineStyle: const AxisLineStyle(
                    thickness: 0.12,
                    thicknessUnit: GaugeSizeUnit.factor,
                    color: Colors.white12,
                  ),
                  pointers: [
                    RangePointer(
                      value: score,
                      width: 0.12,
                      sizeUnit: GaugeSizeUnit.factor,
                      color: color,
                      cornerStyle: CornerStyle.bothCurve,
                    ),
                  ],
                  annotations: [
                    GaugeAnnotation(
                      angle: 90,
                      positionFactor: 0.3,
                      widget: Column(
                        children: [
                          Text("${score.toInt()}",
                              style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: color)),
                          const Text("Score",
                              style: TextStyle(color: Colors.white70)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              verdict,
                              style: TextStyle(color: color),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 GLASS SECTION TITLE
  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// 🔹 GLASS TILE
  Widget _glassTile(IconData icon, String label, String? value) {
    return _glassContainer(
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFDC2626)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(color: Colors.white70)),
          ),
          Text(
            value ?? "Not available",
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  /// 🔹 GLASS CONTAINER
  Widget _glassContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: child,
    );
  }
}

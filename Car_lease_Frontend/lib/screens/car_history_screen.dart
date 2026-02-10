import 'dart:ui';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../services/auth_service.dart';

class CarHistoryScreen extends StatelessWidget {
  final Map<String, dynamic> result;

  const CarHistoryScreen({super.key, required this.result});

  String _computeOverallStatus(Map<String, dynamic> history) {
    final bool accident = history["accident_history"] == true;
    final bool flood = history["flood_damage"] == true;
    final bool stolen = history["stolen_record"] == true;
    final int claims = history["insurance_claims"] ?? 0;

    if (accident || flood || stolen) return "High Risk";
    if (claims > 0) return "Minor Issues";
    return "Clean Record";
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> history =
        Map<String, dynamic>.from(result["car_full_history"] ?? {});
    final Map<String, dynamic> vehicle =
        Map<String, dynamic>.from(result["vehicle_api_data"] ?? {});
    final String vin = result["vin"] ?? "N/A";

    final status = _computeOverallStatus(history);

    Color statusColor = status == "Clean Record"
        ? Colors.greenAccent
        : status == "Minor Issues"
            ? Colors.orangeAccent
            : Colors.redAccent;

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
            child: Container(color: Colors.black.withOpacity(0.65)),
          ),

          SafeArea(
            child: Column(
              children: [
                /// TOP BAR
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon:
                            const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        "Car Full History",
                        style:
                            TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const Spacer(),
//                      ElevatedButton.icon(
//                        onPressed: () {
//                          // TODO: connect PDF print later
//                        },
//                        icon: const Icon(Icons.print, size: 16),
//                        label: const Text("Print Report"),
//                        style: ElevatedButton.styleFrom(
//                          backgroundColor:
//                              Colors.white.withOpacity(0.15),
//                          foregroundColor: Colors.white,
//                          elevation: 0,
//                          shape: RoundedRectangleBorder(
//                            borderRadius: BorderRadius.circular(14),
//                          ),
//                        ),
 //                     ),
                      const SizedBox(width: 6),
                      PopupMenuButton<String>(
                        icon:
                            const Icon(Icons.more_vert, color: Colors.white),
                        onSelected: (value) {
                          if (value == "home") {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const HomeScreen()),
                              (route) => false,
                            );
                          } else if (value == "logout") {
                            AuthService.logout(context);
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                              value: "home", child: Text("Home")),
                          PopupMenuItem(
                              value: "logout", child: Text("Logout")),
                        ],
                      )
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        /// VEHICLE CARD
                        _glass(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${vehicle["make"] ?? ""} ${vehicle["model"] ?? ""}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "VIN: $vin",
                                style: const TextStyle(
                                    color: Colors.white70),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color:
                                      statusColor.withOpacity(0.2),
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                      color: statusColor,
                                      fontWeight:
                                          FontWeight.w600),
                                ),
                              )
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        _historyRow("Owners",
                            history["owners"]?.toString()),
                        _historyRow(
                          "Insurance Claims",
                          history["insurance_claims"] != null
                              ? "${history["insurance_claims"]} claims"
                              : "No claims",
                        ),
                        _historyRow(
                          "Accident History",
                          history["accident_history"] == true
                              ? "Accident reported"
                              : "No accident history",
                        ),
                        _historyRow(
                          "Flood Damage",
                          history["flood_damage"] == true
                              ? "Flood damage reported"
                              : "No flood damage",
                        ),
                        _historyRow(
                          "Stolen Record",
                          history["stolen_record"] == true
                              ? "Reported stolen"
                              : "No stolen record",
                        ),

                        const SizedBox(height: 20),

                        _glass(
                          child: const Text(
                            "Data Source: NHTSA + Mock History (API-Ready)",
                            style: TextStyle(color: Colors.white60),
                          ),
                        ),

                        const SizedBox(height: 28),

                        /// RETURN BUTTON
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const HomeScreen()),
                                (route) => false,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFFDC2626),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              "Return to Home",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// HISTORY ROW
  Widget _historyRow(String title, String? value) {
    return _glass(
      child: Row(
        children: [
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600)),
          ),
          Text(value ?? "Not available",
              style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  /// GLASS CONTAINER
  Widget _glass({required Widget child}) {
    return Container(
      width: double.infinity,
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

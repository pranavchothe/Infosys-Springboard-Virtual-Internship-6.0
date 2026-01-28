import 'package:flutter/material.dart';
import '../services/car_history_service.dart';

class CarHistoryTestScreen extends StatefulWidget {
  @override
  _CarHistoryTestScreenState createState() => _CarHistoryTestScreenState();
}

class _CarHistoryTestScreenState extends State<CarHistoryTestScreen> {
  final TextEditingController vinController = TextEditingController();
  Map<String, dynamic>? result;
  String? error;
  bool loading = false;

  final service = CarHistoryService();

  Future<void> fetchHistory() async {
    setState(() {
      loading = true;
      error = null;
      result = null;
    });

    try {
      final data =
          await service.fetchCarFullHistory(vinController.text.trim());
      setState(() {
        result = data;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Color statusColor(String status) {
    if (status.contains("Clean")) return Colors.green;
    if (status.contains("Damage")) return Colors.orange;
    if (status.contains("Stolen")) return Colors.red;
    return Colors.grey;
  }

  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          Text(value, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Car Full History Test")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: vinController,
              decoration: InputDecoration(
                labelText: "Enter VIN",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: loading ? null : fetchHistory,
              child: Text("Check Car History"),
            ),
            SizedBox(height: 20),

            if (loading) CircularProgressIndicator(),

            if (error != null)
              Text(error!, style: TextStyle(color: Colors.red)),

            if (result != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🚗 Title
                          Text(
                            "${result!['make']} ${result!['model']} (${result!['year']})",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 6),
                          Text("VIN: ${result!['vin']}",
                              style: TextStyle(color: Colors.grey)),

                          SizedBox(height: 12),

                          // ✅ Status Badge
                          Chip(
                            label: Text(
                              result!['status'],
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor:
                                statusColor(result!['status']),
                          ),

                          Divider(height: 30),

                          // 📊 Details
                          infoRow(
                              "Owners", result!['owners'].toString()),
                          infoRow("Insurance Claims",
                              result!['insurance_claims'].toString()),
                          infoRow(
                              "Accident History",
                              result!['accidental'] ? "Yes" : "No"),
                          infoRow(
                              "Flood Damage",
                              result!['flood_damage'] ? "Yes" : "No"),
                          infoRow(
                              "Stolen Record",
                              result!['stolen'] ? "Yes" : "No"),

                          Divider(height: 30),

                          Text(
                            "Data Source",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          SizedBox(height: 4),
                          Text(result!['source'],
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

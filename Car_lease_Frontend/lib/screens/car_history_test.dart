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
      final data = await service.fetchCarFullHistory(vinController.text.trim());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Car Full History Test")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
              Text(
                error!,
                style: TextStyle(color: Colors.red),
              ),
            if (result != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    result.toString(),
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

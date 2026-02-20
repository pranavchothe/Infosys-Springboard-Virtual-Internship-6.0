import 'package:flutter/material.dart';
import '../dealer_services/dealer_lease_service.dart';
import 'dealer_chat_screen.dart';

class DealerLeasesScreen extends StatefulWidget {
  const DealerLeasesScreen({super.key});

  @override
  State<DealerLeasesScreen> createState() =>
      _DealerLeasesScreenState();
}

class _DealerLeasesScreenState
    extends State<DealerLeasesScreen> {

  final DealerLeaseService _service =
      DealerLeaseService();

  List<dynamic> leases = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadLeases();
  }

  Future<void> _loadLeases() async {
    try {
      final data = await _service.getDealerLeases();

      setState(() {
        leases = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text("My Leases"),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.redAccent,
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Text(
          "Error loading leases",
          style: const TextStyle(color: Colors.redAccent),
        ),
      );
    }

    if (leases.isEmpty) {
      return const Center(
        child: Text(
          "No leases found",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.builder(
      itemCount: leases.length,
      itemBuilder: (context, index) {
        final lease = leases[index];

        return Card(
          color: const Color(0xFF1E1E1E),
          margin: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(
              lease["vin"] ?? "Unknown VIN",
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              lease["filename"] ?? "",
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: const Icon(
              Icons.chat,
              color: Colors.redAccent,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DealerChatScreen(
                    leaseId: lease["lease_id"],
                    isDealer: true,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

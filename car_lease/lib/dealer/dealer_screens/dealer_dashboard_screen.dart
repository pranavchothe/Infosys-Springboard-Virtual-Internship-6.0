import 'package:flutter/material.dart';
import '../dealer_screens/dealer_chat_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DealerDashboardScreen extends StatefulWidget {
  const DealerDashboardScreen({super.key});

  @override
  State<DealerDashboardScreen> createState() =>
      _DealerDashboardScreenState();
}
class _DealerDashboardScreenState
  extends State<DealerDashboardScreen> {

    List<dynamic> dashboardLeases = [];
    bool loading = true;
  
  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("dealer_token");

    final response = await http.get(
      Uri.parse("http://127.0.0.1:8000/dealer/dashboard"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        dashboardLeases = jsonDecode(response.body);
        loading = false;
      });
    } else {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// BACKGROUND
          Positioned.fill(
            child: Image.asset(
              "assets/images/galaxy_bg.png",
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.6),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _header(),
                  const SizedBox(height: 30),

                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// LEFT SIDE (LEADS)
                        Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Leads Overview",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),

                            Expanded(  
                              child: loading
                                  ? const Center(child: CircularProgressIndicator())
                                  : dashboardLeases.isEmpty
                                      ? const Center(
                                          child: Text(
                                            "No Active Chats",
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        )
                                      : ListView.builder(
                                          itemCount: dashboardLeases.length,
                                          itemBuilder: (context, index) {
                                            final chat = dashboardLeases[index];

                                            return ListTile(
                                              leading: const CircleAvatar(
                                                backgroundColor: Colors.grey,
                                                child: Icon(Icons.person, color: Colors.white),
                                              ),
                                              title: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    chat["customer_name"] ?? "Customer",
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    "VIN: ${chat["vin"] ?? ""}",
                                                    style: const TextStyle(
                                                      color: Colors.white54,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              subtitle: Text(
                                                chat["last_message"] ?? "",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(color: Colors.white70),
                                              ),
                                              trailing: chat["unread"] > 0
                                                  ? CircleAvatar(
                                                      radius: 12,
                                                      backgroundColor: Colors.green,
                                                      child: Text(
                                                        chat["unread"].toString(),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    )
                                                  : null,
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => DealerChatScreen(
                                                      leaseId: chat["lease_id"],
                                                      isDealer: true,
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        )
                  ),
                                    ],
                                  ),
                                ),

                        const SizedBox(width: 30),

                        /// RIGHT SIDE (CHAT PANEL)
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Chat",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 20),

                              dashboardLeases.isNotEmpty
                              ? _chatPreviewCard(dashboardLeases.first)
                              : const SizedBox(),


                              const Spacer(),
                              const Text(
                                "Powered by CarLeaseAI",
                                style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12),
                              ),  
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// HEADER
 Widget _header() {
  return const Row(
    children: [
      Icon(Icons.dashboard, color: Colors.white, size: 26),
      SizedBox(width: 10),
      Text(
        "Dealer Home",
        style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold),
      ),
      Spacer(),
      Stack(
        children: [
          Icon(Icons.notifications, color: Colors.white70),
          Positioned(
            right: 0,
            child: CircleAvatar(
              radius: 6,
              backgroundColor: Colors.red,
            ),
          ),
        ],
      )
    ],
  );
}


  /// LEAD CARD
  Widget _leadCard(
    BuildContext context, {
    required String name,
    required String company,
    required int score,
    required String risk,
    required Color riskColor,
    required int leaseId,
  }){
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: _glassDecoration(),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 26,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  company,
                  style: const TextStyle(
                      color: Colors.white70),
                ),
                const SizedBox(height: 6),
                Text(
                  "Lead Score: $score",
                  style: const TextStyle(
                      color: Colors.white54),
                ),
              ],
            ),
          ),
          Column(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      riskColor.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DealerChatScreen(
                        leaseId: leaseId,
                        isDealer: true,
                      ),
                    ),
                  );
                },
                child: const Text("Chat"),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: riskColor.withOpacity(0.2),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Text(
                  risk,
                  style: TextStyle(
                      color: riskColor,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  /// CHAT PREVIEW CARD
  Widget _chatPreviewCard(Map<String, dynamic> chat) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _glassDecoration(),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 35,
            backgroundImage: AssetImage("assets/images/avatar.png"),
          ),
          const SizedBox(height: 15),
          Text(
            chat["customer_name"] ?? "Customer",
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          Text(
            "VIN: ${chat["vin"] ?? ""}",
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DealerChatScreen(
                      leaseId: chat["lease_id"],
                      isDealer: true,
                    ),
                  ),
                );
              },
              child: const Text("Open Chat"),
            ),
          )
        ],
      ),
    );
  }

  

  /// GLASS EFFECT
  BoxDecoration _glassDecoration() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.08),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white12),
    );
  }
}

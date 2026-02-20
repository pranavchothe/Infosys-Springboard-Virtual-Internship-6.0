import 'package:flutter/material.dart';
import 'upload_screen.dart';
import '../services/auth_service.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1220),
        elevation: 0,
        title: const Text("Car Lease AI"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: "Profile",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
              );
            },
          ),

          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "logout") {
                AuthService.logout(context);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: "logout", child: Text("Logout")),
            ],
          ),
        ],

      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            /// ================= HERO SECTION =================
            Stack(
              children: [
                SizedBox(
                  height: 420,
                  width: double.infinity,
                  child: Image.asset(
                    "assets/images/hero_car.jpg",
                    fit: BoxFit.cover,
                  ),
                ),

                Container(
                  height: 420,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.45),
                        Colors.black.withOpacity(0.85),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 60,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Drive Your Dream Car for Less",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Upload your lease, uncover hidden fees,\nand negotiate smarter using AI.",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: 260,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const UploadScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE11D48),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "Upload Lease PDF",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            /// ================= WHY SECTION =================
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Why Car Lease AI?",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _feature(Icons.search, "Deep Lease Analysis",
                      "Detect hidden fees and unfair clauses"),
                  _feature(Icons.smart_toy, "AI Negotiation",
                      "Dealer & customer role-play negotiation"),
                  _feature(Icons.directions_car, "Car History Check",
                      "Accident, insurance & ownership insights"),
                  _feature(Icons.warning_amber, "Risk Alerts",
                      "Identify legally risky terms"),
                ],
              ),
            ),

            /// ================= HOW IT WORKS =================
            Container(
              width: double.infinity,
              color: const Color(0xFF020617),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: const [
                  Text(
                    "How It Works",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),

                  _Step(number: "1", title: "Upload Lease", desc: "Upload your lease PDF"),
                  _Step(number: "2", title: "AI Analysis", desc: "We analyze fairness & risks"),
                  _Step(number: "3", title: "Negotiate", desc: "Negotiate smarter with AI"),
                ],
              ),
            ),

            /// ================= FOOTER CTA =================
            Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Text(
                    "Get Started Today",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Find your perfect lease deal now.",
                    style: TextStyle(color: Colors.white60),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UploadScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE11D48),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 36, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text("GET YOUR QUOTE"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= FEATURE TILE =================
  static Widget _feature(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white12,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              Text(subtitle,
                  style: const TextStyle(color: Colors.white60)),
            ],
          ),
        ],
      ),
    );
  }
}

/// ================= STEP WIDGET =================
class _Step extends StatelessWidget {
  final String number;
  final String title;
  final String desc;

  const _Step({
    required this.number,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF6366F1),
            child: Text(number,
                style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              Text(desc,
                  style: const TextStyle(color: Colors.white60)),
            ],
          )
        ],
      ),
    );
  }
}

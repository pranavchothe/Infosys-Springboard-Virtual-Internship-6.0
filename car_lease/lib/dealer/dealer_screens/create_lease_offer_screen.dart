import 'dart:ui';
import 'package:flutter/material.dart';

class CreateLeaseOfferScreen extends StatefulWidget {
  const CreateLeaseOfferScreen({super.key});

  @override
  State<CreateLeaseOfferScreen> createState() =>
      _CreateLeaseOfferScreenState();
}

class _CreateLeaseOfferScreenState
    extends State<CreateLeaseOfferScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController vinController =
      TextEditingController();
  final TextEditingController modelController =
      TextEditingController();
  final TextEditingController monthlyController =
      TextEditingController();
  final TextEditingController residualController =
      TextEditingController();
  final TextEditingController downPaymentController =
      TextEditingController();
  final TextEditingController termController =
      TextEditingController();
  final TextEditingController mileageController =
      TextEditingController();

  double fairnessScore = 0;
  bool showResult = false;

  void calculateFairness() {
    double monthly =
        double.tryParse(monthlyController.text) ?? 0;
    double residual =
        double.tryParse(residualController.text) ?? 0;
    double down =
        double.tryParse(downPaymentController.text) ?? 0;

    // 🔥 Mock Fairness Logic
    fairnessScore =
        100 - (monthly / 1000) - (down / 2000) + (residual / 10);

    if (fairnessScore > 100) fairnessScore = 100;
    if (fairnessScore < 0) fairnessScore = 0;

    setState(() {
      showResult = true;
    });
  }

  Color fairnessColor() {
    if (fairnessScore >= 75) return Colors.greenAccent;
    if (fairnessScore >= 50) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          Positioned.fill(
            child: Image.asset(
              "assets/images/galaxy_bg.png",
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child:
                Container(color: Colors.black.withOpacity(0.65)),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    /// HEADER
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.white),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Create Lease Offer",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    _glassField(vinController, "VIN"),
                    _glassField(modelController, "Car Model"),
                    _glassField(monthlyController,
                        "Monthly Payment (₹)",
                        isNumber: true),
                    _glassField(residualController,
                        "Residual Value (%)",
                        isNumber: true),
                    _glassField(downPaymentController,
                        "Down Payment (₹)",
                        isNumber: true),
                    _glassField(termController,
                        "Lease Term (Months)",
                        isNumber: true),
                    _glassField(mileageController,
                        "Mileage Limit (km/year)",
                        isNumber: true),

                    const SizedBox(height: 30),

                    /// GENERATE BUTTON
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.blueAccent,
                        minimumSize:
                            const Size(double.infinity, 55),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!
                            .validate()) {
                          calculateFairness();
                        }
                      },
                      child: const Text(
                        "Generate Offer",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),

                    const SizedBox(height: 30),

                    if (showResult)
                      _glassResult(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassField(TextEditingController controller,
      String label,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter:
              ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 20),
            decoration: BoxDecoration(
              color:
                  Colors.white.withOpacity(0.08),
              borderRadius:
                  BorderRadius.circular(20),
              border:
                  Border.all(color: Colors.white12),
            ),
            child: TextFormField(
              controller: controller,
              style:
                  const TextStyle(color: Colors.white),
              keyboardType: isNumber
                  ? TextInputType.number
                  : TextInputType.text,
              decoration: InputDecoration(
                hintText: label,
                hintStyle: const TextStyle(
                    color: Colors.white54),
                border: InputBorder.none,
              ),
              validator: (value) {
                if (value == null ||
                    value.isEmpty) {
                  return "Required";
                }
                return null;
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _glassResult() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter:
            ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius:
                BorderRadius.circular(20),
            border:
                Border.all(color: Colors.white12),
          ),
          child: Column(
            children: [
              const Text(
                "Fairness Score",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18),
              ),
              const SizedBox(height: 15),
              Text(
                fairnessScore.toStringAsFixed(1),
                style: TextStyle(
                    color: fairnessColor(),
                    fontSize: 40,
                    fontWeight:
                        FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import '../dealer_services/dealer_auth_service.dart';

class DealerRegisterScreen extends StatefulWidget {
  const DealerRegisterScreen({super.key});

  @override
  State<DealerRegisterScreen> createState() =>
      _DealerRegisterScreenState();
}

class _DealerRegisterScreenState
    extends State<DealerRegisterScreen> {
  final DealerAuthService _authService = DealerAuthService();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool loading = false;
  bool showPassword = false;
  String? error;

  bool get passwordsMatch =>
      passwordController.text.isNotEmpty &&
      passwordController.text == confirmPasswordController.text;

  Future<void> _register() async {
    setState(() {
      loading = true;
      error = null;
    });

    if (!passwordsMatch) {
      setState(() {
        loading = false;
        error = "Passwords do not match";
      });
      return;
    }

    final errorMessage = await _authService.register(
      nameController.text.trim(),
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (!mounted) return;

    setState(() => loading = false);

    if (errorMessage == null) {
     
    } else {
      setState(() {
        error = errorMessage;
      });
    }

    if (errorMessage == null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Dealer Registration Successful"),
          content:
              const Text("Please login to access dealer dashboard."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        error = "Registration failed. Email may already exist.";
      });
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
              "assets/images/login_bg.png",
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child:
                Container(color: Colors.black.withOpacity(0.65)),
          ),

          /// GLASS FORM
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: 14, sigmaY: 14),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius:
                          BorderRadius.circular(24),
                      border:
                          Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Dealer Registration",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          "Create your dealership account",
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: Colors.white70),
                        ),

                        const SizedBox(height: 28),

                        _glassField(
                          controller: nameController,
                          label: "Dealer Name",
                          icon: Icons.store,
                        ),

                        const SizedBox(height: 16),

                        _glassField(
                          controller: emailController,
                          label: "Email",
                          icon: Icons.email_outlined,
                        ),

                        const SizedBox(height: 16),

                        _glassField(
                          controller: passwordController,
                          label: "Password",
                          icon: Icons.lock_outline,
                          obscure: !showPassword,
                          suffix: IconButton(
                            icon: Icon(
                              showPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white70,
                            ),
                            onPressed: () =>
                                setState(() =>
                                    showPassword =
                                        !showPassword),
                          ),
                          onChanged: (_) =>
                              setState(() {}),
                        ),

                        const SizedBox(height: 16),

                        _glassField(
                          controller:
                              confirmPasswordController,
                          label: "Confirm Password",
                          icon: Icons.lock,
                          obscure: !showPassword,
                          onChanged: (_) =>
                              setState(() {}),
                        ),

                        const SizedBox(height: 12),

                        if (confirmPasswordController
                            .text.isNotEmpty)
                          Text(
                            passwordsMatch
                                ? "Passwords match ✓"
                                : "Passwords do not match",
                            style: TextStyle(
                              color: passwordsMatch
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                            ),
                          ),

                        const SizedBox(height: 14),

                        if (error != null)
                          Text(
                            error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.redAccent,
                            ),
                          ),

                        const SizedBox(height: 22),

                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed:
                                loading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF2563EB),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                        30),
                              ),
                            ),
                            child: loading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    "Register Dealer",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Already have an account? Login",
                            style: TextStyle(
                                color: Colors.white70),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// GLASS TEXT FIELD
  Widget _glassField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            const TextStyle(color: Colors.white70),
        prefixIcon:
            Icon(icon, color: Colors.white70),
        suffixIcon: suffix,
        filled: true,
        fillColor:
            Colors.white.withOpacity(0.08),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

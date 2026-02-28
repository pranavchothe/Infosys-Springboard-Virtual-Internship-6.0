import 'dart:ui';
import 'package:flutter/material.dart';
import '../dealer_services/dealer_auth_service.dart';
import 'dealer_dashboard_screen.dart';
import 'dealer_register_screen.dart';

class DealerLoginScreen extends StatefulWidget {
  const DealerLoginScreen({super.key});

  @override
  State<DealerLoginScreen> createState() => _DealerLoginScreenState();
}

class _DealerLoginScreenState extends State<DealerLoginScreen> {
  final DealerAuthService _authService = DealerAuthService();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool showPassword = false;
  String? error;

  Future<void> _login() async {
    setState(() {
      loading = true;
      error = null;
    });

    final success = await _authService.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (!mounted) return;

    setState(() => loading = false);

    if (success == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DealerDashboardScreen(),
        ),
      );
    } else {
      setState(() {
        error = "Invalid email or password";
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
            child: Container(
              color: Colors.black.withOpacity(0.65),
            ),
          ),

          /// GLASS LOGIN CARD
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Dealer Login",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          "Access your customer chats",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70),
                        ),

                        const SizedBox(height: 30),

                        _glassField(
                          controller: emailController,
                          label: "Email",
                          icon: Icons.email_outlined,
                        ),

                        const SizedBox(height: 18),

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
                                setState(() => showPassword = !showPassword),
                          ),
                        ),

                        const SizedBox(height: 18),

                        if (error != null)
                          Text(
                            error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.redAccent,
                            ),
                          ),

                        const SizedBox(height: 24),

                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: loading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFFE11D48),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(30),
                              ),
                            ),
                            child: loading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    "Login",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),

                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DealerRegisterScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Don't have an account? Register",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Back to User App",
                            style: TextStyle(color: Colors.white70),
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

  Widget _glassField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

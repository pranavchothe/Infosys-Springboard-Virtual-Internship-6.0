import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();

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

    final success = await _authService.register(
      nameController.text.trim(),
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (!mounted) return;

    setState(() => loading = false);

    if (success) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Registration Successful"),
          content: const Text("Please login to continue."),
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
            child: Container(color: Colors.black.withOpacity(0.65)),
          ),

          /// GLASS FORM
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Create Account",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          "Analyze leases smarter",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70),
                        ),

                        const SizedBox(height: 28),

                        _glassField(
                          controller: nameController,
                          label: "Full Name",
                          icon: Icons.person_outline,
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
                                setState(() => showPassword = !showPassword),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),

                        const SizedBox(height: 16),

                        _glassField(
                          controller: confirmPasswordController,
                          label: "Confirm Password",
                          icon: Icons.lock,
                          obscure: !showPassword,
                          onChanged: (_) => setState(() {}),
                        ),

                        const SizedBox(height: 10),

                        if (confirmPasswordController.text.isNotEmpty)
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
                            onPressed: loading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFFE11D48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
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
                                    "Create Account",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
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

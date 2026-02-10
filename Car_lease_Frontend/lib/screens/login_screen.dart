import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import '../services/chatbot_context.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool showPassword = false;
  String error = "";

  Future<void> _login() async {
    if (loading) return;

    setState(() {
      loading = true;
      error = "";
    });

    bool success = false;

    try {
      success = await AuthService().login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
    } catch (_) {
      success = false;
    }

    if (!mounted) return;

    setState(() => loading = false);

    if (success) {
      
      ChatBotContext.setLoggedIn(true);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      setState(() {
        error = "Invalid email or password";
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// BACKGROUND IMAGE
          Positioned.fill(
            child: Image.asset(
              "assets/images/login_bg.png", // <-- same image as screenshot
              fit: BoxFit.cover,
            ),
          ),

          /// DARK OVERLAY
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.55),
            ),
          ),

          /// CONTENT
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),

                    /// TITLE
                    const Text(
                      "Welcome Back!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "Login to analyze your car lease and negotiate smarter.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 36),

                    /// EMAIL FIELD
                    _glassTextField(
                      controller: emailController,
                      hint: "Email address",
                      icon: Icons.email_outlined,
                      obscure: false,
                    ),

                    const SizedBox(height: 16),

                    /// PASSWORD FIELD
                    _glassTextField(
                      controller: passwordController,
                      hint: "Password",
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

                    const SizedBox(height: 12),

                    /// ERROR
                    if (error.isNotEmpty)
                      Text(
                        error,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 13,
                        ),
                      ),

                    const SizedBox(height: 28),

                    /// LOGIN BUTTON
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: loading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE11D48),
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
                                "Login",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// SIGN UP BUTTON
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// FOOTER
                    const Text(
                      "By continuing, you agree to our Terms of Service and Privacy Policy.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassTextField({
  required TextEditingController controller,
  required String hint,
  required IconData icon,
  required bool obscure,
  Widget? suffix,
}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(18),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                obscureText: obscure,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
              ),
            ),
            if (suffix != null) suffix,
          ],
        ),
      ),
    ),
  );
}


}

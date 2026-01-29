import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/upload_screen.dart';
import 'services/auth_service.dart';
import 'widgets/chatbot_popup.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getStartScreen() async {
    final authService = AuthService();
    final token = await authService.getToken();
    return token != null ? const UploadScreen() : const LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Lease Analyzer',
      debugShowCheckedModeBanner: false,

      // THIS GUARANTEES Overlay + Navigator EXIST
      builder: (context, child) {
        return Material(
          child: Stack(
            children: [
              child!,         
              ChatBotPopup(), 
            ],
          ),
        );
      },

      theme: ThemeData(
        primaryColor: const Color(0xFF5B4BFF),
        scaffoldBackgroundColor: const Color(0xFFF7F8FC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF5B4BFF),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5B4BFF),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),

      home: FutureBuilder<Widget>(
        future: _getStartScreen(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return snapshot.data!;
        },
      ),
    );
  }
}

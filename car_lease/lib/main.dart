import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/role_selection_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import '../screens/result_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Lease AI',
      debugShowCheckedModeBanner: false,

       onGenerateRoute: (settings) {
          if (settings.name == "/result") {
            final args = settings.arguments as Map<String, dynamic>;

            return MaterialPageRoute(
              builder: (_) => ResultScreen(result: args),
            );
          }

          switch (settings.name) {
            case "/":
              return MaterialPageRoute(builder: (_) => const RoleSelectionScreen());
            case "/login":
              return MaterialPageRoute(builder: (_) => const LoginScreen());
            case "/home":
              return MaterialPageRoute(builder: (_) => const HomeScreen());
            default:
              return null;
          }
        },

      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0E1A1F),
        primaryColor: const Color(0xFF2575FC),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0E1A1F),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),

        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
          titleLarge: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2575FC),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),

        cardTheme: CardThemeData(
          color: const Color(0xFF1C2B33),
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        iconTheme: const IconThemeData(color: Colors.white70),
      ),

      // SINGLE ENTRY POINT
      home: const RoleSelectionScreen(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool checking = true;
  bool loggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");

    setState(() {
      loggedIn = token != null;
      checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (checking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // LOGIN → HOME (wrapped with global chatbot)
    return loggedIn
        ? const HomeScreen()
        : const LoginScreen();  
  }
}

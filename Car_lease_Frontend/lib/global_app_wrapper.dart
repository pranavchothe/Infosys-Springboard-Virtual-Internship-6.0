import 'package:flutter/material.dart';
import 'widgets/chatbot_popup.dart';

class GlobalAppWrapper extends StatelessWidget {
  final Widget child;

  const GlobalAppWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,          // All app screens
        ChatBotPopup(), // Chatbot always visible
      ],
    );
  }
}

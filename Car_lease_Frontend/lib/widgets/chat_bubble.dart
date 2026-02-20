import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatBubble({
    super.key,
    required this.text,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isUser
              ? const Color(0xFFDCF8C6) // WhatsApp green
              : const Color(0xFF1F2937), // dealer dark
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft:
                isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight:
                isUser ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.black : Colors.white,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

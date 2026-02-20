import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AIChatBot extends StatefulWidget {
  final int recordId;
  final Map<String, dynamic> analysisResult;
  final Map<String, dynamic> fairnessAnalysis;
  final Map<String, dynamic> carHistory;

  const AIChatBot({
    super.key,
    required this.recordId,
    Map<String, dynamic>? analysisResultMap,
    Map<String, dynamic>? fairnessAnalysisMap,
    Map<String, dynamic>? carHistoryMap,
  })  : analysisResult = analysisResultMap ?? const {},
        fairnessAnalysis = fairnessAnalysisMap ?? const {},
        carHistory = carHistoryMap ?? const {};

  @override
  State<AIChatBot> createState() => _AIChatBotState();
}

class _AIChatBotState extends State<AIChatBot>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool isOpen = false;
  bool isTyping = false;

  late AnimationController _dotController;

  final List<Map<String, String>> messages = [
    {
      "role": "assistant",
      "text":
          "Hi 👋 I’m your AI Lease & Negotiation Assistant.\n\nYou can ask me to:\n• Negotiate this lease\n• Explain any clause\n• Act as dealer or customer\n• Simplify the document"
    }
  ];

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("access_token");
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add({"role": "user", "text": text});
      isTyping = true;
    });

    _controller.clear();
    _scrollToBottom();

    final token = await _getToken();
    if (token == null) return;

    try {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:8000/chatbot/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "record_id": widget.recordId,
          "message": text,
        }),


      );


      print("AI CHAT STATUS: ${response.statusCode}");
      print("AI CHAT RAW BODY: ${response.body}");

      if (response.statusCode != 200 || response.body.isEmpty) {
        throw Exception("AI backend failed");
      }

      final decoded = jsonDecode(response.body);

      final aiText =
      decoded["reply"] ??
      decoded["response"] ??
      decoded["message"] ??
      decoded["content"] ??
      "I couldn’t generate a response. Please try again.";



      setState(() {
        messages.add({
          "role": "assistant",
          "text": aiText.toString(),
        });
        isTyping = false;
      });

      _scrollToBottom();
    } catch (_) {
      setState(() {
        isTyping = false;
        messages.add({
          "role": "assistant",
          "text": "⚠️ Something went wrong while talking to the AI."
        });
      });
    }
  }

  /// QUICK PROMPTS 
  Widget _quickButton(String text) {
    return GestureDetector(
      onTap: () => _sendMessage(text),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ),
    );
  }

  /// TYPING DOTS
  Widget _typingIndicator() {
    return AnimatedBuilder(
      animation: _dotController,
      builder: (_, __) {
        int dots = (_dotController.value * 3).floor() + 1;
        return Text(
          "AI is typing${'.' * dots}",
          style: const TextStyle(color: Colors.white60),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

        /// CHAT WINDOW
        if (isOpen)
          Positioned(
            right: 16,
            bottom: 90,
            child: Container(
              width: 350,
              height: 500,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 20,
                  )
                ],
              ),
              child: Column(
                children: [

                  /// HEADER
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        const Text(
                          "AI Assistant 🤖",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => setState(() => isOpen = false),
                          icon: const Icon(Icons.close, color: Colors.white),
                        )
                      ],
                    ),
                  ),

                  const Divider(color: Colors.white24),

                  /// MESSAGES
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(12),
                      itemCount: messages.length,
                      itemBuilder: (_, i) {
                        final msg = messages[i];
                        final isUser = msg["role"] == "user";

                        return Align(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? const Color(0xFF6366F1)
                                  : Colors.white12,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              msg["text"]!,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  /// TYPING INDICATOR
                  if (isTyping)
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 16, bottom: 6),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _typingIndicator(),
                      ),
                    ),

                  /// QUICK BUTTONS
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: [
                        _quickButton("Negotiate this lease"),
                        _quickButton("Explain this clause"),
                        _quickButton("Act as dealer"),
                        _quickButton("Simplify document"),
                      ],
                    ),
                  ),

                  /// INPUT
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            style: const TextStyle(color: Colors.white),
                            onSubmitted: _sendMessage, // ⌨️ ENTER SENDS
                            decoration: const InputDecoration(
                              hintText: "Type a message...",
                              hintStyle: TextStyle(color: Colors.white54),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () =>
                              _sendMessage(_controller.text),
                          icon: const Icon(Icons.send, color: Colors.white),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),

        /// FLOATING BUTTON
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            backgroundColor: const Color(0xFF6366F1),
            onPressed: () => setState(() => isOpen = !isOpen),
            child: const Icon(Icons.smart_toy),
          ),
        )
      ],
    );
  }
}

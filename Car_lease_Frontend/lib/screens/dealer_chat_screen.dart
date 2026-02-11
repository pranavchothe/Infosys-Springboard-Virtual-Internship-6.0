import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/dealer_chat_service.dart';
import '../widgets/chat_bubble.dart';

class DealerChatScreen extends StatefulWidget {
  final int leaseId;

  const DealerChatScreen({
    super.key,
    required this.leaseId,
  });

  @override
  State<DealerChatScreen> createState() => _DealerChatScreenState();
}

class _DealerChatScreenState extends State<DealerChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [];
  bool _dealerTyping = false;
  bool _loadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final history =
          await DealerChatService.loadHistory(widget.leaseId);

      for (final h in history) {
        _messages.add(
          ChatMessage(
            text: h["message"],
            isUser: h["sender"] == "user",
            timestamp: DateTime.parse(h["created_at"]),
          ),
        );
      }
    } catch (e) {
      debugPrint("Failed to load chat history: $e");
    }

    setState(() {
      _loadingHistory = false;
    });

    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();

    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _dealerTyping = true;
    });

    _scrollToBottom();

    try {
      final dealerReply = await DealerChatService.sendMessage(
        leaseId: widget.leaseId,
        message: text,
      );

      setState(() {
        _dealerTyping = false;
        _messages.add(
          ChatMessage(
            text: dealerReply,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
    } catch (e) {
      setState(() {
        _dealerTyping = false;
      });

      _messages.add(
        ChatMessage(
          text:
              "Sorry, I’ll need to check this and get back to you shortly.",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    }

    _scrollToBottom();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B141A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF202C33),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Dealer"),
            Text(
              "Online",
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loadingHistory
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(top: 10),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return ChatBubble(
                        text: msg.text,
                        isUser: msg.isUser,
                      );
                    },
                  ),
          ),

          if (_dealerTyping)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                "Dealer is typing...",
                style: TextStyle(color: Colors.white54),
              ),
            ),

          _inputBar(),
        ],
      ),
    );
  }

  Widget _inputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      color: const Color(0xFF202C33),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Type a message",
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFF25D366)),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import '/models/chat_message.dart';
import '../dealer_services/dealer_chat_service.dart';
import '/widgets/chat_bubble.dart';

class DealerChatScreen extends StatefulWidget {
  final int leaseId;
  final bool isDealer;

  const DealerChatScreen({
    super.key,
    required this.leaseId,
    this.isDealer = false, 
  });

  @override
  State<DealerChatScreen> createState() => _DealerChatScreenState();
}

class _DealerChatScreenState extends State<DealerChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [];

  bool _loadingHistory = true;
  bool _dealerOnline = false;

  Timer? _pollingTimer;
  Timer? _statusTimer;
  List<String> _aiSuggestions = [];
  String? _lastDealerMessage;
  bool _loadingAi = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _startMessagePolling();
    _startStatusPolling();
  }

  
  // DISPOSE
  
  @override
  void dispose() {
    _pollingTimer?.cancel();
    _statusTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // LOAD CHAT HISTORY

  Future<void> _loadHistory() async {
    try {
      final history =
          await DealerChatService.loadHistory(widget.leaseId);

      if (mounted) {
        final updatedMessages = history.map((h) => ChatMessage(
              text: h["message"],
              isUser: h["sender"] == "user",
              timestamp: DateTime.parse(h["created_at"]),
            )).toList();

        setState(() {
          _messages
            ..clear()
            ..addAll(updatedMessages);
        });

        // 🔥 Detect new dealer message
        if (!widget.isDealer && _messages.isNotEmpty) {
          final last = _messages.last;

          if (!last.isUser) {
            print("Triggering AI for dealer message");
            _fetchAiSuggestion(last.text);
          }
        }

      }

      await DealerChatService.markMessagesRead(widget.leaseId);

    } catch (e) {
      debugPrint("Failed to load chat history: $e");
    }

    if (mounted) {
      setState(() {
        _loadingHistory = false;
      });
    }

    _scrollToBottom();
  }

  // MESSAGE POLLING
  
  void _startMessagePolling() {
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _loadHistory(),
    );
  }

 
  // DEALER STATUS POLLING

  void _startStatusPolling() {
  _statusTimer = Timer.periodic(
    const Duration(seconds: 5),
    (_) async {
      try {
        // If dealer → send heartbeat
        if (widget.isDealer) {
          await DealerChatService.sendHeartbeat();
        }

        // Check status
        final online = await DealerChatService.getDealerStatus();

        if (mounted) {
          setState(() {
            _dealerOnline = online;
          });
        }
      } catch (_) {}
    },
  );
}

  Future<void> _fetchAiSuggestion(String dealerMessage) async {
    if (widget.isDealer) return;

    print("Fetching AI for message: $dealerMessage");

    setState(() {
      _loadingAi = true;
    });

    try {
      final suggestions =
          await DealerChatService.getAiSuggestion(
        leaseId: widget.leaseId,
        dealerMessage: dealerMessage,
      );

      print("AI Suggestions received: $suggestions");

      if (mounted) {
        setState(() {
          _aiSuggestions = suggestions;
          _loadingAi = false;
        });
      }
    } catch (e) {
      print("AI ERROR: $e");

      if (mounted) {
        setState(() {
          _loadingAi = false;
        });
      }
    }
  }


  // SEND MESSAGE
  
  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();

    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isUser: !widget.isDealer,
          timestamp: DateTime.now(),
        ),
      );
    });

    _scrollToBottom();

     try {
      if (widget.isDealer) {
        await DealerChatService.sendDealerReply(
          leaseId: widget.leaseId,
          message: text,
        );
      } else {
        await DealerChatService.sendMessage(
          leaseId: widget.leaseId,
          message: text,
        );
      }

    await _loadHistory();

    } catch (e) {
      debugPrint("Send failed: $e");
    }
  }


  // AUTO SCROLL
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.isDealer ? "Customer" : "Dealer"),
            Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 10,
                  color: _dealerOnline ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  _dealerOnline ? "Online" : "Offline",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
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

          // ===== AI Panel (Customer Only) =====
          if (!widget.isDealer)
            _buildAiPanel(),
            
          _inputBar(),
        ],
      ),
    );
  }

  Widget _buildAiPanel() {
    if (_loadingAi) {
      return const Padding(
        padding: EdgeInsets.all(8),
        child: LinearProgressIndicator(),
      );
    }

    if (_aiSuggestions.isEmpty) {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.all(10),
      color: const Color(0xFF16232A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "AI Negotiation Assistant",
            style: TextStyle(
              color: Colors.greenAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          ..._aiSuggestions.map((suggestion) {
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                ),
                onPressed: () {
                  _controller.text = suggestion;
                },
                child: Text(
                  suggestion,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // INPUT BAR
 
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
            icon: const Icon(
              Icons.send,
              color: Color(0xFF25D366),
            ),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}

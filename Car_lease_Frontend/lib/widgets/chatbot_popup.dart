import 'package:flutter/material.dart';
import '../services/chatbot_service.dart';
import '../services/chatbot_api_service.dart';

class ChatBotPopup extends StatefulWidget {
  @override
  State<ChatBotPopup> createState() => _ChatBotPopupState();
}

class _ChatBotPopupState extends State<ChatBotPopup> {
  bool open = false;
  final controller = TextEditingController();

  final service = ChatBotService();
  final aiService = ChatbotApiService();

  final List<Map<String, String>> messages = [
    {
      "role": "bot",
      "text": "👋 Hi! I’m your Car Assistant.\n\nAsk me anything about this car 🙂"
    }
  ];

  // MUST BE ASYNC
  Future<void> send() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    // Add USER message
    setState(() {
      messages.add({"role": "user", "text": text});
      messages.add({"role": "bot", "text": "Typing..."});
    });

    controller.clear();

    try {
      final aiReply = await aiService.sendMessage(text, 1); 
      setState(() {
        messages.removeLast(); // remove Typing...
        messages.add({"role": "bot", "text": aiReply});
      });
    } catch (e) {
      setState(() {
        messages.removeLast();
        messages.add({
          "role": "bot",
          "text": "⚠️ AI service unavailable. Please try again."
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (open)
          Positioned(
            bottom: 90,
            right: 16,
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 300,
                height: 420,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Car Assistant 🤖",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() => open = false),
                        )
                      ],
                    ),
                    const Divider(),

                    Expanded(
                      child: ListView(
                        children: messages.map((m) {
                          final isUser = m['role'] == "user";
                          return Align(
                            alignment: isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? Colors.blue[100]
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(m['text']!),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            onSubmitted: (_) => send(),
                            decoration: const InputDecoration(
                              hintText: "Ask something...",
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: send,
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),

        //Positioned(
          //bottom: 20,
          //right: 16,
          //child: FloatingActionButton(
            //onPressed: () => setState(() => open = !open),
            //child: Icon(open ? Icons.close : Icons.chat),
          //),
        //)
      ],
    );
  }
}

import 'package:flutter/material.dart';

class ChatbotSheet extends StatefulWidget {
  final void Function(String message)? onSend;

  const ChatbotSheet({
    super.key,
    this.onSend,
  });

  @override
  State<ChatbotSheet> createState() => _ChatbotSheetState();
}

class _ChatbotSheetState extends State<ChatbotSheet> {
  final TextEditingController _controller = TextEditingController();

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    widget.onSend?.call(text);
    _controller.clear();

    // Close sheet after send (natural UX)
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ================= DRAG INDICATOR =================
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ================= TITLE =================
            Text(
              "AI Assistant",
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 6),

            Text(
              "Ask anything about your lease",
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // ================= INPUT =================
            TextField(
              controller: _controller,
              maxLines: 3,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _handleSend(),
              decoration: InputDecoration(
                hintText: "e.g. Can I terminate early?",
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ================= SEND BUTTON =================
            ElevatedButton.icon(
              onPressed: _handleSend,
              icon: const Icon(Icons.send),
              label: const Text("Send"),
            ),
          ],
        ),
      ),
    );
  }
}

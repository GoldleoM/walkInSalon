import 'package:flutter/material.dart';

class ReplyDialog extends StatefulWidget {
  final Future<void> Function(String replyText) onSubmit;

  const ReplyDialog({super.key, required this.onSubmit});

  @override
  State<ReplyDialog> createState() => _ReplyDialogState();
}

class _ReplyDialogState extends State<ReplyDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Reply to Review"),
      content: TextField(
        controller: _controller,
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: "Write your reply...",
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () async {
            final reply = _controller.text.trim();
            if (reply.isNotEmpty) {
              Navigator.pop(context);
              await widget.onSubmit(reply);
            }
          },
          child: const Text("Post Reply"),
        ),
      ],
    );
  }
}

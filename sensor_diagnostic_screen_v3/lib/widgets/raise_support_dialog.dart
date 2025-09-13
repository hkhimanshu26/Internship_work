import 'package:flutter/material.dart';

class RaiseSupportDialog extends StatefulWidget {
  const RaiseSupportDialog({super.key});

  @override
  State<RaiseSupportDialog> createState() => _RaiseSupportDialogState();
}

class _RaiseSupportDialogState extends State<RaiseSupportDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Raise Support"),
      content: TextField(
        controller: _controller,
        maxLines: 5,
        decoration: const InputDecoration(
          hintText: "Describe the issue...",
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting
              ? null
              : () {
                  Navigator.pop(context);
                },
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _isSubmitting
              ? null
              : () async {
                  if (_controller.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please enter a message.")),
                    );
                    return;
                  }

                  setState(() => _isSubmitting = true);

                  await Future.delayed(
                    const Duration(seconds: 2),
                  ); // Simulated delay

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Support request sent successfully!"),
                      ),
                    );
                  }
                },
          child: _isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text("Submit"),
        ),
      ],
    );
  }
}

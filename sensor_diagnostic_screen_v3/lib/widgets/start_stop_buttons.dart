import 'package:flutter/material.dart';

class StartStopButtons extends StatelessWidget {
  final bool isStarted;
  final VoidCallback onStartPressed;
  final VoidCallback onStopPressed;

  const StartStopButtons({
    super.key,
    required this.isStarted,
    required this.onStartPressed,
    required this.onStopPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isStarted ? onStopPressed : onStartPressed,
      icon: Icon(isStarted ? Icons.pause : Icons.play_arrow),
      label: Text(isStarted ? 'Stop' : 'Start'),
      style: ElevatedButton.styleFrom(
        backgroundColor: isStarted
            ? const Color.fromARGB(255, 85, 88, 125)
            : const Color.fromARGB(255, 34, 61, 119),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 5,
      ),
    );
  }
}

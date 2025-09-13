import 'package:flutter/material.dart';
import 'screens/diagnostic_screen.dart'; // Use the modular screen

void main() {
  runApp(TraffiQIQApp());
}

class TraffiQIQApp extends StatelessWidget {
  const TraffiQIQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TraffiQIQ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: DiagnosticScreen(), // Launch this screen
    );
  }
}

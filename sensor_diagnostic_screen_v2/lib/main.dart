import 'package:flutter/material.dart';
import 'sensor_diagnostic_screen_v2.dart';

void main() {
  runApp(const TraffiQIQApp());
}

class TraffiQIQApp extends StatefulWidget {
  const TraffiQIQApp({super.key});

  @override
  State<TraffiQIQApp> createState() => _TraffiQIQAppState();
}

class _TraffiQIQAppState extends State<TraffiQIQApp> {
  bool isDarkTheme = false;

  void toggleTheme() {
    setState(() {
      isDarkTheme = !isDarkTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TraffiQIQ V2',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      themeMode: isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: SensorDiagnosticScreenV2(toggleTheme: toggleTheme),
    );
  }
}

// ---------------- Screens Below ----------------

class HomeScreen extends StatelessWidget {
  final VoidCallback toggleTheme;
  const HomeScreen({super.key, required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: toggleTheme,
          ),
        ],
      ),
      body: const Center(child: Text('Home Screen')),
    );
  }
}

class ReportScreen extends StatelessWidget {
  final VoidCallback toggleTheme;
  const ReportScreen({super.key, required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: toggleTheme,
          ),
        ],
      ),
      body: const Center(child: Text('Report Screen')),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  final VoidCallback toggleTheme;
  const SettingsScreen({super.key, required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: toggleTheme,
          ),
        ],
      ),
      body: const Center(child: Text('Settings Screen')),
    );
  }
}

class AboutScreen extends StatelessWidget {
  final VoidCallback toggleTheme;
  const AboutScreen({super.key, required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: toggleTheme,
          ),
        ],
      ),
      body: const Center(child: Text('About Screen')),
    );
  }
}

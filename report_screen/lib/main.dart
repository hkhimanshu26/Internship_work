// main.dart (snippet)
import 'package:flutter/material.dart';
import 'screens/report_screen.dart';

void main() => runApp(const TraffiQIQApp());

class TraffiQIQApp extends StatelessWidget {
  const TraffiQIQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TraffiQIQ',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const ReportScreen(),
    );
  }
}

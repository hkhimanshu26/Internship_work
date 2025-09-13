import 'package:flutter/material.dart';
import 'report/report_screen.dart';

void main() {
  runApp(const TraffiQIQReportsApp());
}

class TraffiQIQReportsApp extends StatelessWidget {
  const TraffiQIQReportsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TraffiQIQ - Reports',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        primaryColor: const Color(0xFF1976D2),
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 1,
          centerTitle: false,
        ),
      ),
      home: const ReportScreen(),
    );
  }
}

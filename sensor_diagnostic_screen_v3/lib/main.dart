import 'package:flutter/material.dart';
import 'package:sensor_diagnostic_screen_v3/sensor_diagnostic_screen_v3.dart';
import 'themes/app_theme.dart';

void main() {
  runApp(const TraffiQIQApp());
}

class TraffiQIQApp extends StatefulWidget {
  const TraffiQIQApp({super.key});

  @override
  State<TraffiQIQApp> createState() => _TraffiQIQAppState();
}

class _TraffiQIQAppState extends State<TraffiQIQApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TraffiQIQ - Sensor Diagnostic',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: SensorDiagnosticScreenV3(onToggleTheme: toggleTheme),
    );
  }
}

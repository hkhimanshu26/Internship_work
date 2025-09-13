import 'package:flutter/material.dart';
import 'sensor_diagnostic_screen.dart';

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
      title: 'TraffiQIQ App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      themeMode: isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: SensorDiagnosticScreen(toggleTheme: toggleTheme),
      // routes: {
      //   '/home': (context) => HomeScreen(toggleTheme: toggleTheme),
      //   '/report': (context) => ReportScreen(toggleTheme: toggleTheme),
      //   '/settings': (context) => SettingsScreen(toggleTheme: toggleTheme),
      //   '/about': (context) => AboutScreen(toggleTheme: toggleTheme),
      // },
    );
  }
}

// ----- Screens -----

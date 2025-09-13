import 'package:flutter/material.dart';
import 'device_connection_screen.dart';
import 'main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (_) => const DeviceConnectionScreen(),
        '/main': (_) => const MainScreen(),
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'report_mobile_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TraffiQIQMobileReportsApp());
}

class TraffiQIQMobileReportsApp extends StatelessWidget {
  const TraffiQIQMobileReportsApp({super.key});

  // Dark palette carried over from web (tweak if your exact hexes differ)
  static const _bg = Color(0xFF0F1216);
  static const _card = Color(0xFF151A21);
  static const _elev = Color(0xFF1B2230);
  static const _primary = Color(0xFF4CC2FF);
  static const _accent = Color(0xFF00E5A8);
  static const _warning = Color(0xFFFFC857);
  static const _danger = Color(0xFFFF5964);
  static const _textPrimary = Color(0xFFE6EAF2);
  static const _textSecondary = Color(0xFFADB6C8);

  static ThemeData _darkTheme() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: _bg,
      colorScheme: base.colorScheme.copyWith(
        brightness: Brightness.dark,
        primary: _primary,
        secondary: _accent,
        surface: _card,
        onSurface: _textPrimary,
      ),
      cardColor: _card,
      dividerColor: const Color(0x223B4B5F),
      appBarTheme: const AppBarTheme(
        backgroundColor: _bg,
        elevation: 0,
        centerTitle: false,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: _textPrimary,
        displayColor: _textPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _elev,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0x334CC2FF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0x223B4B5F)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      chipTheme: base.chipTheme.copyWith(
        side: BorderSide.none,
        backgroundColor: _elev,
        labelStyle: const TextStyle(color: _textSecondary, fontSize: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primary,
        foregroundColor: _bg,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TraffiQIQ Reports (Mobile)',
      debugShowCheckedModeBanner: false,
      theme: _darkTheme(),
      home: const ReportMobileScreen(
        palette: ReportPalette(
          bg: _bg,
          card: _card,
          elev: _elev,
          primary: _primary,
          accent: _accent,
          warning: _warning,
          danger: _danger,
          textPrimary: _textPrimary,
          textSecondary: _textSecondary,
        ),
      ),
    );
  }
}

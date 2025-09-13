import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: Color(0xFF0057B8),
      secondary: Color(0xFF34C759),
      surface: Color(0xFFF5F7FA),
      error: Color(0xFFFF3B30),
    ),
    useMaterial3: true,
    textTheme: GoogleFonts.poppinsTextTheme(),
  );

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF0A84FF),
      secondary: Color(0xFF32D74B),
      surface: Color(0xFF1C1C1E),
      error: Color(0xFFFF453A),
    ),
    useMaterial3: true,
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
  );
}

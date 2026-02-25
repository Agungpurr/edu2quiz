import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DuoColors {
  // Duolingo signature palette
  static const Color green = Color(0xFF58CC02);
  static const Color greenDark = Color(0xFF46A302);
  static const Color greenLight = Color(0xFFD7FFB8);
  static const Color blue = Color(0xFF1CB0F6);
  static const Color blueDark = Color(0xFF0A9BD4);
  static const Color orange = Color(0xFFFF9600);
  static const Color orangeLight = Color(0xFFFFDEA3);
  static const Color red = Color(0xFFFF4B4B);
  static const Color redDark = Color(0xFFCC3B3B);
  static const Color redLight = Color(0xFFFFD5D5);
  static const Color purple = Color(0xCECE82FF);
  static const Color yellow = Color(0xFFFFE066);
  static const Color white = Colors.white;
  static const Color border = Color(0xFFE5E5E5);
  static const Color bg = Color(0xFFF7F7F7);
  static const Color textDark = Color(0xFF3C3C3C);
  static const Color textGrey = Color(0xFFAFAFAF);
}

class AppTheme {
  // Mapel colors
  static const Map<String, Color> mapelColors = {
    'Matematika': Color(0xFF1CB0F6),
    'IPA': Color(0xFF58CC02),
    'IPS': Color(0xFFFF9600),
    'B.Indonesia': Color(0xFFFF4B4B),
  };

  static const Map<String, Color> mapelDark = {
    'Matematika': Color(0xFF0A9BD4),
    'IPA': Color(0xFF46A302),
    'IPS': Color(0xFFCC7A00),
    'B.Indonesia': Color(0xFFCC3B3B),
  };

  static const Map<String, Color> mapelLight = {
    'Matematika': Color(0xFFE0F5FF),
    'IPA': Color(0xFFD7FFB8),
    'IPS': Color(0xFFFFEED4),
    'B.Indonesia': Color(0xFFFFD5D5),
  };

  static const Map<String, String> mapelEmoji = {
    'Matematika': '🔢',
    'IPA': '🔬',
    'IPS': '🌏',
    'B.Indonesia': '📖',
  };

  static const Map<String, IconData> mapelIcons = {
    'Matematika': Icons.calculate,
    'IPA': Icons.science,
    'IPS': Icons.public,
    'B.Indonesia': Icons.menu_book,
  };

  static Color gradeColor(String g) {
    switch (g) {
      case 'A':
        return DuoColors.green;
      case 'B':
        return DuoColors.blue;
      case 'C':
        return DuoColors.orange;
      case 'D':
        return DuoColors.orange;
      default:
        return DuoColors.red;
    }
  }

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: DuoColors.green, primary: DuoColors.green),
        scaffoldBackgroundColor: DuoColors.bg,
        textTheme: GoogleFonts.nunitoTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: DuoColors.textDark,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: DuoColors.textDark,
          ),
          shadowColor: DuoColors.border,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: DuoColors.green,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: GoogleFonts.nunito(
                fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: 0.5),
            elevation: 0,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: DuoColors.border, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: DuoColors.border, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: DuoColors.green, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: DuoColors.border, width: 2),
          ),
          color: Colors.white,
        ),
      );
}

class AppConstants {
  static const List<String> kelasList = ['4', '5', '6'];
  static const List<String> mapelList = [
    'Matematika',
    'IPA',
    'IPS',
    'B.Indonesia'
  ];
  static const List<String> tingkatList = ['mudah', 'sedang', 'sulit'];
  static const Map<String, String> tingkatLabel = {
    'mudah': 'Mudah',
    'sedang': 'Sedang',
    'sulit': 'Sulit'
  };
  static const Map<String, Color> tingkatColors = {
    'mudah': Color(0xFF58CC02),
    'sedang': Color(0xFFFF9600),
    'sulit': Color(0xFFFF4B4B),
  };
  static const Map<String, int> tingkatPoin = {
    'mudah': 10,
    'sedang': 15,
    'sulit': 20
  };
}

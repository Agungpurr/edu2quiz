import 'package:flutter/material.dart';

// ── Warna utama Duolingo-style ────────────────────────────────────────────────
class DuoColors {
  DuoColors._();

  static const Color green = Color(0xFF58CC02);
  static const Color greenDark = Color(0xFF46A302);
  static const Color greenLight = Color(0xFFD7F5A0);

  static const Color red = Color(0xFFFF4B4B);
  static const Color redDark = Color(0xFFCC0000);
  static const Color redLight = Color(0xFFFFE0E0);

  static const Color orange = Color(0xFFFF9600);
  static const Color orangeDark = Color(0xFFCC7700);
  static const Color orangeLight = Color(0xFFFFF3E0);

  static const Color blue = Color(0xFF1CB0F6);
  static const Color blueDark = Color(0xFF0A7ABF);
  static const Color blueLight = Color(0xFFE0F5FF);

  static const Color purple = Color(0xFFCE82FF);
  static const Color purpleDark = Color(0xFF9A40CC);
  static const Color purpleLight = Color(0xFFF5E6FF);

  static const Color textDark = Color(0xFF3C3C3C);
  static const Color textGrey = Color(0xFF777777);
  static const Color border = Color(0xFFE5E5E5);
  static const Color bg = Color(0xFFF7F7F7);
}

// ── AppTheme ─────────────────────────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  /// Warna per mata pelajaran — B.Inggris pakai ungu
  static const Map<String, Color> mapelColors = {
    'Matematika': DuoColors.blue,
    'IPA': DuoColors.green,
    'IPS': DuoColors.orange,
    'B.Indonesia': DuoColors.red,
    'B.Inggris': DuoColors.purple, // ← baru
  };

  /// Emoji per mata pelajaran
  static const Map<String, String> mapelEmoji = {
    'Matematika': '🔢',
    'IPA': '🔬',
    'IPS': '🌏',
    'B.Indonesia': '📚',
    'B.Inggris': '🇬🇧', // ← baru
  };

  /// Warna berdasarkan nilai huruf (grade)
  static Color gradeColor(String grade) {
    switch (grade) {
      case 'A':
        return DuoColors.green;
      case 'B':
        return DuoColors.blue;
      case 'C':
        return DuoColors.orange;
      case 'D':
        return DuoColors.orangeDark;
      default:
        return DuoColors.red; // E
    }
  }

  /// ThemeData utama aplikasi
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: DuoColors.green,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: DuoColors.bg,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: DuoColors.textDark,
          elevation: 0,
          surfaceTintColor: Colors.white,
          titleTextStyle: TextStyle(
            color: DuoColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: DuoColors.border, width: 2),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: DuoColors.border, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: DuoColors.border, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: DuoColors.blue, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: DuoColors.green,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
        ),
      );
}

// ── AppConstants ──────────────────────────────────────────────────────────────
class AppConstants {
  AppConstants._();

  static const List<String> mapelList = [
    'Matematika',
    'IPA',
    'IPS',
    'B.Indonesia',
    'B.Inggris', // ← baru
  ];

  static const List<String> kelasList = ['4', '5', '6'];

  static const List<String> tingkatList = ['mudah', 'sedang', 'sulit'];

  /// Batas maksimal soal per tingkat per mapel per kelas yang boleh dibuat guru
  static const int maxSoalPerTingkat = 10;

  static const Map<String, String> tingkatLabel = {
    'mudah': '🟢 Mudah',
    'sedang': '🟡 Sedang',
    'sulit': '🔴 Sulit',
  };

  static const Map<String, Color> tingkatColors = {
    'mudah': Color(0xFF2E7D32),
    'sedang': DuoColors.orange,
    'sulit': DuoColors.red,
  };

  static const Map<String, int> tingkatPoin = {
    'mudah': 10,
    'sedang': 15,
    'sulit': 20,
  };

  static const Color purple = Color(0xFF9C27B0);
}

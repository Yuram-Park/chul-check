import 'package:flutter/material.dart';
import '../models/attendance_model.dart';

class AppTheme {
  static const Color primary = Color(0xFF4A6CF7);
  static const Color primaryLight = Color(0xFFEEF2FF);
  static const Color present = Color(0xFF22C55E);
  static const Color absent = Color(0xFFEF4444);
  static const Color late = Color(0xFFF59E0B);
  static const Color etc = Color(0xFF8B5CF6);
  static const Color surface = Color(0xFFF8FAFC);
  static const Color cardBg = Colors.white;
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  static Color statusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return present;
      case AttendanceStatus.absent:
        return absent;
      case AttendanceStatus.late:
        return late;
      case AttendanceStatus.etc:
        return etc;
    }
  }

  static Color statusBgColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return const Color(0xFFDCFCE7);
      case AttendanceStatus.absent:
        return const Color(0xFFFEE2E2);
      case AttendanceStatus.late:
        return const Color(0xFFFEF3C7);
      case AttendanceStatus.etc:
        return const Color(0xFFEDE9FE);
    }
  }
}

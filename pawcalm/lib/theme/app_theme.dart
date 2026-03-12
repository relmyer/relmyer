import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Brand Colors ---
  static const Color primary = Color(0xFF4A90D9);        // Calm blue
  static const Color primaryDark = Color(0xFF2C6FAD);
  static const Color secondary = Color(0xFF7BC67E);      // Gentle green
  static const Color accent = Color(0xFFFFB347);         // Warm orange (treats!)
  static const Color danger = Color(0xFFE57373);         // Soft red
  static const Color background = Color(0xFFF7F9FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1F36);
  static const Color textSecondary = Color(0xFF6B7080);
  static const Color divider = Color(0xFFEEF0F5);

  // --- Calm Level Colors ---
  static const Color calmLevel1 = Color(0xFF66BB6A); // Very calm
  static const Color calmLevel2 = Color(0xFFAED581); // Calm
  static const Color calmLevel3 = Color(0xFFFFD54F); // Moderate
  static const Color calmLevel4 = Color(0xFFFF8A65); // Busy
  static const Color calmLevel5 = Color(0xFFE57373); // Very busy

  static Color calmLevelColor(int level) {
    switch (level) {
      case 1: return calmLevel1;
      case 2: return calmLevel2;
      case 3: return calmLevel3;
      case 4: return calmLevel4;
      case 5: return calmLevel5;
      default: return calmLevel3;
    }
  }

  static String calmLevelLabel(int level) {
    switch (level) {
      case 1: return 'Çok Sakin';
      case 2: return 'Sakin';
      case 3: return 'Orta';
      case 4: return 'Kalabalık';
      case 5: return 'Çok Kalabalık';
      default: return 'Bilinmiyor';
    }
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        surface: surface,
        background: background,
        error: danger,
      ),
      scaffoldBackgroundColor: background,
      textTheme: GoogleFonts.nunitoTextTheme().copyWith(
        displayLarge: GoogleFonts.nunito(
          fontSize: 32, fontWeight: FontWeight.w800, color: textPrimary,
        ),
        displayMedium: GoogleFonts.nunito(
          fontSize: 26, fontWeight: FontWeight.w700, color: textPrimary,
        ),
        titleLarge: GoogleFonts.nunito(
          fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary,
        ),
        titleMedium: GoogleFonts.nunito(
          fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary,
        ),
        bodyLarge: GoogleFonts.nunito(
          fontSize: 15, fontWeight: FontWeight.w400, color: textPrimary,
        ),
        bodyMedium: GoogleFonts.nunito(
          fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary,
        ),
        labelLarge: GoogleFonts.nunito(
          fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black12,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      cardTheme: CardTheme(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: divider, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF0F2F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.nunito(color: textSecondary, fontSize: 14),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF0F2F8),
        selectedColor: primary.withOpacity(0.15),
        labelStyle: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }
}

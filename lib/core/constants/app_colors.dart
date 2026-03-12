import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette - Electric Teal
  static const Color primary = Color(0xFF00C896);
  static const Color primaryDark = Color(0xFF00A37A);
  static const Color primaryLight = Color(0xFF33D9A9);
  static const Color primarySurface = Color(0xFFE0FBF4);

  // Secondary palette - Deep Navy
  static const Color secondary = Color(0xFF1A1F3A);
  static const Color secondaryLight = Color(0xFF2D3561);

  // Accent
  static const Color accent = Color(0xFFFF6B35);
  static const Color accentLight = Color(0xFFFF8A5C);

  // Background
  static const Color background = Color(0xFFF5F7FA);
  static const Color backgroundDark = Color(0xFF0F1221);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E2340);
  static const Color cardDark = Color(0xFF252B4B);

  // Text
  static const Color textPrimary = Color(0xFF1A1F3A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color textLight = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Walk types
  static const Color soloWalk = Color(0xFF6366F1);
  static const Color groupWalk = Color(0xFFEC4899);

  // Zone colors (map overlays)
  static const Color zoneOwn = Color(0x4000C896);
  static const Color zoneFriend = Color(0x406366F1);
  static const Color zoneOverlap = Color(0x40EC4899);

  // Gradient presets
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00C896), Color(0xFF0097C4)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A1F3A), Color(0xFF0F1221)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF252B4B), Color(0xFF1E2340)],
  );

  static const LinearGradient soloGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
  );

  static const LinearGradient groupGradient = LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFFEF4444)],
  );

  // Border
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderDark = Color(0xFF374151);
  static const Color divider = Color(0xFFF3F4F6);
}

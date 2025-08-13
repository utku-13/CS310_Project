import 'package:flutter/material.dart';

class AppStyles {
  // Modern Color Palette
  static const Color primaryColor = Color(0xFF6366F1); // Indigo
  static const Color primaryLightColor = Color(0xFF818CF8);
  static const Color primaryDarkColor = Color(0xFF4F46E5);
  static const Color secondaryColor = Color(0xFF10B981); // Emerald
  static const Color accentColor = Color(0xFFF59E0B); // Amber
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textPrimaryColor = Color(0xFF1E293B);
  static const Color textSecondaryColor = Color(0xFF64748B);
  static const Color textLightColor = Color(0xFF94A3B8);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color infoColor = Color(0xFF3B82F6);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryLightColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondaryColor, Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentColor, Color(0xFFFBBF24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Spacing
  static const double defaultPadding = 20.0;
  static const double smallPadding = 12.0;
  static const double largePadding = 32.0;
  static const double extraLargePadding = 48.0;
  static const double borderRadius = 16.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 24.0;

  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // Typography
  static const TextStyle headingStyle = TextStyle(
    fontSize: 28.0,
    fontWeight: FontWeight.w700,
    color: textPrimaryColor,
    letterSpacing: -0.5,
  );

  static const TextStyle headingMediumStyle = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
    letterSpacing: -0.3,
  );

  static const TextStyle headingSmallStyle = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
    letterSpacing: -0.2,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    color: textPrimaryColor,
    height: 1.5,
  );

  static const TextStyle bodyMediumStyle = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: textSecondaryColor,
    height: 1.4,
  );

  static const TextStyle bodySmallStyle = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    color: textLightColor,
    height: 1.3,
  );

  static const TextStyle buttonStyle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    color: textSecondaryColor,
    letterSpacing: 0.5,
  );

  // Input Decoration
  static InputDecoration textFieldDecoration(String label, {String? hint, IconData? prefixIcon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: textSecondaryColor) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: textLightColor.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: textLightColor.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: smallPadding,
      ),
      filled: true,
      fillColor: surfaceColor,
      labelStyle: bodyMediumStyle.copyWith(color: textSecondaryColor),
      hintStyle: bodyMediumStyle.copyWith(color: textLightColor),
    );
  }

  // Button Styles
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(
      horizontal: defaultPadding,
      vertical: smallPadding,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    ),
    elevation: 0,
    shadowColor: primaryColor.withOpacity(0.3),
  );

  static ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.transparent,
    foregroundColor: primaryColor,
    padding: const EdgeInsets.symmetric(
      horizontal: defaultPadding,
      vertical: smallPadding,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      side: const BorderSide(color: primaryColor, width: 2),
    ),
    elevation: 0,
  );

  static ButtonStyle outlineButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: textSecondaryColor,
    padding: const EdgeInsets.symmetric(
      horizontal: defaultPadding,
      vertical: smallPadding,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    ),
    side: BorderSide(color: textLightColor.withOpacity(0.3)),
  );

  // Card Decoration
  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(borderRadius),
    boxShadow: cardShadow,
  );

  static BoxDecoration elevatedCardDecoration = BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(borderRadius),
    boxShadow: elevatedShadow,
  );
} 
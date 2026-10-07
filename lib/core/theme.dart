import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

class RuslTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.urbanistTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: RuslColors.bgCream,
      primaryColor: RuslColors.accentYellow,
      colorScheme: const ColorScheme.light(
        primary: RuslColors.accentYellow,
        onPrimary: RuslColors.darkText,
        surface: RuslColors.pureWhite,
        onSurface: RuslColors.darkText,
        outline: RuslColors.borderGrey,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.urbanist(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: RuslColors.darkText,
          height: 1.2,
        ),
        displayMedium: GoogleFonts.urbanist(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: RuslColors.darkText,
          height: 1.2,
        ),
        headlineMedium: GoogleFonts.urbanist(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: RuslColors.darkText,
        ),
        titleLarge: GoogleFonts.urbanist(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: RuslColors.darkText,
        ),
        titleMedium: GoogleFonts.urbanist(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: RuslColors.darkText,
        ),
        bodyLarge: GoogleFonts.urbanist(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: RuslColors.darkText,
        ),
        bodyMedium: GoogleFonts.urbanist(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: RuslColors.textMuted,
        ),
        labelLarge: GoogleFonts.urbanist(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: RuslColors.darkText,
        ),
      ),
      cardTheme: CardThemeData(
        color: RuslColors.pureWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: RuslColors.borderGrey, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: RuslColors.pureWhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: RuslColors.borderGrey, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: RuslColors.borderGrey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: RuslColors.darkText, width: 1.8),
        ),
        hintStyle: GoogleFonts.urbanist(
          fontSize: 14,
          color: RuslColors.textMuted,
          fontWeight: FontWeight.w400,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: RuslColors.accentYellow,
          foregroundColor: RuslColors.darkText,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: GoogleFonts.urbanist(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: RuslColors.darkText,
          side: const BorderSide(color: RuslColors.borderGrey, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: GoogleFonts.urbanist(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

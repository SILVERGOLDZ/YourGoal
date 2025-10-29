import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    textTheme: GoogleFonts.nunitoSansTextTheme(),
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.active),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        return TextStyle(
          fontSize: 12,
          fontWeight:
          states.contains(WidgetState.selected)
              ? FontWeight.w600
              : FontWeight.normal,
          color: states.contains(WidgetState.selected)
              ? AppColors.active
              : AppColors.inactive,
        );
      }),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    textTheme: GoogleFonts.nunitoSansTextTheme(),
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.active),

    //Untuk InputForm RegisterLogin
    inputDecorationTheme: const InputDecorationTheme(
      // Properti dari template Anda
      filled: true,
      fillColor: Colors.white, // const Color(0xffffffff)
      labelStyle: TextStyle(
          color: Color(0x80484848)), // Warna label dari template Anda

      // Menggunakan borderRadius 10 dari template Anda
      // dan menghapus border saat tidak difokus (enabled)
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide.none, // Hapus border default
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide.none, // Hapus border saat enabled
      ),

      // Tetap gunakan border aktif saat difokus
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: AppColors.active, width: 2.0),
      ),

      // Atur style label saat di-fokus
      floatingLabelStyle: TextStyle(color: AppColors.active),
      prefixIconColor: AppColors.inactive,
      suffixIconColor: AppColors.inactive,
    ),


    //Untuk NavigationBar
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

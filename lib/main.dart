import 'package:flutter/material.dart';
import 'package:tes/ReusableWidget/navigation_widget.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //untuk color navbar
    const Color warnaAktif = Color(0xFF137FEC); // Warna kustom Anda
    const Color warnaNonAktif =  Color(0xFF6C6C6C); // Warna untuk yang tidak dipilih
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.nunitoSansTextTheme(
          Theme.of(context).textTheme,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF137FEC)),
        // ini kebawah mengatur tema untuk NavigationBar
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          //  Ini mengatur WARNA LABEL (Menggunakan WidgetStateProperty) ---
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
                (Set<WidgetState> states) { // <-- Menggunakan WidgetState
              // Cek apakah state-nya "selected" (dipilih)
              if (states.contains(WidgetState.selected)) { // <-- Menggunakan WidgetState
                // Jika DIPILIH
                return const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: warnaAktif, // <-- Gunakan warna aktif Anda
                );
              } else {
                // Jika TIDAK DIPILIH
                return const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: warnaNonAktif, // <-- Gunakan warna non-aktif
                );
              }
            },
          ),
        ),
      ),

      // 2. Panggil "Wadah" Anda sebagai home
      home: const navigation_widget(),
    );
  }
}


/*
INI SIH GUNANYA UNTUK BIAR NOTCH BAR (KALO HP NYA ADA NOTCH BIAR TRANSPARAN
DAN SESUAI DENGAN BACKGROUND APLIKASI HALAMAN YANG DIPILIH)
*/

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tes/ReusableWidget/mygoal_background.dart';

class BasePage extends StatelessWidget {
  final Widget child;

  const BasePage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent, // Transparent status bar
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Make Scaffold transparent
        extendBodyBehindAppBar: true, // Allow behind system UI
        body: Stack(
          children: [
            MyGoalBackground(
              child: SizedBox.expand(), // This becomes your background
            ),
            SafeArea(
              child: child, // Content for the next implementation
            ),
          ],
        ),
      ),
    );
  }
}

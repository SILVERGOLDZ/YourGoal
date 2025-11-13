/*
KALO INI BIAR BLENDING COLOR BACKGROUND NYA SESUAI FIGMA YANG WARNA BIRU
*/
import 'package:flutter/material.dart';

class MyGoalBackground extends StatelessWidget {
  // Tambahkan child agar widget lain bisa dimasukkan ke dalamnya
  final Widget? child;

  const MyGoalBackground({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1E89EF),
                Color(0xFFDDE8FF),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 1.0],
            ),
          ),
        ),

        // Lapisan 2: Overlay Warna Solid
        Container(
          color: const Color(0x80F6F7F8), // 0x80 = 50% opacity
        ),


        // Tampilkan konten yang dilewatkan
        if (child != null) child!,
      ],
    );
  }
}

/*

| Opacity | HEX | Example      |
| ------- | --- | ------------ |
| 100%    | FF  | `0xFFF6F7F8` |
| 75%     | BF  | `0xBFF6F7F8` |
| 50%     | 80  | `0x80F6F7F8` |
| 30%     | 4D  | `0x4DF6F7F8` |
| 10%     | 1A  | `0x1AF6F7F8` |

 */
import 'package:flutter/material.dart';
import 'package:tes/ReusableWidget/navigation_widget.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),

      // 2. Panggil "Wadah" Anda sebagai home
      home: const navigation_widget(),
    );
  }
}


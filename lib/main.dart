import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'package:tes/pages/Login&Register/Register.dart'; // ✅ Impor RegisterPage

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
      theme: AppTheme.lightTheme, // ✅ theme is cleanly separated
      home: const RegisterPage(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:tes/ReusableWidget/navigation_widget.dart';
import 'theme/app_theme.dart';
import 'ReusableWidget/navigation_widget.dart';

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
      home: const navigation_widget(),
    );
  }
}

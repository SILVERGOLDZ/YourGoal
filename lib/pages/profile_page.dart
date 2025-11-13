import 'package:flutter/material.dart';
import 'package:tes/Widget/base_page.dart'; //bg color + transparent status bar with safe area

// Gunakan PascalCase untuk nama class (ProfilePage)
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BasePage(
        child: Center(
          child: Text(
            'Ini Halaman Profil',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}

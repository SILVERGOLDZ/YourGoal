import 'package:flutter/material.dart';

// Gunakan PascalCase untuk nama class (ProfilePage)
class Profile_page extends StatelessWidget {
  const Profile_page({super.key});

  @override
  Widget build(BuildContext context) {

    return const Center(
      child: Text(
        'Ini Halaman Profil',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

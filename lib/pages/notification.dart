import 'package:flutter/material.dart';
import 'package:tes/Widget/base_page.dart'; //bg color + transparent status bar with safe area


class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BasePage(
        child: ListView(
          padding: const EdgeInsets.all(16.0), // 'const' di sini OK

          // 1. HAPUS 'const' dari list ini
          children: <Widget>[

            // 2. TAMBAHKAN 'const' ke widget individual yang bisa
            const Center(
              child: Text(
                'Notification',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Today',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // 3. Biarkan widget yang TIDAK const (seperti Card dan Image.asset)
            //    tanpa 'const' di depannya.
            Card(
              child: ListTile(
                leading: Image.asset( // <-- Tidak ada 'const' di sini
                  'assets/images/Notification_widget_logo.png',
                  width: 40,
                  height: 40,
                ),
                title: const Text('Daily Grind'), // <-- Tambah 'const'
                subtitle: const Text('12:00 A.M'), // <-- Tambah 'const'
              ),
            ),
            Card(
              child: ListTile(
                leading: Image.asset( // <-- Tidak ada 'const' di sini
                  'assets/images/Notification_widget_logo.png',
                  width: 40,
                  height: 40,
                ),
                title: const Text('Someone Liked Your Post'), // <-- Tambah 'const'
                subtitle: const Text('10:00 A.M'), // <-- Tambah 'const'
              ),
            ),

            const Text(
              'Yesterday',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // 3. Biarkan widget yang TIDAK const (seperti Card dan Image.asset)
            //    tanpa 'const' di depannya.
            Card(
              child: ListTile(
                leading: Image.asset( // <-- Tidak ada 'const' di sini
                  'assets/images/Opened_Notification_widget_logo.png',
                  width: 40,
                  height: 40,
                ),
                title: const Text('Daily Grind'), // <-- Tambah 'const'
                subtitle: const Text('12:00 A.M'), // <-- Tambah 'const'
              ),
            ),
            Card(
              child: ListTile(
                leading: Image.asset( // <-- Tidak ada 'const' di sini
                  'assets/images/Opened_Notification_widget_logo.png',
                  width: 40,
                  height: 40,
                ),
                title: const Text('Someone Liked Your Post'), // <-- Tambah 'const'
                subtitle: const Text('10:00 A.M'), // <-- Tambah 'const'
              ),
            ),

            // ...dan seterusnya...
          ],
        ),
      ),
    );
  }
}

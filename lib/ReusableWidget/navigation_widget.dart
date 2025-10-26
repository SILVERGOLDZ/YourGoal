import 'package:flutter/material.dart';
import 'package:tes/pages/notification.dart';
import 'package:tes/pages/home_page.dart';
import 'package:tes/pages/MyGoal_page.dart';
import 'package:tes/pages/Profile_page.dart';

class navigation_widget extends StatefulWidget {
  const navigation_widget({super.key});

  @override
  State<navigation_widget> createState() => _navigation_widgetState();
}

// Ganti nama class dari _MyHomePageState menjadi _MainNavigationShellState
class _navigation_widgetState extends State<navigation_widget> {
  // 2. Semua state tetap di sini
  int _counter = 0;
  int currentPageIndex = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    // 3. Buat daftar "Isi", tapi sekarang panggil class-nya
    final List<Widget> pages = [
      // Berikan state _counter ke HomePage
      HomePage(counterValue: _counter),
      const MyGoal_page(),
      const notification(),
      const Profile_page(),
    ];

    // 4. Seluruh Scaffold tetap di sini
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.inversePrimary,
        title: const Text('bagaimana buat latar birunya?'), // Ganti judul jika perlu
      ),

      // 5. Body sekarang memanggil 'pages'
      body: pages[currentPageIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.transparent,
        selectedIndex: currentPageIndex,
        destinations: <Widget>[
          NavigationDestination( // <-- Item ini TIDAK const (karena Image.asset)
            selectedIcon: Image.asset(
              'assets/images/Dashboard_logo.png',
              width: 24,
              height: 24,
              color: const Color(0xFF137FEC),
            ),
            icon: Image.asset(
              'assets/images/Dashboard_logo.png',
              width: 24, // Jangan lupa atur ukuran
              height: 24,
            ),
            label: 'Dashboard',
          ),
          NavigationDestination( // <-- Item ini TIDAK const (karena Image.asset)
            selectedIcon: Image.asset(
              'assets/images/My_Goal_Logo.png',
              width: 24,
              height: 24,
              color: const Color(0xFF137FEC),
            ),
            icon: Image.asset(
              'assets/images/My_Goal_Logo.png',
              width: 24, // Jangan lupa atur ukuran
              height: 24,
            ),
            label: 'My Goal',
          ),
          NavigationDestination( // <-- Item ini TIDAK const (karena Image.asset)
            selectedIcon: Image.asset(
              'assets/images/Notification_logo.png',
              width: 24,
              height: 24,
              color: const Color(0xFF137FEC),
            ),
            icon: Image.asset(
              'assets/images/Notification_logo.png',
              width: 24, // Jangan lupa atur ukuran
              height: 24,
            ),
            label: 'Notifications',
          ),
          NavigationDestination( // <-- Item ini TIDAK const (karena Image.asset)
            selectedIcon: Image.asset(
              'assets/images/profile_logo.png',
              width: 24,
              height: 24,
              color: const Color(0xFF137FEC),
            ),
            icon: Image.asset(
              'assets/images/profile_logo.png',
              width: 24, // Jangan lupa atur ukuran
              height: 24,
            ),
            label: 'Profile',
          ),
        ],
      ),

      // 6. FAB kondisional tetap di sini
      floatingActionButton: currentPageIndex == 0
          ? FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}
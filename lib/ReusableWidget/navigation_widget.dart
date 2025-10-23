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
        title: const Text('My App Shell'), // Ganti judul jika perlu
      ),

      // 5. Body sekarang memanggil 'pages'
      body: pages[currentPageIndex],

      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Badge(child: Icon(Icons.notifications_sharp)),
            label: 'My Goal',
          ),
          NavigationDestination(
            icon: Badge(child: Icon(Icons.notifications_sharp)),
            label: 'Notifications',
          ),
          NavigationDestination(
            icon: Badge(label: Text('2'), child: Icon(Icons.messenger_sharp)),
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
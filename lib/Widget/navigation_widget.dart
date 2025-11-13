import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../config/routes.dart';

class BottomNavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const BottomNavigationShell({super.key, required this.navigationShell});

  void _onItemTapped(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final currentIndex = navigationShell.currentIndex;
    final bool isMobile = screenWidth < 600;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;

        final String currentLocation = GoRouterState.of(context).uri.path;

        if (currentLocation == AppRoutes.home) {
          // Show exit confirmation dialog
          final shouldExit = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Exit App'),
              content: const Text('Are you sure you want to exit?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Exit'),
                ),
              ],
            ),
          );

          // Exit app if user confirmed
          if (shouldExit == true) {
            SystemNavigator.pop();
          }
        } else {
          if (GoRouter.of(context).canPop()) {
            GoRouter.of(context).pop();
          } else {
            context.go(AppRoutes.home);
          }
        }
      },
      child: SafeArea(
        top: false,
        child: Scaffold(
          body: isMobile
              ? navigationShell
              : Row(
            children: [
              // Sidebar navigation for desktop
              _buildSidebar(context, currentIndex, screenWidth, screenHeight),
              // Main content
              Expanded(child: navigationShell),
            ],
          ),
          extendBody: true,
          bottomNavigationBar: isMobile
              ? Container(
            decoration: const BoxDecoration(
              color: Color(0xffffffff),
              border: Border(
                top: BorderSide(
                  color: Colors.grey,
                  width: 1.0,
                )
              )
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [

                //TODO: BUAT ICONNYA SESUAI DENGAN PAGE TUJUAN
                _buildNavItem(
                  context,
                  0,
                  'assets/images/Dashboard_logo.png',
                  'Home',
                  currentIndex,
                  screenWidth,
                  screenHeight,
                ),

                _buildNavItem(
                  context,
                  1,
                  'assets/images/My_Goal_Logo.png',
                  'mygoal',
                  currentIndex,
                  screenWidth,
                  screenHeight,
                ),

                _buildNavItem(
                  context,
                  2,
                  'assets/images/Notification_logo.png',
                  'notifications',
                  currentIndex,
                  screenWidth,
                  screenHeight,
                ),

                _buildNavItem(
                  context,
                  3,
                  'assets/images/profile_logo.png',
                  'profile',
                  currentIndex,
                  screenWidth,
                  screenHeight,
                ),

              ],
            ),
          )
              : null,
        ),
      ),
    );
  }

  Widget _buildSidebar(
      BuildContext context,
      int currentIndex,
      double screenWidth,
      double screenHeight,
      ) {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: Color(0xFF702e46),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(height: screenHeight * 0.05),
          // App title or logo (optional)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'Navigation',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(color: Colors.white24, thickness: 1),
          SizedBox(height: 20),
          // Navigation items
          //TODO: ICON UBAH MENJADI SESUAI
          _buildSidebarItem(
            context,
            0,
            Icons.home_rounded,
            'Home',
            currentIndex,
          ),
          _buildSidebarItem(
            context,
            1,
            Icons.grading,
            'mygoal',
            currentIndex,
          ),
          _buildSidebarItem(
            context,
            2,
            Icons.grading,
            'notifications',
            currentIndex,
          ),
          _buildSidebarItem(
            context,
            3,
            Icons.grading,
            'profile',
            currentIndex,
          ),
          const Spacer(),
        ],
      ),
    );
  }


  //TODO: UBAH AGAR TAMPILAN PAGE AKTIF MENJADI SESUAI FIGMA!
  Widget _buildSidebarItem(
      BuildContext context,
      int index,
      IconData icon,
      String label,
      int currentIndex,
      ) {
    final isActive = index == currentIndex;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onItemTapped(context, index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xffa64267) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isActive ? Colors.white : Colors.grey.shade400,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.grey.shade400,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context,
      int index,
      String image,
      String label,
      int currentIndex,
      double screenWidth,
      double screenHeight,
      ) {
    final isActive = index == currentIndex;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onItemTapped(context, index),
      child: Container(
        width: screenWidth / 4,
        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                image, // ✅ correct usage
                color: isActive ? Colors.blue : Colors.grey.shade600,
                width: 20,
                height: 20,
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: screenWidth * 0.03,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:tes/pages/notification.dart';
// import 'package:tes/pages/home_page.dart';
// import 'package:tes/pages/mygoal_page.dart';
// import 'package:tes/pages/profile_page.dart';
//
// class navigation_widget extends StatefulWidget {
//   const navigation_widget({super.key});
//
//   @override
//   State<navigation_widget> createState() => _navigation_widgetState();
// }
//
// // Ganti nama class dari _MyHomePageState menjadi _MainNavigationShellState
// class _navigation_widgetState extends State<navigation_widget> {
//   // 2. Semua state tetap di sini
//   int _counter = 0;
//   int currentPageIndex = 0;
//
//   void _incrementCounter() {
//     setState(() {
//       _counter++;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final ThemeData theme = Theme.of(context);
//
//     // 3. Buat daftar "Isi", tapi sekarang panggil class-nya
//     final List<Widget> pages = [
//       // Berikan state _counter ke HomePage
//       HomePage(counterValue: _counter),
//       const MyGoalPage(),
//       const NotificationPage(),
//       const ProfilePage(),
//     ];
//
//     // 4. Seluruh Scaffold tetap di sini
//     return Scaffold(
//       // appBar: AppBar(
//       //   backgroundColor: theme.colorScheme.inversePrimary,
//       //   title: const Text('bagaimana buat latar birunya?'), // Ganti judul jika perlu
//       // ),
//
//       // 5. Body sekarang memanggil 'pages'
//       body: pages[currentPageIndex],
//       bottomNavigationBar: NavigationBar(
//         onDestinationSelected: (int index) {
//           setState(() {
//             currentPageIndex = index;
//           });
//         },
//         indicatorColor: Colors.transparent,
//         selectedIndex: currentPageIndex,
//         destinations: <Widget>[
//           NavigationDestination( // <-- Item ini TIDAK const (karena Image.asset)
//             selectedIcon: Image.asset(
//               'assets/images/Dashboard_logo.png',
//               width: 24,
//               height: 24,
//               color: const Color(0xFF137FEC),
//             ),
//             icon: Image.asset(
//               'assets/images/Dashboard_logo.png',
//               width: 24, // Jangan lupa atur ukuran
//               height: 24,
//             ),
//             label: 'Dashboard',
//           ),
//           NavigationDestination( // <-- Item ini TIDAK const (karena Image.asset)
//             selectedIcon: Image.asset(
//               'assets/images/My_Goal_Logo.png',
//               width: 24,
//               height: 24,
//               color: const Color(0xFF137FEC),
//             ),
//             icon: Image.asset(
//               'assets/images/My_Goal_Logo.png',
//               width: 24, // Jangan lupa atur ukuran
//               height: 24,
//             ),
//             label: 'My Goal',
//           ),
//           NavigationDestination( // <-- Item ini TIDAK const (karena Image.asset)
//             selectedIcon: Image.asset(
//               'assets/images/Notification_logo.png',
//               width: 24,
//               height: 24,
//               color: const Color(0xFF137FEC),
//             ),
//             icon: Image.asset(
//               'assets/images/Notification_logo.png',
//               width: 24, // Jangan lupa atur ukuran
//               height: 24,
//             ),
//             label: 'Notifications',
//           ),
//           NavigationDestination( // <-- Item ini TIDAK const (karena Image.asset)
//             selectedIcon: Image.asset(
//               'assets/images/profile_logo.png',
//               width: 24,
//               height: 24,
//               color: const Color(0xFF137FEC),
//             ),
//             icon: Image.asset(
//               'assets/images/profile_logo.png',
//               width: 24, // Jangan lupa atur ukuran
//               height: 24,
//             ),
//             label: 'Profile',
//           ),
//         ],
//       ),
//
//       // 6. FAB kondisional tetap di sini
//       floatingActionButton: currentPageIndex == 0
//           ? FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       )
//           : null,
//     );
//   }
// }
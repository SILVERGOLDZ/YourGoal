import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../config/routes.dart';

class BottomNavigationShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const BottomNavigationShell({super.key, required this.navigationShell});

  @override
  State<BottomNavigationShell> createState() => _BottomNavigationShellState();
}

class _BottomNavigationShellState extends State<BottomNavigationShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSidebarExpanded = false;

  void _onItemTapped(BuildContext context, int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
    // Close drawer on tablet after navigation
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final currentIndex = widget.navigationShell.currentIndex;
    final bool isMobile = screenWidth < 600;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1080;
    final bool isDesktop = screenWidth >= 1080;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;

        final String currentLocation = GoRouterState.of(context).uri.path;

        if (currentLocation == AppRoutes.home) {
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
          key: _scaffoldKey,
          body: isMobile
              ? widget.navigationShell
              : Row(
            children: [
              if (isTablet)
                _buildTabletSidebar(
                  context,
                  currentIndex,
                  screenHeight,
                ),
              if (isDesktop)
                MouseRegion(
                  onEnter: (_) {
                    setState(() {
                      _isSidebarExpanded = true;
                    });
                  },
                  onExit: (_) {
                    setState(() {
                      _isSidebarExpanded = false;
                    });
                  },
                  child: _buildDesktopSidebar(
                    context,
                    currentIndex,
                    screenHeight,
                  ),
                ),
              Expanded(
                child: widget.navigationShell,
              ),
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
                ),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      context,
                      0,
                      'assets/images/explore.png',
                      'Explore',
                      currentIndex,
                      screenWidth,
                    ),
                    _buildNavItem(
                      context,
                      1,
                      'assets/images/My_Goal_Logo.png',
                      'Home',
                      currentIndex,
                      screenWidth,
                    ),
                    _buildNavItem(
                      context,
                      2,
                      'assets/images/Notification_logo.png',
                      'Notifications',
                      currentIndex,
                      screenWidth,
                    ),
                    _buildNavItem(
                      context,
                      3,
                      'assets/images/profile_logo.png',
                      'Profile',
                      currentIndex,
                      screenWidth,
                    ),
                  ],
                ),
              ),
            ),
          )
              : null,
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
      ) {
    final isActive = index == currentIndex;

    return Flexible(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onItemTapped(context, index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                image,
                color: isActive ? Colors.blue : Colors.grey.shade600,
                width: 24,
                height: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.blue : Colors.grey,
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabletSidebar(
      BuildContext context,
      int currentIndex,
      double screenHeight,
      ) {
    return Container(
      width: 250,
      height: double.infinity,
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
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.all(20.0),
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
            const SizedBox(height: 10),
            _buildDrawerItem(
              context,
              0,
              'assets/images/explore.png',
              'Explore',
              currentIndex,
            ),
            _buildDrawerItem(
              context,
              1,
              'assets/images/My_Goal_Logo.png',
              'Home',
              currentIndex,
            ),
            _buildDrawerItem(
              context,
              2,
              'assets/images/Notification_logo.png',
              'Notifications',
              currentIndex,
            ),
            _buildDrawerItem(
              context,
              3,
              'assets/images/profile_logo.png',
              'Profile',
              currentIndex,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletDrawer(
      BuildContext context,
      int currentIndex,
      double screenHeight,
      ) {
    return Container(
      color: const Color(0xFF702e46),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.all(20.0),
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
            const SizedBox(height: 10),
            _buildDrawerItem(
              context,
              0,
              'assets/images/explore.png',
              'Explore',
              currentIndex,
            ),
            _buildDrawerItem(
              context,
              1,
              'assets/images/My_Goal_Logo.png',
              'Home',
              currentIndex,
            ),
            _buildDrawerItem(
              context,
              2,
              'assets/images/Notification_logo.png',
              'Notifications',
              currentIndex,
            ),
            _buildDrawerItem(
              context,
              3,
              'assets/images/profile_logo.png',
              'Profile',
              currentIndex,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context,
      int index,
      String image,
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
                Image.asset(
                  image,
                  color: Colors.white,
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopSidebar(
      BuildContext context,
      int currentIndex,
      double screenHeight,
      ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _isSidebarExpanded ? 250 : 80,
      height: double.infinity,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          _buildSidebarItem(
            context,
            0,
            'assets/images/explore.png',
            'Explore',
            currentIndex,
          ),
          _buildSidebarItem(
            context,
            1,
            'assets/images/My_Goal_Logo.png',
            'Home',
            currentIndex,
          ),
          _buildSidebarItem(
            context,
            2,
            'assets/images/Notification_logo.png',
            'Notifications',
            currentIndex,
          ),
          _buildSidebarItem(
            context,
            3,
            'assets/images/profile_logo.png',
            'Profile',
            currentIndex,
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
      BuildContext context,
      int index,
      String image,
      String label,
      int currentIndex,
      ) {
    final isActive = index == currentIndex;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onItemTapped(context, index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xffa64267) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Image.asset(
                  image,
                  color: Colors.white,
                  width: 28,
                  height: 28,
                ),
                if (_isSidebarExpanded) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
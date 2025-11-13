import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/Widget/navigation_widget.dart';
import '/pages/home_page.dart';
import '/pages/mygoal_page.dart';
import '/pages/notification.dart';
import '/pages/profile_page.dart';
import '/pages/Login&Register/login.dart';
import '/pages/Login&Register/register.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String notification = '/notification';
  static const String mygoal = '/mygoal';
  static const String home = '/home';
  static const String profile = '/profile';
}

GoRouter createRouter() {
  final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.login,
    routes: [
      GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => RegisterPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return BottomNavigationShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: 'home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.mygoal,
                name: 'mygoal',
                builder: (context, state) => const MyGoalPage(),
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.notification,
                name: 'notification',
                builder: (context, state) => const NotificationPage(),
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: 'profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              '404 - Page Not Found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text('Path: ${state.uri.path}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
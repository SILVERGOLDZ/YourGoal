import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../pages/collection.dart';
import '/Widget/navigation_widget.dart';
import '/pages/home_page.dart';
import '/pages/mygoal_page.dart';
import '/pages/notification.dart';
import '/pages/profile_page.dart';
import '/pages/Login&Register/login.dart';
import '/pages/Login&Register/register.dart';
import '/pages/email_verification_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String notification = '/notification';
  static const String mygoal = '/mygoal';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String verifyEmail = '/verify-email';
  static const String collection = '/collection';
}

GoRouter createRouter(Stream<User?> authStream) {
  final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

  final publicRoutes = [
    AppRoutes.login,
    AppRoutes.register,
  ];

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.login,
    refreshListenable: GoRouterRefreshStream(authStream),

    // UPDATE REDIRECT LOGIC
    redirect: (BuildContext context, GoRouterState state) {
      final user = FirebaseAuth.instance.currentUser;
      final bool loggedIn = user != null;
      final String location = state.uri.toString();
      final bool isGoingToPublicRoute = publicRoutes.contains(location);

      // 1. Jika TIDAK Login & mau ke Private -> Lempar ke Login
      if (!loggedIn && !isGoingToPublicRoute && location != AppRoutes.verifyEmail) {
        return AppRoutes.login;
      }

      // 2. Jika SUDAH Login
      if (loggedIn) {
        // Email Verification Logic
        if (!user.emailVerified && location != AppRoutes.verifyEmail) {
          return AppRoutes.verifyEmail;
        }

        if (user.emailVerified && location == AppRoutes.verifyEmail) {
          return AppRoutes.home;
        }

        // Jika mau ke halaman Login/Register padahal sudah login -> Lempar ke Home
        if (isGoingToPublicRoute) {
          return AppRoutes.home;
        }
      }

      return null;
    },

    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) {
          // Tidak ada extra data lagi
          return const RegisterPage();
        },
      ),
      GoRoute(
        path: AppRoutes.verifyEmail,
        name: 'verifyEmail',
        builder: (context, state) => const EmailVerificationPage(),
      ),
      GoRoute(
        path: AppRoutes.collection,
        name: 'collection',
        builder: (context, state) => const CollectionPage(),
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
        child: Text('Page Not Found: ${state.uri.path}'),
      ),
    ),
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    stream.asBroadcastStream().listen((_) => notifyListeners());
  }
}
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tes/pages/collection.dart';
import 'package:tes/pages/edit_profile_page.dart';
import 'package:tes/pages/settings_page.dart';
import 'package:tes/Widget/navigation_widget.dart';
import 'package:tes/pages/home_page.dart';
import 'package:tes/pages/mygoal_page.dart';
import 'package:tes/pages/notification.dart';
import 'package:tes/pages/profile_page.dart';
import 'package:tes/pages/Login&Register/login.dart';
import 'package:tes/pages/Login&Register/register.dart';
import 'package:tes/pages/email_verification_page.dart';
import 'package:tes/pages/mygoal_subpage/newgoal_page.dart';
import 'package:tes/pages/Login&Register/forgot_password_page.dart';

import '../pages/mygoal_subpage/detailscreen_page.dart';
import '../services/goaldata_service.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String notification = '/notification';
  static const String mygoal = '/mygoal';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String verifyEmail = '/verify-email';
  static const String newgoal = '/newgoal';
  static const String collection = '/collection';
  static const String forgotPassword = '/forgot-password';
  static const String editProfile = '/edit-profile';
  static const String goalDetail = '/goal-detail';
}

GoRouter createRouter(Stream<User?> authStream) {
  final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

  final publicRoutes = [
    AppRoutes.login,
    AppRoutes.register,
    AppRoutes.forgotPassword,
  ];

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.login,
    refreshListenable: GoRouterRefreshStream(authStream),

    redirect: (BuildContext context, GoRouterState state) {
      final user = FirebaseAuth.instance.currentUser;
      final bool loggedIn = user != null;
      final String location = state.uri.toString();
      final bool isGoingToPublicRoute = publicRoutes.contains(location);

      if (!loggedIn && !isGoingToPublicRoute && location != AppRoutes.verifyEmail) {
        return AppRoutes.login;
      }

      if (loggedIn) {
        if (!user.emailVerified && location != AppRoutes.verifyEmail) {
          return AppRoutes.verifyEmail;
        }

        if (user.emailVerified && location == AppRoutes.verifyEmail) {
          return AppRoutes.home;
        }

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
          return const RegisterPage();
        },
      ),
      GoRoute(
        path: AppRoutes.verifyEmail,
        name: 'verifyEmail',
        builder: (context, state) => const EmailVerificationPage(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        name: 'editProfile',
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.newgoal,
        name: 'newgoal',
        builder: (context, state) => const NewRoadmapScreen(),
      ),
      GoRoute(
        path: AppRoutes.goalDetail,
        name: 'goalDetail',
        builder: (context, state) {
          RoadmapModel? roadmap = state.extra as RoadmapModel?;
          return RoadmapDetailScreen(roadmap: roadmap);
        },
      ),
      GoRoute(
        path: AppRoutes.collection,
        name: 'collection',
        builder: (context, state) => const CollectionPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordPage(),
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

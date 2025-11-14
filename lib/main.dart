import 'package:flutter/material.dart';
import 'package:tes/config/routes.dart';
import 'package:tes/theme/app_theme.dart';
import 'package:tes/auth_service.dart'; // Import AuthService

//firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase with the default options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // Create an instance of AuthService to get the auth stream
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'YourGoal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Pass the auth stream to the router
      routerConfig: createRouter(_authService.authStateChanges),
    );
  }
}
import 'package:flutter/material.dart';

// 1. Define a GlobalKey to access the ScaffoldMessenger from anywhere
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

// 2. Update function to remove 'BuildContext' argument
void showSnackBar(String message, {bool isError = false}) {
  // Use the key to find the global messenger state
  final messenger = rootScaffoldMessengerKey.currentState;

  if (messenger != null) {
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.red : Colors.black,
        behavior: SnackBarBehavior.floating, // Makes it float above navigation bars
        margin: const EdgeInsets.all(16), // Adds some spacing
      ),
    );
  }
}
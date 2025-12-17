import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tes/utils/snackbar_helper.dart';
// Make sure this import exists for colors, or replace AppColors.active with Colors.blue etc.
import 'package:tes/theme/colors.dart';
// If you don't have AuthService, you can use FirebaseAuth directly for logout
import 'package:tes/services/auth/auth_service.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  // --- LOGIC VARIABLES (From File 1) ---
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;
  // Additional variable for UI loading during logout/other actions if needed
  final bool _isPerformingAction = false;

  @override
  void initState() {
    super.initState();

    // --- LOGIC INIT (From File 1) ---

    // Check if the user's email is verified when the page is first opened
    isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;

    // If the email is not verified, send a verification email
    if (!isEmailVerified) {
      sendVerificationEmail();

      // Start a timer to check the verification status every 3 seconds
      timer = Timer.periodic(
        const Duration(seconds: 3),
            (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    // --- LOGIC DISPOSE (From File 1) ---
    timer?.cancel();
    super.dispose();
  }

  /// Checks the user's email verification status periodically.
  /// (Exact logic from File 1)
  Future<void> checkEmailVerified() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Reload user data from Firebase to get the latest status
    await user.reload();
    user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    final isVerifiedNow = user?.emailVerified ?? false;

    // Update state so the UI can change if needed (e.g. removing a button)
    if (isVerifiedNow != isEmailVerified) {
      setState(() {
        isEmailVerified = isVerifiedNow;
      });
    }

    if (isVerifiedNow) {
      timer?.cancel();

      // Navigate to the 'home' page and send the 'extra' parameter
      // According to file 1 logic
      context.goNamed('home', extra: {'showVerificationSuccess': true});
    }
  }

  /// Sends a verification email to the user.
  /// (Exact logic from File 1: 5 second delay)
  Future<void> sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      if (mounted) {
        showSnackBar("Verification email sent");
      }

      // Logic: disable the button for 5 seconds
      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(seconds: 5));

      if (mounted) {
        setState(() => canResendEmail = true);
      }
    } catch (e) {
      if (mounted) {
        showSnackBar("Error: ${e.toString()}", isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fallback if already verified (From File 1 + Loading Design)
    if (isEmailVerified) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // --- UI DESIGN (From File 2) ---
    return PopScope(
      canPop: false, // Prevents back button
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // New Design Icon
                const Icon(
                  Icons.mark_email_unread_outlined,
                  size: 100,
                  color: AppColors.active, // Make sure AppColors is imported or change to Colors.blue
                ),
                const SizedBox(height: 30),

                // New Design Title
                const Text(
                  'Verify Your Email',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Description with User Email
                Text(
                  'We have sent a verification link to the email:\n${FirebaseAuth.instance.currentUser?.email}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 30),

                // "I Have Verified" Button (Manual Check)
                // Using the checkEmailVerified function from Logic 1
                ElevatedButton.icon(
                  onPressed: checkEmailVerified,
                  icon: const Icon(Icons.refresh),
                  label: const Text('I Have Verified'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
                const SizedBox(height: 16),

                // "Resend Email" Button
                // Using canResendEmail logic from Logic 1
                TextButton(
                  onPressed: canResendEmail ? sendVerificationEmail : null,
                  child: Text(
                    canResendEmail ? 'Resend Email' : 'Please wait...',
                    style: TextStyle(
                      color: canResendEmail ? AppColors.active : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Logout Button
                // Added to match the design, standard logout logic
                TextButton.icon(
                  onPressed: () async {
                    // Use AuthService if available, or FirebaseAuth directly
                    try {
                      await FirebaseAuth.instance.signOut();
                      // AuthService().signOut();
                      if(context.mounted) {
                        // Navigate to login if needed, or the router will handle the auth state change
                      }
                    } catch (e) {
                      // Handle error
                    }
                  },
                  icon: const Icon(Icons.logout, size: 18, color: Colors.grey),
                  label: const Text('Logout / Change Email',
                      style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
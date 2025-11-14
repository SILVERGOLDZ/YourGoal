import 'package:flutter/material.dart';
import 'package:tes/Widget/base_page.dart'; //bg color + transparent status bar with safe area
import 'package:tes/auth_service.dart'; // Import AuthService
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tes/theme/colors.dart'; // Import custom colors

// Convert to StatefulWidget to manage loading and user data state
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _email;
  String? _fullName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
    });

    User? user = _authService.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot doc =
        await _firestore.collection('users').doc(user.uid).get();

        if (doc.exists && mounted) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          setState(() {
            _email = data['email'];
            _fullName = "${data['firstName']} ${data['lastName']}";
          });
        } else if (mounted) {
          // Fallback for users who signed in with Google but data wasn't set yet
          // or if doc doesn't exist for some reason
          setState(() {
            _email = user.email;
            _fullName = user.displayName ?? "No Name";
          });
        }
      } catch (e) {
        print("Error fetching user data: $e");
        if (mounted) {
          // Fallback
          setState(() {
            _email = user.email;
            _fullName = user.displayName ?? "Error loading name";
          });
        }
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Sign out function
  void _signOut() async {
    // Show confirmation dialog
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.signOut();
      // No need to navigate, router redirect will handle it.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BasePage(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.active,
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                // Display Full Name
                Text(
                  _fullName ?? 'Loading...',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                // Display Email
                Text(
                  _email ?? 'Loading...',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: AppColors.inactive),
                ),
                const SizedBox(height: 40),
                // Sign Out Button
                ElevatedButton.icon(
                  onPressed: _signOut,
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
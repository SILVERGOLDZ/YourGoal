import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:tes/Widget/half_gradient_background.dart';
import 'package:tes/config/routes.dart';
import 'package:tes/services/auth/auth_service.dart';
import 'package:tes/theme/colors.dart';
import 'package:tes/utils/snackbar_helper.dart';
import 'package:url_launcher/url_launcher.dart'; // Make sure to run: flutter pub add url_launcher

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _email;
  String? _firstName;
  String? _lastName;
  String? _phone;
  String? _photoUrl;
  bool _isLoading = true;

  // State for Notifications Toggle
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    User? user = _authService.currentUser;

    if (user != null) {
      try {
        await user.reload();
        user = _authService.currentUser;

        _email = user!.email;
        _photoUrl = user.photoURL;

        DocumentSnapshot doc =
        await _firestore.collection('users').doc(user.uid).get();

        if (doc.exists && mounted) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          setState(() {
            _firstName = data['firstName'] ?? '';
            _lastName = data['lastName'] ?? '';
            _phone = data['phone'] ?? '';
          });
        }
      } catch (e) {
        debugPrint("Error fetching data: $e");
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  // --- 2. Function to launch URL ---
  Future<void> _launchGithub() async {
    final Uri url = Uri.parse('https://github.com/SILVERGOLDZ/YourGoal');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        showSnackBar('Could not launch $url', isError: true);
      }
    }
  }

  void _deleteAccount() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
        content: const Text(
            'Are you sure? This action cannot be undone. All your data will be permanently lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete Permanently',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ) ??
        false;

    if (confirm) {
      if (!mounted) return;
      setState(() => _isLoading = true);

      try {
        bool success = await _authService.deleteUserAccount();

        if (!success && mounted) {
          _handleDeleteError();
        }
      } catch (e) {
        if (mounted) _handleDeleteError();
      }
    }
  }

  void _handleDeleteError() {
    setState(() => _isLoading = false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Security Alert'),
        content: const Text(
            'For security reasons, you must have recently signed in to delete your account.\n\nPlease Sign Out and Sign In again, then try deleting your account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _signOut();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.active),
            child: const Text('Sign Out Now', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  void _signOut() async {
    await _authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: Stack(
        children: [
          const BackgroundDecoration(),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "My Profile",
                      style: GoogleFonts.nunitoSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // --- Profile Card ---
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: _photoUrl != null
                            ? NetworkImage(_photoUrl!)
                            : const AssetImage('assets/images/default_profile.png')
                        as ImageProvider,
                        backgroundColor: Colors.grey[200],
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "$_firstName $_lastName",
                              style: GoogleFonts.nunitoSans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              _email ?? "",
                              style: GoogleFonts.nunitoSans(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              _phone ?? "",
                              style: GoogleFonts.nunitoSans(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => context.push(AppRoutes.editProfile).then((_) => _fetchUserData()),
                        icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // --- 1. Renamed Header to "General" ---
                _buildSectionTitle("General"),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      // --- 2. About MyGoal Link ---
                      _buildListTile(
                        icon: Icons.info_outline,
                        title: "About MyGoal",
                        showDivider: true,
                        onTap: _launchGithub,
                      ),
                      // --- 5. Saved Post Redirect ---
                      _buildListTile(
                        icon: Icons.bookmark_outline,
                        title: "Saved Post",
                        showDivider: false,
                        onTap: () => context.push(AppRoutes.collection),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),
                _buildSectionTitle("App Preferences"),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      // --- 3. Language Snackbar ---
                      _buildListTile(
                        icon: Icons.translate,
                        title: "Language",
                        showDivider: true,
                        onTap: () => showSnackBar('Language selection is coming soon!'),
                      ),
                      // --- 4. Notification Switch ---
                      // We use a custom ListTile here for the switch
                      ListTile(
                        leading: const Icon(Icons.notifications_outlined, color: Color(0xFF555555)),
                        title: Text(
                          "Notifications",
                          style: GoogleFonts.nunitoSans(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: null,
                          ),
                        ),
                        trailing: Switch(
                          value: _notificationsEnabled,
                          activeColor: AppColors.active,
                          onChanged: (bool value) {
                            setState(() {
                              _notificationsEnabled = value;
                            });
                            showSnackBar(value ? 'Notifications Enabled' : 'Notifications Disabled');
                          },
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),
                _buildSectionTitle("Others"),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildListTile(
                        icon: Icons.logout,
                        title: "Sign Out",
                        showDivider: true,
                        onTap: _signOut,
                        color: Colors.orange,
                      ),
                      _buildListTile(
                        icon: Icons.delete_forever,
                        title: "Delete Account",
                        showDivider: false,
                        onTap: _deleteAccount,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.nunitoSans(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  // Updated Helper to allow optional trailing override
  Widget _buildListTile({
    required IconData icon,
    required String title,
    required bool showDivider,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: color ?? const Color(0xFF555555)),
          title: Text(
            title,
            style: GoogleFonts.nunitoSans(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: color,
            ),
          ),
          // Default trailing is the arrow, can be changed if needed
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          onTap: onTap,
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.only(left: 60, right: 20),
            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
          ),
      ],
    );
  }
}
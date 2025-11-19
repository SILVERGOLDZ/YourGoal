import 'package:flutter/material.dart';
import 'package:tes/Widget/base_page.dart';
import 'package:tes/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tes/theme/colors.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // State variables
  String? _email;
  String? _firstName;
  String? _lastName;
  String? _phone;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // --- READ: Fetch Data ---
  Future<void> _fetchUserData() async {
    setState(() => _isLoading = true);

    User? user = _authService.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot doc =
        await _firestore.collection('users').doc(user.uid).get();

        if (doc.exists && mounted) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          setState(() {
            _email = data['email'];
            _firstName = data['firstName'];
            _lastName = data['lastName'];
            _phone = data['phone'];
          });
        } else {
          // Fallback if no firestore doc exists
          setState(() {
            _email = user.email;
            _firstName = user.displayName?.split(' ').first ?? "User";
          });
        }
      } catch (e) {
        debugPrint("Error fetching data: $e");
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  // --- UPDATE: Edit Profile Dialog ---
  void _showEditProfileDialog() {
    final formKey = GlobalKey<FormState>();
    final firstNameController = TextEditingController(text: _firstName);
    final lastNameController = TextEditingController(text: _lastName);
    final phoneController = TextEditingController(text: _phone);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: firstNameController,
                    decoration: const InputDecoration(labelText: 'First Name'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: lastNameController,
                    decoration: const InputDecoration(labelText: 'Last Name'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Phone'),
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  // Close dialog first
                  Navigator.pop(context);

                  // Show loading
                  setState(() => _isLoading = true);

                  // Call Update Method
                  bool success = await _authService.updateUserData({
                    'firstName': firstNameController.text.trim(),
                    'lastName': lastNameController.text.trim(),
                    'phone': phoneController.text.trim(),
                  });

                  if (success) {
                    await _fetchUserData(); // Refresh UI
                    if (mounted) _showSnackBar('Profile Updated!', Colors.green);
                  } else {
                    setState(() => _isLoading = false);
                    if (mounted) _showSnackBar('Update failed.', Colors.red);
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.active, foregroundColor: Colors.white),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // --- DELETE: Delete Account Logic ---
  void _deleteAccount() async {
    // Warning Dialog
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
        content: const Text(
            'Are you sure? This action cannot be undone. You will lose all your data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      setState(() => _isLoading = true);

      // For security, Firebase often requires re-authentication before deleting.
      // For this example, we'll try directly.
      bool success = await _authService.deleteUserAccount("dummy_password");

      if (success) {
        if (mounted) {
          // Router handles redirect to login automatically via auth stream
          _showSnackBar('Account deleted.', Colors.grey);
        }
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          _showSnackBar(
              'Failed. You may need to logout and login again strictly to perform this action.',
              Colors.red
          );
        }
      }
    }
  }

  void _signOut() async {
    await _authService.signOut();
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    String fullName = "$_firstName $_lastName".trim();
    if (fullName.isEmpty) fullName = "No Name";

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: BasePage(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Avatar
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.active,
                  child: Icon(Icons.person, size: 60, color: Colors.white),
                ),
                const SizedBox(height: 16),

                // Name & Email
                Text(
                  fullName,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _email ?? '',
                  style: TextStyle(color: Colors.grey[600]),
                ),

                const SizedBox(height: 32),

                // --- CRUD Buttons ---

                // Edit Button
                _buildMenuButton(
                  icon: Icons.edit,
                  text: "Edit Profile Details",
                  onTap: _showEditProfileDialog,
                ),

                const SizedBox(height: 16),

                // Sign Out Button
                _buildMenuButton(
                  icon: Icons.logout,
                  text: "Sign Out",
                  onTap: _signOut,
                  color: Colors.orange,
                ),

                const SizedBox(height: 16),

                // Delete Account Button
                _buildMenuButton(
                  icon: Icons.delete_forever,
                  text: "Delete Account",
                  onTap: _deleteAccount,
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color color = AppColors.active,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600)
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tes/auth_service.dart';
import 'package:tes/theme/colors.dart';
import 'package:tes/Widget/base_page.dart'; // Pastikan path ini benar

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // State variables
  String? _email;
  String? _firstName;
  String? _lastName;
  String? _phone;
  String? _photoUrl; // Tambahan untuk foto Google
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // --- READ: Fetch Data ---
  Future<void> _fetchUserData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    User? user = _authService.currentUser;

    if (user != null) {
      try {
        // 1. Ambil data dasar dari Auth (Backup jika Firestore kosong)
        _email = user.email;
        _photoUrl = user.photoURL; // Ambil foto dari Google Auth

        // 2. Ambil detail dari Firestore
        DocumentSnapshot doc =
        await _firestore.collection('users').doc(user.uid).get();

        if (doc.exists && mounted) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          setState(() {
            _firstName = data['firstName'] ?? '';
            _lastName = data['lastName'] ?? '';
            _phone = data['phone'] ?? '';
            // Jika user upload foto custom di masa depan, ambil dari sini:
            // _photoUrl = data['photoUrl'] ?? user.photoURL;
          });
        } else if (mounted) {
          // Fallback jika dokumen Firestore belum ada (jarang terjadi dgn logic baru)
          setState(() {
            _firstName = user.displayName?.split(' ').first ?? "User";
            _lastName = "";
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
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      prefixIcon: Icon(Icons.phone_android),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context); // Tutup dialog
                  setState(() => _isLoading = true);

                  bool success = await _authService.updateUserData({
                    'firstName': firstNameController.text.trim(),
                    'lastName': lastNameController.text.trim(),
                    'phone': phoneController.text.trim(),
                  });

                  if (mounted) {
                    if (success) {
                      await _fetchUserData(); // Refresh tampilan
                      _showSnackBar('Profile Updated Successfully!', Colors.green);
                    } else {
                      setState(() => _isLoading = false);
                      _showSnackBar('Failed to update profile.', Colors.red);
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.active,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // --- DELETE: Delete Account Logic ---
  void _deleteAccount() async {
    // 1. Konfirmasi User
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
        // 2. Coba Hapus
        // Note: Kita kirim dummy string karena authService Anda meminta parameter password,
        // tapi implementasi authService sebelumnya sebenarnya tidak menggunakannya untuk re-auth.
        bool success = await _authService.deleteUserAccount();

        if (!success && mounted) {
          // Jika gagal, biasanya karena "Requires Recent Login"
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
              _signOut(); // Bantu user logout langsung
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
    // Router akan otomatis handle redirect ke Login
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    String fullName = "$_firstName $_lastName".trim();
    if (fullName.isEmpty) fullName = "User";

    // Initials untuk Avatar jika tidak ada foto
    String initials = "";
    if (_firstName != null && _firstName!.isNotEmpty) {
      initials += _firstName![0];
    }
    if (_lastName != null && _lastName!.isNotEmpty) {
      initials += _lastName![0];
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : BasePage( // Menggunakan BasePage Anda untuk konsistensi
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // --- Avatar Section ---
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.active, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    backgroundImage: _photoUrl != null
                        ? NetworkImage(_photoUrl!)
                        : null,
                    child: _photoUrl == null
                        ? Text(
                      initials.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.active,
                      ),
                    )
                        : null,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // --- Info Section ---
              Text(
                fullName,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.inactive.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _email ?? 'No Email',
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
              ),

              const SizedBox(height: 40),

              // --- Menu Buttons ---

              _buildMenuCard(
                icon: Icons.edit_outlined,
                title: "Edit Profile Details",
                subtitle: "Change name or phone number",
                onTap: _showEditProfileDialog,
                iconColor: AppColors.active,
              ),

              const SizedBox(height: 16),

              _buildMenuCard(
                icon: Icons.logout_rounded,
                title: "Sign Out",
                subtitle: "Log out from this device",
                onTap: _signOut,
                iconColor: Colors.orange,
              ),

              const SizedBox(height: 16),

              _buildMenuCard(
                icon: Icons.delete_forever_outlined,
                title: "Delete Account",
                subtitle: "Permanently remove your data",
                onTap: _deleteAccount,
                iconColor: Colors.red,
                isDanger: true,
              ),

              const SizedBox(height: 30),
              Text(
                "Version 1.0.0",
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color iconColor,
    bool isDanger = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDanger ? Colors.red : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: Colors.grey[300],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
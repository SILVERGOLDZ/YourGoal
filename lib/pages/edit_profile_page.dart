import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:google_fonts/google_fonts.dart'; // Ensure this is in pubspec if you use it
import 'package:image_picker/image_picker.dart';
import 'package:tes/services/auth/auth_service.dart';
import 'package:tes/theme/colors.dart';
import 'package:tes/utils/snackbar_helper.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  final _formKey = GlobalKey<FormState>();

  // Initialize with empty to avoid late initialization errors during build if loading is fast
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  String? _email;
  String? _photoUrl;
  XFile? _imageFile;
  bool _isLoading = true;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    User? user = _authService.currentUser;

    if (user != null) {
      try {
        _email = user.email;
        _photoUrl = user.photoURL;

        DocumentSnapshot doc =
        await _firestore.collection('users').doc(user.uid).get();

        if (doc.exists && mounted) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          _firstNameController.text = data['firstName'] ?? '';
          _lastNameController.text = data['lastName'] ?? '';
          _phoneController.text = data['phone'] ?? '';
        }
      } catch (e) {
        debugPrint("Error fetching data: $e");
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<bool> _onWillPop() async {
    if (_hasUnsavedChanges) {
      final shouldPop = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text(
              'You have unsaved changes. If you leave now, the changes you made will be lost.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Discard Changes'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Stay'),
            ),
          ],
        ),
      );
      return shouldPop ?? false;
    }
    return true;
  }

  void _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
        _hasUnsavedChanges = true;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      String? newPhotoUrl;
      if (_imageFile != null) {
        newPhotoUrl =
        await _authService.uploadProfilePicture(File(_imageFile!.path));
      }

      bool success = await _authService.updateUserData({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        if (newPhotoUrl != null) 'photoURL': newPhotoUrl,
      });

      if (mounted) {
        if (success) {
          showSnackBar('Profile Updated Successfully!');
          setState(() {
            _hasUnsavedChanges = false;
            _isLoading = false;
          });
          context.pop();
        } else {
          showSnackBar('Failed to update profile.', isError: true);
          setState(() => _isLoading = false);
        }
      }
    }
  }

  // --- UI Helper Widgets ---

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: readOnly ? Colors.grey.shade200 : Colors.grey.shade100, // Darker if read-only
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        readOnly: readOnly,
        style: TextStyle(
          // Change text color to indicate disabled state if readOnly
          color: readOnly ? Colors.grey.shade600 : Colors.black,
          fontWeight: FontWeight.w500,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          isDense: true,
        ),
        onChanged: (_) {
          if (!readOnly) setState(() => _hasUnsavedChanges = true);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
            ),
            onPressed: () async {
              if (await _onWillPop()) {
                context.pop();
              }
            },
          ),
          centerTitle: true,
          title: const Text(
            'Edit Profile',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Profile Picture Section ---
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purple.withOpacity(0.1),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: _imageFile != null
                                ? FileImage(File(_imageFile!.path))
                                : (_photoUrl != null
                                ? NetworkImage(_photoUrl!)
                                : const AssetImage(
                                'assets/images/default_profile.png'))
                            as ImageProvider,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Display combined name dynamically
                      Text(
                        "${_firstNameController.text} ${_lastNameController.text}",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: _pickImage,
                        child: const Text(
                          'Change Profile Picture',
                          style: TextStyle(
                            color: Colors.blue, // Match the blue in design
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // --- Form Fields ---

                // First Name
                _buildLabel('First name'),
                _buildTextField(
                  controller: _firstNameController,
                  validator: (value) =>
                  value!.isEmpty ? 'First name is required' : null,
                ),
                const SizedBox(height: 20),

                // Last Name
                _buildLabel('Last name'),
                _buildTextField(
                  controller: _lastNameController,
                  validator: (value) =>
                  value!.isEmpty ? 'Last name is required' : null,
                ),
                const SizedBox(height: 20),

                // Email (Read Only)
                _buildLabel('Email'),
                _buildTextField(
                  controller: TextEditingController(text: _email),
                  readOnly: true, // This makes it un-editable
                ),
                const SizedBox(height: 20),

                // Phone Number
                _buildLabel('Number phone (Optional)'),
                _buildTextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 40),

                // --- Save Button ---
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Or AppColors.active
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
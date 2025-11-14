import 'package:flutter/material.dart';
// import 'package:tes/pages/Login&Register/Login.dart'; // No longer needed
import 'package:tes/theme/colors.dart'; // Impor warna
import 'package:go_router/go_router.dart';
import 'package:tes/auth_service.dart'; // Import your AuthService

// Halaman StatefulWidget untuk Registrasi
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _obscurePassword = true;

  // --- Firebase ---
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  // ---

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Fungsi yang dipanggil saat tombol "NEXT" ditekan
  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // (Logika Bisnis)
      final userCredential = await _authService.registerWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
        _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (userCredential != null) {
          // Registrasi sukses
          _showSuccessSnackBar(
              'Registration successful! Please log in to continue.');
          // (Navigasi)
          context.goNamed('login');
        } else {
          // Registrasi gagal
          _showErrorSnackBar(
              'Registration failed. The email might already be in use.');
        }
      }
    }
  }

  // Helper to show SnackBar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed('login');
            }
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // --- Main Content ---
            SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Sign Up',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // First Name
                    _buildTextFieldWithLabel(
                      controller: _firstNameController,
                      label: 'First Name*',
                      hint: 'Enter your name',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'First name cannot be empty';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Last Name
                    _buildTextFieldWithLabel(
                      controller: _lastNameController,
                      label: 'Last Name*',
                      hint: 'Enter your last name',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Last name cannot be empty';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Email
                    _buildTextFieldWithLabel(
                      controller: _emailController,
                      label: 'Email*',
                      hint: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email cannot be empty';
                        }
                        if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Password
                    _buildTextFieldWithLabel(
                      controller: _passwordController,
                      label: 'Password*',
                      hint: '********',
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.inactive,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password cannot be empty';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Phone Number
                    _buildTextFieldWithLabel(
                      controller: _phoneController,
                      label: 'Phone Number (Optional)',
                      hint: 'Start with your country code (e.g. +62)',
                      keyboardType: TextInputType.phone,
                      // Tidak ada validator karena opsional
                    ),
                    const SizedBox(height: 40),

                    // 4. Tombol "NEXT"
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : _register, // Disable if loading
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.active,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                      const Text('NEXT', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),

            // --- Loading Overlay ---
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper Widget
  Widget _buildTextFieldWithLabel({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
            filled: false,
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.inactive),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.inactive.withOpacity(0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.inactive.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.active, width: 2.0),
            ),
            suffixIcon: suffixIcon,
            contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:tes/theme/colors.dart';
import 'package:go_router/go_router.dart';
import 'package:tes/auth_service.dart';
import 'package:tes/utils/snackbar_helper.dart';

class RegisterPage extends StatefulWidget {
  // Tidak butuh parameter extraData lagi
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

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _register() async {
    // Validasi form terlebih dahulu
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    String? error = await _authService.registerWithEmailPassword(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _firstNameController.text.trim(),
      _lastNameController.text.trim(),
      _phoneController.text.trim(),
    );

    if (error == null) {
      // SUKSES
      if (mounted) {
        showSnackBar(context, 'Akun berhasil dibuat. Silakan periksa email Anda untuk verifikasi.');
        // GoRouter otomatis handle navigasi
      }
    } else {
      // GAGAL
      if (mounted) showSnackBar(context, error, isError: true);
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
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
                        if (value == null || value.isEmpty) return 'First name cannot be empty';
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
                        if (value == null || value.isEmpty) return 'Last name cannot be empty';
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
                        if (value == null || value.isEmpty) return 'Email cannot be empty';
                        if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return 'Please enter a valid email';
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
                        if (value == null || value.isEmpty) return 'Password cannot be empty';
                        //TODO : UBAH INI KALO UD RILIS
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        // if (!passwordRegex.hasMatch(value)) {
                        //   return 'Must be 8+ chars, with Upper, Lower, Number & Symbol';
                        // }
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
                    ),
                    const SizedBox(height: 40),

                    // Tombol Aksi
                    ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.active,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('NEXT', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),

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
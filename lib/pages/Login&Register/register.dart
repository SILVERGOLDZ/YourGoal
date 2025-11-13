import 'package:flutter/material.dart';
import 'package:tes/pages/Login&Register/Login.dart'; // Impor LoginPage
import 'package:tes/theme/colors.dart'; // Impor warna
import 'package:go_router/go_router.dart';

// Halaman StatefulWidget untuk Registrasi
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // GlobalKey untuk validasi Form
  final _formKey = GlobalKey<FormState>();

  // Controller untuk setiap input field
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  // State untuk visibilitas password
  bool _obscurePassword = true;

  @override
  void dispose() {
    // Selalu dispose controller untuk mencegah memory leaks
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Fungsi yang dipanggil saat tombol "NEXT" ditekan
  void _register() {
    // Jalankan validasi form
    if (_formKey.currentState!.validate()) {
      // (Logika Bisnis)
      // Di sini Anda akan mengirim data registrasi ke API atau database.
      print('Register sukses');

      // (Navigasi)
      // Bawa pengguna ke halaman Login setelah berhasil mendaftar
      context.goNamed('login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. AppBar - Disesuaikan agar sama dengan screenshot (hanya tombol kembali)
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // 1. Gunakan context.canPop() dari GoRouter
            if (context.canPop()) {
              // 2. Gunakan context.pop() dari GoRouter
              context.pop();
            } else {
              // 3. Fallback jika tidak ada halaman di bawahnya
              context.goNamed('login');
            }
          },
        ),
        backgroundColor: Colors.white, // Latar belakang AppBar
        elevation: 0, // Tanpa bayangan
      ),
      backgroundColor: Colors.white, // Latar belakang Scaffold
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 2. Judul "Sign Up"
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

                // 3. Form Fields (menggunakan helper)
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
                  onPressed: _register,
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
      ),
    );
  }

  // Helper Widget untuk membuat form (Label di atas, TextForm di bawah)
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
        // Label Teks
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        // Text Form Field
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
            // --- Catatan ---
            // Kode ini secara eksplisit MENGGANTI (override)
            // InputDecorationTheme dari app_theme.dart.
            // Ini diperlukan karena app_theme.dart Anda mendefinisikan
            // style "filled" (BorderSide.none), sedangkan screenshot
            // Anda menggunakan style "outlined" (dengan border abu-abu).

            filled: false,
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.inactive),
            // Tentukan border standar (Outline)
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.inactive.withOpacity(0.5)),
            ),
            // Tentukan border saat enabled
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.inactive.withOpacity(0.5)),
            ),
            // Tentukan border saat fokus
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.active, width: 2.0),
            ),
            suffixIcon: suffixIcon,
            // Mengatur padding konten
            contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          ),
        ),
      ],
    );
  }
}
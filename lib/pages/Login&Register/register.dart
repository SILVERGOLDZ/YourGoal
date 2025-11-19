import 'package:flutter/material.dart';
import 'package:tes/theme/colors.dart'; // Impor warna
import 'package:go_router/go_router.dart';
import 'package:tes/auth_service.dart'; // Import your AuthService

// Halaman StatefulWidget untuk Registrasi
class RegisterPage extends StatefulWidget {
  // Terima data dari Login Page
  final Map<String, dynamic>? extraData;

  const RegisterPage({super.key, this.extraData});

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

  bool _isGoogleFlow = false;

  @override
  void initState() {
    super.initState();
    // Cek apakah ini flow dari Google
    if (widget.extraData != null && widget.extraData!['isGoogle'] == true) {
      _isGoogleFlow = true;
      _emailController.text = widget.extraData!['email'] ?? '';
      _firstNameController.text = widget.extraData!['firstName'] ?? '';
      _lastNameController.text = widget.extraData!['lastName'] ?? '';
      // Password tidak butuh untuk Google
    }
  }

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
      setState(() => _isLoading = true);

      if (_isGoogleFlow) {
        // FLOW A: SAVE DATA GOOGLE
        await _authService.completeGoogleRegistration(
          uid: widget.extraData!['uid'],
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
        );
        // Karena Auth state sudah login dari proses Google sebelumnya,
        // User akan otomatis ter-redirect ke Home oleh Router setelah data tersimpan.
        // Tidak perlu navigasi eksplisit di sini jika router sudah diatur.

      } else {
        // FLOW B: REGISTER MANUAL (Kirim Email Verifikasi)
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
            // HAPUS INI: context.goNamed('login');
            // Router akan otomatis mendeteksi user login (karena signOut dihapus)
            // dan redirect ke '/verify-email' karena emailVerified masih false.

            // Cukup tampilkan pesan saja:
            _showSuccessSnackBar('Akun dibuat. Silakan verifikasi email Anda.');
          }
        } else {
          if (mounted) _showErrorSnackBar(error);
        }
      }

      if (mounted) setState(() => _isLoading = false);
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
        duration: const Duration(seconds: 4), // Durasi lebih lama agar terbaca
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Judul dan teks tombol disesuaikan berdasarkan alur
    final String pageTitle = _isGoogleFlow ? 'Complete Your Profile' : 'Sign Up';
    final String buttonText = _isGoogleFlow ? 'COMPLETE' : 'NEXT';

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
                    Text(
                      pageTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
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
                      enabled: !_isGoogleFlow, // Nonaktifkan jika dari Google
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

                    // Password (Sembunyikan jika dari Google Flow)
                    if (!_isGoogleFlow)
                      Column(
                        children: [
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
                        ],
                      ),

                    // Phone Number (Wajib diisi jika dari Google)
                    _buildTextFieldWithLabel(
                      controller: _phoneController,
                      label:
                      _isGoogleFlow ? 'Phone Number*' : 'Phone Number (Optional)',
                      hint: 'Start with your country code (e.g. +62)',
                      keyboardType: TextInputType.phone,
                      validator: _isGoogleFlow
                          ? (value) { // Validator jika dari Google
                        if (value == null || value.isEmpty) {
                          return 'Phone number is required';
                        }
                        return null;
                      }
                          : null, // Tidak ada validator jika manual & opsional
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
                      child: Text(buttonText, style: const TextStyle(fontSize: 16)),
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
    bool enabled = true, // Tambahkan parameter enabled
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
          enabled: enabled, // Terapkan di sini
          decoration: InputDecoration(
            filled: !enabled, // Beri background abu-abu jika disabled
            fillColor: !enabled ? Colors.grey[200] : null,
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
            disabledBorder: OutlineInputBorder( // Style untuk disabled state
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.inactive.withOpacity(0.3)),
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

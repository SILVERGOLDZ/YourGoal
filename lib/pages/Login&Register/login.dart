import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tes/theme/colors.dart'; // Impor warna kustom
import 'package:tes/auth_service.dart'; // Import AuthService

// LoginPage adalah StatefulWidget untuk mengelola state form
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

// Kelas State untuk LoginPage
class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // Firebase
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Fungsi yang dipanggil saat tombol "Login" ditekan
  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // (Logika Bisnis)
      final userCredential = await _authService.signInWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (mounted) {
        // Check if the widget is still in the tree
        setState(() {
          _isLoading = false;
        });

        if (userCredential == null) {
          // Show error message
          _showErrorSnackBar('Login failed. Please check your credentials.');
        }
        // No need to navigate, the router's redirect will handle it.
      }
    }
  }

  // --- Navigasi untuk tombol sosial ---
  void _googleLogin() async {
    setState(() => _isLoading = true);

    // Panggil method yang sudah dimodifikasi
    final result = await _authService.signInWithGoogle();

    if (mounted) {
      setState(() => _isLoading = false);

      if (result['status'] == 'success') {
        // Router akan otomatis redirect ke Home karena authState berubah
      } else if (result['status'] == 'needs_registration') {
        // NAH INI KUNCINYA: Redirect ke Register bawa data
        context.pushNamed(
          'register',
          extra: { // Kirim data via 'extra' object GoRouter
            'isGoogle': true,
            'email': result['email'],
            'firstName': result['firstName'],
            'lastName': result['lastName'],
            'uid': result['uid'],
          },
        );
      } else if (result['status'] == 'error') {
        _showErrorSnackBar(result['message'] ?? 'Google Sign-In failed');
      }
    }
  }

  // Non-functional social logins
  void _socialLoginNotImplemented() {
    _showErrorSnackBar('This feature is not yet implemented.');
  }

  // Fungsi untuk beralih ke halaman Register
  void _goToRegister() {
    context.goNamed('register');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // --- Main Content ---
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- Judul Halaman ---
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: 'Your',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color),
                            ),
                            TextSpan(
                              text: 'Gooal',
                              style: TextStyle(color: AppColors.active),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Login untuk melanjutkan',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.inactive,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // --- Form Email ---
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email tidak boleh kosong';
                          }
                          if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                            return 'Masukkan alamat email yang valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // --- Form Password ---
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),

                      // --- Tombol Login ---
                      ElevatedButton(
                        onPressed: _isLoading ? null : _login, // Disable if loading
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.active,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:
                        const Text('Login', style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(height: 30),

                      // --- Pemisah "Or" ---
                      Row(
                        children: [
                          Expanded(
                              child: Divider(
                                  color: AppColors.inactive.withOpacity(0.5))),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'Or',
                              style: TextStyle(color: AppColors.inactive),
                            ),
                          ),
                          Expanded(
                              child: Divider(
                                  color: AppColors.inactive.withOpacity(0.5))),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // --- Tombol Social Login ---
                      _buildSocialLoginButton(
                        onPressed: _isLoading
                            ? () {}
                            : _socialLoginNotImplemented, // Non-functional
                        icon: Icons.apple,
                        label: 'Continue with Apple',
                        iconColor: Colors.black,
                      ),
                      const SizedBox(height: 16),
                      _buildSocialLoginButton(
                        onPressed:
                        _isLoading ? () {} : _googleLogin, // Functional
                        iconWidget: Image.asset(
                          'assets/images/google_icon.png',
                          height: 28.0,
                          width: 28.0,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.g_mobiledata,
                                color: AppColors.active, size: 28.0);
                          },
                        ),
                        label: 'Continue with Google',
                      ),
                      const SizedBox(height: 16),
                      _buildSocialLoginButton(
                        onPressed: _isLoading
                            ? () {}
                            : _socialLoginNotImplemented, // Non-functional
                        icon: Icons.facebook,
                        label: 'Continue with Facebook',
                        iconColor: const Color(0xFF1877F2),
                      ),
                      const SizedBox(height: 10),

                      // --- Link ke Register ---
                      TextButton(
                        onPressed: _isLoading ? null : _goToRegister,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Create an Account',
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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

  // Widget Kustom untuk Tombol Social Login
  Widget _buildSocialLoginButton({
    required VoidCallback onPressed,
    required String label,
    IconData? icon,
    Widget? iconWidget,
    Color? iconColor,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: iconWidget ??
          Icon(
            icon,
            color: iconColor ??
                Theme.of(context).textTheme.bodyLarge?.color,
            size: 28.0,
          ),
      label: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        side: BorderSide(color: AppColors.inactive.withOpacity(0.3)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}

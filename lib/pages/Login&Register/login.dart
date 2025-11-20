import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tes/theme/colors.dart'; // Pastikan import warna benar
import 'package:tes/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

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

  // --- Logika Login Manual (Tetap Berfungsi) ---
  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final userCredential = await _authService.signInWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (userCredential == null) {
          _showSnackBar('Login failed. Please check your email or password.', isError: true);
        }
        // Jika sukses, GoRouter otomatis redirect
      }
    }
  }

  // --- Logika Dummy untuk Social Login ---
  void _onSocialLoginPressed(String providerName) {
    // Hanya tampilkan Snackbar
    _showSnackBar('Fitur login dengan $providerName belum tersedia saat ini.', isError: false);
  }

  void _goToRegister() {
    context.goNamed('register');
  }

  // Helper untuk SnackBar (Bisa merah untuk error, default hitam/standar)
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.black87,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // --- Konten Utama ---
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Judul
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

                      // Form Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Email tidak boleh kosong';
                          if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return 'Email tidak valid';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Form Password
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
                        validator: (value) =>
                        (value == null || value.isEmpty) ? 'Password tidak boleh kosong' : null,
                      ),
                      const SizedBox(height: 30),

                      // Tombol Login Utama
                      ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.active,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Login', style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(height: 30),

                      // --- Divider "Or" ---
                      Row(
                        children: [
                          Expanded(child: Divider(color: AppColors.inactive.withOpacity(0.5))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text('Or', style: TextStyle(color: AppColors.inactive)),
                          ),
                          Expanded(child: Divider(color: AppColors.inactive.withOpacity(0.5))),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // --- Tombol Social Login (DUMMY) ---
                      _buildSocialLoginButton(
                        onPressed: () => _onSocialLoginPressed('Apple'),
                        icon: Icons.apple,
                        label: 'Continue with Apple',
                        iconColor: Colors.black,
                      ),
                      const SizedBox(height: 16),
                      _buildSocialLoginButton(
                        onPressed: () => _onSocialLoginPressed('Google'),
                        // Menggunakan fallback Icon jika aset gambar belum siap
                        iconWidget: Image.asset(
                          'assets/images/google_icon.png',
                          height: 24.0,
                          width: 24.0,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.g_mobiledata, color: Colors.red, size: 28);
                          },
                        ),
                        label: 'Continue with Google',
                      ),
                      const SizedBox(height: 16),
                      _buildSocialLoginButton(
                        onPressed: () => _onSocialLoginPressed('Facebook'),
                        icon: Icons.facebook,
                        label: 'Continue with Facebook',
                        iconColor: const Color(0xFF1877F2),
                      ),
                      const SizedBox(height: 20),

                      // Link ke Register
                      TextButton(
                        onPressed: _isLoading ? null : _goToRegister,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account? ", style: TextStyle(color: Colors.grey)),
                            Text(
                              'Create Account',
                              style: TextStyle(
                                color: AppColors.active,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Loading Overlay
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  // Widget Tombol Social Login
  Widget _buildSocialLoginButton({
    required VoidCallback onPressed,
    required String label,
    IconData? icon,
    Widget? iconWidget,
    Color? iconColor,
  }) {
    return OutlinedButton.icon(
      onPressed: _isLoading ? null : onPressed,
      icon: iconWidget ?? Icon(icon, color: iconColor ?? Colors.black, size: 24.0),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        side: BorderSide(color: AppColors.inactive.withOpacity(0.3)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        // Agar tombol tetap terlihat aktif (clickable) meskipun hanya dummy
        foregroundColor: Colors.grey,
      ),
    );
  }
}
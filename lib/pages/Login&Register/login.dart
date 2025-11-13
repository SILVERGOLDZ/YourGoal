import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tes/theme/colors.dart'; // Impor warna kustom
import 'Register.dart'; // Impor halaman Register untuk navigasi

// LoginPage adalah StatefulWidget untuk mengelola state form
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

// Kelas State untuk LoginPage
class _LoginPageState extends State<LoginPage> {
  // Key untuk mengidentifikasi dan memvalidasi Form
  final _formKey = GlobalKey<FormState>();

  // Controller untuk input email dan password
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // State untuk visibilitas password
  bool _obscurePassword = true;

  @override
  void dispose() {
    // Selalu dispose controller untuk mencegah memory leaks
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Fungsi yang dipanggil saat tombol "Login" ditekan
  void _login() {
    // Validasi input form
    if (_formKey.currentState!.validate()) {
      // (Logika Bisnis)
      // Di sini Anda akan memeriksa email dan password ke API atau database.
      // print('Email: ${_emailController.text}');
      // print('Password: ${_passwordController.text}');
      print('Login sukses');

      // (Navigasi)
      // Jika login berhasil, bawa pengguna ke halaman utama (navigation_widget).
      // pushReplacement menghapus halaman Login dari tumpukan,
      // sehingga pengguna tidak bisa kembali ke halaman Login dengan tombol back.
      context.goNamed('home');
    }
  }

  // --- Navigasi sementara untuk tombol sosial ---
  // Sesuai permintaan, tombol ini akan langsung ke halaman utama
  void _socialLogin() {
    print('Login sosial sukses (placeholder)');
    context.goNamed('home');
  }

  // Fungsi untuk beralih ke halaman Register
  void _goToRegister() {
    // Ganti halaman saat ini (Login) dengan halaman Register      context.goNamed('home');
    context.goNamed('register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          // SingleChildScrollView agar tidak error saat keyboard muncul
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            // Form widget untuk validasi
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Judul Halaman ---
                  // Menggunakan RichText untuk styling "Your" dan "Gooal"
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      // Style dasar diambil dari tema, tanpa warna
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: 'Your',
                          // Atur warna hitam (atau warna teks default)
                          style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.color),
                        ),
                        TextSpan(
                          text: 'Gooal',
                          style:
                          TextStyle(color: AppColors.active), // Warna biru
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4), // Jarak diperkecil dari 8
                  Text(
                    'Login untuk melanjutkan',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.inactive,
                    ),
                  ), // ✅ Tambahkan koma di sini
                  const SizedBox(height: 40), // Spasi

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
                      return null; // Valid
                    },
                  ),
                  const SizedBox(height: 20), // Spasi

                  // --- Form Password ---
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword, // Sembunyikan teks
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      // Tombol ikon untuk toggle visibilitas password
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        // Ubah state _obscurePassword saat ditekan
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
                      return null; // Valid
                    },
                  ),
                  const SizedBox(height: 30), // Spasi

                  // --- Tombol Login ---
                  ElevatedButton(
                    onPressed: _login, // Panggil fungsi _login
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
                  const SizedBox(height: 30), // Spasi pemisah

                  // --- Pemisah "Or" ---
                  Row(
                    children: [
                      Expanded(
                          child: Divider(
                              color: AppColors.inactive.withOpacity(0.5))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                  const SizedBox(height: 30), // Spasi pemisah

                  // --- Tombol Social Login ---
                  _buildSocialLoginButton(
                    onPressed: _socialLogin,
                    icon: Icons.apple,
                    label: 'Continue with Apple',
                    iconColor: Colors.black, // Ikon Apple biasanya hitam
                  ),
                  const SizedBox(height: 16),
                  _buildSocialLoginButton(
                    onPressed: _socialLogin,
                    // Menggunakan logo Google dari asset lokal
                    iconWidget: Image.asset(
                      'assets/images/google_icon.png', // ✅ Ganti ke path asset Anda
                      height: 28.0, // Ukuran diperbesar
                      width: 28.0, // Ukuran diperbesar
                      // Tambahkan error builder jika asset tidak ditemukan
                      errorBuilder: (context, error, stackTrace) {
                        print("Error loading Google asset: $error");
                        // Fallback jika asset gagal dimuat
                        return const Icon(Icons.g_mobiledata,
                            color: AppColors.active, size: 28.0);
                      },
                    ),
                    label: 'Continue with Google',
                  ),
                  const SizedBox(height: 16),
                  _buildSocialLoginButton(
                    onPressed: _socialLogin,
                    icon: Icons.facebook,
                    label: 'Continue with Facebook',
                    iconColor: Color(0xFF1877F2), // Warna biru Facebook
                  ),

                  const SizedBox(height: 10), // Spasi

                  // --- Link ke Register ---
                  // Dipindahkan ke paling bawah, sesuai gambar "Create a Account"
                  TextButton(
                    onPressed: _goToRegister, // Panggil fungsi _goToRegister
                    child: Row(
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
      ),
    );
  }

  // --- Widget Kustom untuk Tombol Social Login ---
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
                Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.color, // Warna ikon default
            size: 28.0, // ✅ Ukuran diperbesar untuk Apple & Facebook
          ),
      label: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color, // Warna teks default
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        side: BorderSide(
            color: AppColors.inactive.withOpacity(0.3)), // Border abu-abu tipis
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // Border sangat bulat
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:tes/theme/colors.dart'; // Impor warna kustom
import 'Login.dart'; // Impor halaman Login untuk navigasi

// RegisterPage adalah StatefulWidget karena kita perlu mengelola status
// seperti teks dalam form dan visibilitas password.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

// Ini adalah kelas State untuk RegisterPage.
class _RegisterPageState extends State<RegisterPage> {
  // GlobalKey<FormState> digunakan untuk mengidentifikasi Form secara unik
  // dan memungkinkan kita untuk memvalidasi input di dalamnya.
  final _formKey = GlobalKey<FormState>();

  // TextEditingController digunakan untuk membaca dan mengontrol teks
  // dari sebuah TextFormField.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Variabel boolean untuk mengontrol visibilitas password (show/hide).
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    // Penting: Selalu dispose controller ketika widget tidak lagi digunakan
    // untuk menghindari kebocoran memori (memory leaks).
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Fungsi yang dipanggil saat tombol "Daftar" ditekan
  void _register() {
    // Langkah 1: Validasi form menggunakan _formKey.
    // `currentState!.validate()` akan menjalankan fungsi validator
    // di setiap TextFormField. Jika semua valid, ia mengembalikan true.
    if (_formKey.currentState!.validate()) {
      // Langkah 2: (Logika Bisnis)
      // Jika form valid, di sinilah Anda akan memanggil API,
      // menyimpan ke database, atau melakukan proses registrasi.
      // print('Email: ${_emailController.text}');
      // print('Password: ${_passwordController.text}');
      print('Registrasi sukses');

      // Langkah 3: Navigasi ke halaman Login setelah registrasi berhasil.
      // Kita menggunakan pushReplacement agar pengguna tidak bisa menekan "kembali"
      // dari halaman Login ke halaman Register.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  // Fungsi untuk beralih ke halaman Login
  void _goToLogin() {
    // Navigasi ke halaman Login dan mengganti halaman saat ini (Register)
    // Ini mencegah tumpukan halaman yang tidak perlu.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold adalah layout dasar untuk halaman dengan app bar, body, dll.
    return Scaffold(
      // SafeArea memastikan konten tidak terhalang oleh notch atau status bar sistem.
      body: SafeArea(
        // Center menengahkan widget anaknya.
        child: Center(
          // SingleChildScrollView memungkinkan konten di-scroll jika
          // ukurannya melebihi layar (misalnya saat keyboard muncul).
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0), // Padding di sekeliling form
            // Widget Form menghubungkan _formKey dengan TextFormField di dalamnya.
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Pusatkan secara vertikal
                crossAxisAlignment: CrossAxisAlignment.stretch, // Lebarkan widget (misalnya tombol)
                children: [
                  // --- Judul Halaman ---
                  Text(
                    'Buat Akun',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.active,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mulai perjalanan baru Anda bersama kami!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.inactive,
                    ),
                  ), // ✅ Tambahkan koma di sini
                  const SizedBox(height: 40), // Spasi

                  // --- Form Email ---
                  TextFormField(
                    controller: _emailController, // Hubungkan ke controller
                    keyboardType: TextInputType.emailAddress, // Tampilkan keyboard email
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined), // Ikon di depan
                    ),
                    // Validator akan dijalankan saat _formKey.currentState!.validate() dipanggil
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email tidak boleh kosong';
                      }
                      // Validasi email sederhana menggunakan Regex
                      if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                        return 'Masukkan alamat email yang valid';
                      }
                      return null; // Kembalikan null jika valid
                    },
                  ),
                  const SizedBox(height: 20), // Spasi

                  // --- Form Password ---
                  TextFormField(
                    controller: _passwordController, // Hubungkan ke controller
                    obscureText: _obscurePassword, // Sembunyikan teks (jika true)
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      // Ikon di belakang (suffix) untuk toggle visibilitas
                      suffixIcon: IconButton(
                        icon: Icon(
                          // Ubah ikon berdasarkan status _obscurePassword
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        // Saat ditekan, ubah status visibilitas
                        onPressed: () {
                          setState(() { // Panggil setState untuk membangun ulang UI
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password tidak boleh kosong';
                      }
                      if (value.length < 6) {
                        return 'Password minimal 6 karakter';
                      }
                      return null; // Valid
                    },
                  ),
                  const SizedBox(height: 20), // Spasi

                  // --- Form Konfirmasi Password ---
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'Konfirmasi Password',
                      prefixIcon: const Icon(Icons.lock_clock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Konfirmasi password tidak boleh kosong';
                      }
                      // Periksa apakah nilainya sama dengan teks di _passwordController
                      if (value != _passwordController.text) {
                        return 'Password tidak cocok';
                      }
                      return null; // Valid
                    },
                  ),
                  const SizedBox(height: 30), // Spasi

                  // --- Tombol Register ---
                  ElevatedButton(
                    onPressed: _register, // Panggil fungsi _register saat ditekan
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.active,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Daftar', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 20), // Spasi

                  // --- Link ke Login ---
                  // TextButton adalah tombol tanpa latar belakang, cocok untuk link
                  TextButton(
                    onPressed: _goToLogin, // Panggil fungsi _goToLogin saat ditekan
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sudah punya akun? ',
                          style: TextStyle(color: AppColors.inactive),
                        ),
                        const Text(
                          'Login',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.active,
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
      ),
    );
  }
}
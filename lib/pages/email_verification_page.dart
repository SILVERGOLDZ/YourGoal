import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tes/utils/snackbar_helper.dart';
// Pastikan import ini ada untuk warna, atau ganti AppColors.active dengan Colors.blue dsb.
import 'package:tes/theme/colors.dart';
// Jika Anda tidak memiliki AuthService, Anda bisa menggunakan FirebaseAuth langsung untuk logout
import 'package:tes/services/auth/auth_service.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  // --- LOGIC VARIABLES (Dari File 1) ---
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;
  // Variabel tambahan untuk UI loading saat logout/aksi lain jika diperlukan
  final bool _isPerformingAction = false;

  @override
  void initState() {
    super.initState();

    // --- LOGIC INIT (Dari File 1) ---

    // Cek apakah email user sudah terverifikasi saat halaman pertama kali dibuka
    isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;

    // Jika email belum terverifikasi, kirim email verifikasi
    if (!isEmailVerified) {
      sendVerificationEmail();

      // Mulai timer untuk mengecek status verifikasi setiap 3 detik
      timer = Timer.periodic(
        const Duration(seconds: 3),
            (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    // --- LOGIC DISPOSE (Dari File 1) ---
    timer?.cancel();
    super.dispose();
  }

  /// Mengecek status verifikasi email user secara berkala.
  /// (Logic persis dari File 1)
  Future<void> checkEmailVerified() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Memuat ulang data user dari Firebase untuk mendapatkan status terbaru
    await user.reload();
    user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    final isVerifiedNow = user?.emailVerified ?? false;

    // Update state agar UI bisa berubah jika diperlukan (misal menghilangkan tombol)
    if (isVerifiedNow != isEmailVerified) {
      setState(() {
        isEmailVerified = isVerifiedNow;
      });
    }

    if (isVerifiedNow) {
      timer?.cancel();

      // Navigasi ke halaman 'home' dan kirim parameter 'extra'
      // Sesuai logic file 1
      context.goNamed('home', extra: {'showVerificationSuccess': true});
    }
  }

  /// Mengirim email verifikasi ke user.
  /// (Logic persis dari File 1: Delay 5 detik)
  Future<void> sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      if (mounted) {
        showSnackBar(context, "Email verifikasi terkirim");
      }

      // Logic: disable tombol selama 5 detik
      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(seconds: 5));

      if (mounted) {
        setState(() => canResendEmail = true);
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, "Error: ${e.toString()}", isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fallback jika sudah verified (Dari File 1 + Desain Loading)
    if (isEmailVerified) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // --- UI DESIGN (Dari File 2) ---
    return PopScope(
      canPop: false, // Mencegah back button
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon Desain Baru
                const Icon(
                  Icons.mark_email_unread_outlined,
                  size: 100,
                  color: AppColors.active, // Pastikan AppColors diimport atau ganti Colors.blue
                ),
                const SizedBox(height: 30),

                // Title Desain Baru
                const Text(
                  'Verifikasi Email Anda',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Deskripsi dengan Email User
                Text(
                  'Kami telah mengirimkan link verifikasi ke email:\n${FirebaseAuth.instance.currentUser?.email}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 30),

                // Tombol "Saya Sudah Verifikasi" (Manual Check)
                // Menggunakan fungsi checkEmailVerified dari Logic 1
                ElevatedButton.icon(
                  onPressed: checkEmailVerified,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Saya Sudah Verifikasi'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
                const SizedBox(height: 16),

                // Tombol "Kirim Ulang Email"
                // Menggunakan logic canResendEmail dari Logic 1
                TextButton(
                  onPressed: canResendEmail ? sendVerificationEmail : null,
                  child: Text(
                    canResendEmail ? 'Kirim Ulang Email' : 'Mohon tunggu...',
                    style: TextStyle(
                      color: canResendEmail ? AppColors.active : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Tombol Logout
                // Ditambahkan agar sesuai desain, logic logout standar
                TextButton.icon(
                  onPressed: () async {
                    // Gunakan AuthService jika ada, atau FirebaseAuth langsung
                    try {
                      await FirebaseAuth.instance.signOut();
                      // AuthService().signOut();
                      if(context.mounted) {
                        // Navigasi ke login jika diperlukan, atau router akan handle auth state change
                      }
                    } catch (e) {
                      // Handle error
                    }
                  },
                  icon: const Icon(Icons.logout, size: 18, color: Colors.grey),
                  label: const Text('Logout / Ganti Email',
                      style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
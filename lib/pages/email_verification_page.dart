import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Diperlukan untuk navigasi
import 'package:tes/auth_service.dart';
import 'package:tes/theme/colors.dart'; // Sesuaikan path import warna Anda

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool isEmailVerified = false;
  Timer? timer;
  final AuthService _authService = AuthService();
  bool _isSendingVerification = false;

  @override
  void initState() {
    super.initState();

    // 1. Cek status awal verifikasi email dari user.
    isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;

    // 2. Jika email belum terverifikasi, lakukan tindakan.
    if (!isEmailVerified) {
      // Kirim email verifikasi secara otomatis saat halaman pertama kali dimuat.
      _sendVerificationEmail(isInitial: true);

      // 3. Atur timer untuk memeriksa status verifikasi secara berkala setiap 3 detik.
      timer = Timer.periodic(
        const Duration(seconds: 3),
            (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    // Pastikan untuk membatalkan timer saat widget tidak lagi digunakan untuk mencegah kebocoran memori.
    timer?.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // 1. Muat ulang status user dari server Firebase untuk mendapatkan data terbaru.
      await user.reload();

      // 2. Perbarui variabel user lokal untuk memastikan propertinya ter-update.
      user = FirebaseAuth.instance.currentUser;

      // Cek status verifikasi terbaru.
      bool verified = user?.emailVerified ?? false;

      // Perbarui state jika ada perubahan, ini akan memicu pembangunan ulang UI.
      if (mounted && verified != isEmailVerified) {
        setState(() {
          isEmailVerified = verified;
        });
      }

      // Jika email sudah terverifikasi, batalkan timer dan navigasi.
      if (verified) {
        timer?.cancel();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Email Terverifikasi! Mengalihkan...'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Beri jeda singkat agar pengguna sempat membaca pesan sukses.
          await Future.delayed(const Duration(milliseconds: 500));

          if (mounted) {
            // Gunakan goNamed untuk pindah paksa ke halaman 'home'.
            context.goNamed('home');
          }
        }
      }
    }
  }

  Future<void> _sendVerificationEmail({bool isInitial = false}) async {
    // Mencegah pengiriman ganda jika proses sedang berlangsung.
    if (_isSendingVerification) return;

    try {
      if(mounted) setState(() => _isSendingVerification = true);

      await FirebaseAuth.instance.currentUser?.sendEmailVerification();

      if (mounted) {
        final message = isInitial
            ? 'Link verifikasi telah dikirim ke email Anda.'
            : 'Email verifikasi telah dikirim ulang!';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim email: ${e.toString()}')),
        );
      }
    } finally {
      // Pastikan state diatur kembali menjadi false setelah proses selesai.
      if (mounted) {
        setState(() => _isSendingVerification = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Jika email sudah terverifikasi, tampilkan indikator loading
    // sementara proses navigasi ke halaman home berjalan.
    if (isEmailVerified) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Tampilan utama saat email belum terverifikasi.
    return PopScope(
      canPop: false, // Mencegah pengguna kembali ke halaman sebelumnya.
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.mark_email_unread_outlined,
                    size: 100, color: AppColors.active),
                const SizedBox(height: 30),
                const Text(
                  'Verifikasi Email Anda',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Kami telah mengirimkan link verifikasi ke email:\n${FirebaseAuth.instance.currentUser?.email}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: checkEmailVerified, // Cek manual oleh user
                  icon: const Icon(Icons.refresh),
                  label: const Text('Saya Sudah Verifikasi'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  // Nonaktifkan tombol saat proses pengiriman sedang berlangsung.
                  onPressed: _isSendingVerification
                      ? null
                      : () => _sendVerificationEmail(),
                  child: Text(
                    _isSendingVerification ? 'Mengirim...' : 'Kirim Ulang Email',
                    style: const TextStyle(color: AppColors.active),
                  ),
                ),
                const SizedBox(height: 30),
                TextButton.icon(
                  onPressed: () => _authService.signOut(),
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

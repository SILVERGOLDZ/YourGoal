import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

    // 1. Cek status awal
    isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;

    if (!isEmailVerified) {
      // 2. Kirim ulang email otomatis (opsional, atau biarkan manual via tombol)
      // _sendVerificationEmail();

      // 3. Pasang Timer untuk cek status setiap 3 detik
      timer = Timer.periodic(
        const Duration(seconds: 3),
            (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    // Kita perlu reload user untuk dapat status terbaru dari Firebase
    await FirebaseAuth.instance.currentUser?.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;
    });

    // Jika sudah verified, timer akan di-cancel otomatis karena router
    // akan mendeteksi perubahan dan memindahkan user ke Home.
    if (isEmailVerified) {
      timer?.cancel();
    }
  }

  Future<void> _sendVerificationEmail() async {
    try {
      setState(() => _isSendingVerification = true);
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email verifikasi telah dikirim ulang!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim ulang: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingVerification = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Jika tiba-tiba verified, tampilkan loading sebentar sebelum redirect
    if (isEmailVerified) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mark_email_unread_outlined, size: 100, color: AppColors.active),
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

              // Tombol Cek Manual (User sering tidak sabar menunggu timer)
              ElevatedButton.icon(
                onPressed: checkEmailVerified,
                icon: const Icon(Icons.refresh),
                label: const Text('Saya Sudah Verifikasi'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
              ),

              const SizedBox(height: 16),

              // Tombol Resend
              TextButton(
                onPressed: _isSendingVerification ? null : _sendVerificationEmail,
                child: Text(
                  _isSendingVerification ? 'Mengirim...' : 'Kirim Ulang Email',
                  style: const TextStyle(color: AppColors.active),
                ),
              ),

              const SizedBox(height: 30),

              // Tombol Logout (Jika salah email)
              TextButton.icon(
                onPressed: () => _authService.signOut(),
                icon: const Icon(Icons.logout, size: 18, color: Colors.grey),
                label: const Text('Logout / Ganti Email', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
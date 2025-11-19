import 'package:flutter/material.dart';
import 'package:tes/Widget/base_page.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  // Default true agar muncul Empty State duluan
  bool _isEmpty = true;

  void _toggleView() {
    setState(() {
      _isEmpty = !_isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BasePage(
        child: SafeArea(
          // Pilih tampilan berdasarkan state _isEmpty
          child: _isEmpty ? _buildEmptyState() : _buildNotificationList(),
        ),
      ),
    );
  }

  // ==========================================
  // 1. TAMPILAN EMPTY STATE (Dengan Tombol Sementara)
  // ==========================================
  Widget _buildEmptyState() {
    return Column(
      children: [
        // --- Header ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
                onPressed: () {
                  // Navigator.pop(context); // Aktifkan jika sudah ada navigasi
                },
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48), // Penyeimbang posisi judul
            ],
          ),
        ),

        // --- Konten Tengah ---
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/No_Notification_Icon.png',
                width: 250,
                height: 250,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              const Text(
                'No notification here',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 40),

              // --- TOMBOL SEMENTARA (UNTUK TESTING) ---
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1), // Warna merah biar ketahuan ini tombol test
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red),
                ),
                child: TextButton.icon(
                  onPressed: _toggleView, // <-- Panggil fungsi toggle
                  icon: const Icon(Icons.bug_report, color: Colors.red),
                  label: const Text(
                    "TEST: Munculkan Notifikasi",
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 2. TAMPILAN LIST NOTIFIKASI (State Lama)
  // ==========================================
  Widget _buildNotificationList() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: <Widget>[
        // Header Judul
        const Center(
          child: Text(
            'Notification',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Group: Today
        const Text(
          'Today',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: Image.asset(
              'assets/images/Notification_widget_logo.png',
              width: 40,
              height: 40,
            ),
            title: const Text('Daily Grind'),
            subtitle: const Text('12:00 A.M'),
          ),
        ),
        Card(
          child: ListTile(
            leading: Image.asset(
              'assets/images/Notification_widget_logo.png',
              width: 40,
              height: 40,
            ),
            title: const Text('Someone Liked Your Post'),
            subtitle: const Text('10:00 A.M'),
          ),
        ),

        const SizedBox(height: 24),

        // Group: Yesterday
        const Text(
          'Yesterday',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: Image.asset(
              'assets/images/Opened_Notification_widget_logo.png',
              width: 40,
              height: 40,
            ),
            title: const Text('Daily Grind'),
            subtitle: const Text('12:00 A.M'),
          ),
        ),
        Card(
          child: ListTile(
            leading: Image.asset(
              'assets/images/Opened_Notification_widget_logo.png',
              width: 40,
              height: 40,
            ),
            title: const Text('Someone Liked Your Post'),
            subtitle: const Text('10:00 A.M'),
          ),
        ),

        const SizedBox(height: 40),

        // --- TOMBOL SEMENTARA DI BAWAH LIST (Untuk Reset) ---
        Center(
          child: TextButton(
            onPressed: _toggleView,
            child: const Text(
              "(Test: Kembali ke Kosong)",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}
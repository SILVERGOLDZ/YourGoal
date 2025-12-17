import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pastikan add intl di pubspec.yaml jika belum, atau gunakan format manual
import 'package:tes/Widget/base_page.dart';
import 'package:tes/services/goaldata_service.dart';

import '../models/goal_model.dart'; // Sesuaikan path import ini

// Model sederhana untuk menampung data notifikasi di UI
class NotificationItem {
  final String title;      // Judul Step
  final String goalTitle;  // Judul Roadmap induk
  final DateTime deadline;
  final bool isOverdue;

  NotificationItem({
    required this.title,
    required this.goalTitle,
    required this.deadline,
    required this.isOverdue,
  });
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final GoalDataService _goalService = GoalDataService();

  // Batas waktu untuk dianggap "Dekat" (misal: 3 hari)
  final Duration _upcomingThreshold = const Duration(days: 3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BasePage(
        child: SafeArea(
          child: StreamBuilder<List<RoadmapModel>>(
            stream: _goalService.getRoadmapsStream(),
            builder: (context, snapshot) {
              // 1. Loading State
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // 2. Error State
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              // 3. Process Data
              final roadmaps = snapshot.data ?? [];
              final notifications = _generateNotifications(roadmaps);

              // 4. Tentukan Tampilan (Empty vs List)
              if (notifications.isEmpty) {
                return _buildEmptyState();
              } else {
                return _buildNotificationList(notifications);
              }
            },
          ),
        ),
      ),
    );
  }

  // ==========================================
  // LOGIC: Filter Data untuk Notifikasi
  // ==========================================
  List<NotificationItem> _generateNotifications(List<RoadmapModel> roadmaps) {
    List<NotificationItem> items = [];
    DateTime now = DateTime.now();

    for (var roadmap in roadmaps) {
      for (var step in roadmap.steps) {
        // Hanya cek yang belum selesai
        if (!step.isCompleted) {
          final difference = step.deadline.difference(now);

          // KONDISI 1: Sudah Lewat Deadline (Overdue)
          if (difference.isNegative) {
            items.add(NotificationItem(
              title: step.title,
              goalTitle: roadmap.title,
              deadline: step.deadline,
              isOverdue: true,
            ));
          }
          // KONDISI 2: Deadline < 3 Hari (Upcoming)
          else if (difference <= _upcomingThreshold) {
            items.add(NotificationItem(
              title: step.title,
              goalTitle: roadmap.title,
              deadline: step.deadline,
              isOverdue: false,
            ));
          }
        }
      }
    }

    // Urutkan berdasarkan deadline (yang paling mendesak di atas)
    items.sort((a, b) => a.deadline.compareTo(b.deadline));
    return items;
  }

  // ==========================================
  // 1. TAMPILAN EMPTY STATE
  // ==========================================
  Widget _buildEmptyState() {
    return Column(
      children: [
        _buildHeader(), // Reusable Header
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
                'No upcoming deadlines',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Relax! You are on track.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 2. TAMPILAN LIST NOTIFIKASI
  // ==========================================
  Widget _buildNotificationList(List<NotificationItem> notifications) {
    // Pisahkan Overdue dan Upcoming untuk grouping UI
    final overdueList = notifications.where((n) => n.isOverdue).toList();
    final upcomingList = notifications.where((n) => !n.isOverdue).toList();

    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // SECTION: OVERDUE (Hanya muncul jika ada)
              if (overdueList.isNotEmpty) ...[
                const Text(
                  'Missed Deadlines',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 12),
                ...overdueList.map((item) => _buildNotificationCard(item)).toList(),
                const SizedBox(height: 24),
              ],

              // SECTION: UPCOMING (Hanya muncul jika ada)
              if (upcomingList.isNotEmpty) ...[
                const Text(
                  'Approaching',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...upcomingList.map((item) => _buildNotificationCard(item)).toList(),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // --- Widget: Header ---
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
            onPressed: () {
              Navigator.pop(context);
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
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  // --- Widget: Card Item ---
  Widget _buildNotificationCard(NotificationItem item) {
    // Format tanggal simpel
    String formattedDate = DateFormat('dd MMM, HH:mm').format(item.deadline);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: item.isOverdue ? Colors.red.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            item.isOverdue ? Icons.warning_amber_rounded : Icons.access_time_filled,
            color: item.isOverdue ? Colors.red : Colors.blue,
          ),
        ),
        title: Text(
          item.title, // Judul Step
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              "Goal: ${item.goalTitle}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              item.isOverdue ? "Overdue since $formattedDate" : "Due: $formattedDate",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: item.isOverdue ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
        trailing: item.isOverdue
            ? const Icon(Icons.error_outline, color: Colors.red, size: 20)
            : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }
}
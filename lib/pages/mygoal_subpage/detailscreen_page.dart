import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // 1. WAJIB: Import GoRouter

// 2. WAJIB: Import halaman NewRoadmapScreen
// Sesuaikan path-nya jika berbeda, misal: 'new_roadmap_page.dart'
import 'package:tes/pages/mygoal_subpage/newgoal_page.dart';

class RoadmapDetailScreen extends StatefulWidget {
  const RoadmapDetailScreen({super.key});

  @override
  State<RoadmapDetailScreen> createState() => _RoadmapDetailScreenState();
}

class _RoadmapDetailScreenState extends State<RoadmapDetailScreen> {
  // Data dummy
  final List<Map<String, dynamic>> _goals = [
    {
      "title": "Ikuti 3 Kompetisi Nasional",
      "status": "Complete",
      "isCompleted": true,
      "description": "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
      "subtasks": ["Konsultasi ke Mentor Raka", "Latihan 500 Soal", "Daftar Lomba UI/UX Gemastik"],
      "message": "I wanna make my parent proud"
    },
    {
      "title": "2. Pelajari Auto Layout",
      "status": "In Progress",
      "isCompleted": false,
      "description": "Memahami konsep resizing, constraints, dan padding dalam Figma.",
      "subtasks": ["Tonton tutorial YouTube", "Replicate desain Gojek"],
      "message": "Konsisten adalah kunci!"
    },
    {
      "title": "3. Buat Portfolio Case Study",
      "status": "In Progress",
      "isCompleted": false,
      "description": "Membuat studi kasus lengkap dari riset hingga high-fidelity prototype.",
      "subtasks": ["Cari ide masalah", "User Interview", "Wireframing"],
      "message": "Jangan lupa istirahat."
    },
    {
      "title": "4. Apply Magang",
      "status": "In Progress",
      "isCompleted": false,
      "description": "Mencari lowongan UI/UX designer intern.",
      "subtasks": ["Perbaiki CV ATS", "Kirim 10 lamaran per hari"],
      "message": "Semangat cari duit!"
    },
  ];

  // Logika Progress
  double get progressValue {
    if (_goals.isEmpty) return 0.0;
    int completed = _goals.where((item) => item['isCompleted'] == true).length;
    return completed / _goals.length;
  }

  String get progressPercentage {
    return "${(progressValue * 100).toInt()}%";
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const primaryBlue = Color(0xFF0B57CF);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // 3. LOGIKA BACK: Pindah ke route 'mygoal'
            // Pastikan di routes.dart Anda name-nya benar-benar 'mygoal'
            context.goNamed('mygoal');
          },
        ),
        title: Text(
          'Roadmap Detail',
          style: textTheme.titleLarge?.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                // 2. EKSEKUSI NAVIGASI KE ROUTE 'newgoal'
                // Menggunakan pushNamed agar bisa kembali (back) ke halaman detail ini
                context.pushNamed('newgoal');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                'Edit Goal',
                style: textTheme.labelLarge?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Learning Figma UI/UX Design",
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Updated 2 weeks ago",
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 30),

            // Progress Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Progress",
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  progressPercentage,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E89EF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progressValue,
                minHeight: 8,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1E89EF)),
              ),
            ),
            const SizedBox(height: 30),

            Text(
              "Goals",
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 16),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _goals.length,
              itemBuilder: (context, index) {
                final item = _goals[index];
                return _buildGoalCard(context, item, index);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget Card Goal (Bisa Diklik)
  Widget _buildGoalCard(BuildContext context, Map<String, dynamic> item, int index) {
    final textTheme = Theme.of(context).textTheme;
    final bool isCompleted = item['isCompleted'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            _showGoalDetailDialog(context, item, index);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IgnorePointer(
                  ignoring: true,
                  child: Transform.scale(
                    scale: 1.3,
                    child: Checkbox(
                      value: isCompleted,
                      onChanged: (val) {},
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      activeColor: const Color(0xFF1E89EF),
                      side: BorderSide(color: Colors.grey[500]!, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'],
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['status'],
                        style: textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF1E89EF),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
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
    );
  }

  // Popup Detail
  void _showGoalDetailDialog(BuildContext context, Map<String, dynamic> item, int index) {
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          insetPadding: const EdgeInsets.all(20),
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item['title'],
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 22,
                          ),
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.close, color: Colors.grey, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Text("Description:", style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    item['description'] ?? "No description provided.",
                    style: textTheme.bodyMedium?.copyWith(color: Colors.black87, height: 1.5),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 20),

                  Text("Subtask:", style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (item['subtasks'] != null)
                    ...List.generate((item['subtasks'] as List).length, (i) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          "${i + 1}. ${item['subtasks'][i]}",
                          style: textTheme.bodyMedium?.copyWith(color: Colors.black87),
                        ),
                      );
                    }),
                  const SizedBox(height: 20),

                  Text("Message from past me:", style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    item['message'] ?? "-",
                    style: textTheme.bodyMedium?.copyWith(color: Colors.black87),
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _goals[index]['isCompleted'] = true;
                          _goals[index]['status'] = "Complete";
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E89EF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        elevation: 0,
                      ),
                      child: Text(
                        "I have completed this goal",
                        style: textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
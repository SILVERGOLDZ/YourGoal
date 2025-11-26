import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tes/Widget/base_page.dart';
import 'package:tes/Widget/gradient_button.dart';
import 'package:tes/Widget/goal_card.dart';
import 'package:tes/Widget/stat_card.dart';

import '../services/goaldata_service.dart';

class MyGoalPage extends StatefulWidget {
  const MyGoalPage({super.key});

  @override
  State<MyGoalPage> createState() => _MyGoalPageState();
}

class _MyGoalPageState extends State<MyGoalPage> {
  // Panggil Service Data
  final GoalDataService _dataService = GoalDataService();

  // LOGIKA DINAMIS:
  // _hasGoals bernilai TRUE jika list roadmaps di service TIDAK kosong.
  // Jika Anda ingin mengetes tampilan kosong, kosongkan list di goal_data.dart
  bool get _hasGoals => _dataService.roadmaps.isNotEmpty;

  void _createNewGoal() {
    // Navigasi ke halaman New Goal
    context.pushNamed('newgoal').then((_) {
      // Refresh halaman saat kembali (agar tampilan berubah jika goal bertambah)
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BasePage(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            // TERNARY OPERATOR:
            // Jika ada goal -> Tampilkan Dashboard
            // Jika kosong -> Tampilkan Empty State (Roket)
            child: _hasGoals ? _buildDashboardView() : _buildEmptyStateView(),
          ),
        ),
      ),

      // Floating Action Button (Tombol +)
      // Hanya muncul jika sudah ada goal (Dashboard View)
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _hasGoals
          ? Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: SizedBox(
          width: 70,
          height: 70,
          child: FloatingActionButton(
            onPressed: _createNewGoal,
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Image.asset(
              'assets/images/+ btn.png',
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => const Icon(Icons.add_circle, size: 60, color: Color(0xFF1E89EF)),
            ),
          ),
        ),
      )
          : null, // Hilangkan tombol FAB di empty state (karena sudah ada tombol besar di tengah)
    );
  }

  // ==========================================
  // VIEW 1: EMPTY STATE (TAMPILAN AWAL)
  // ==========================================
  Widget _buildEmptyStateView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          "YourGoal",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1E89EF),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "Welcome !",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const Spacer(),

        // Logo Roket
        Center(
          child: Image.asset(
            'assets/images/RocketLogo.png',
            width: 150,
            height: 150,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.rocket_launch, size: 100, color: Colors.blue),
          ),
        ),
        const SizedBox(height: 24),

        // Text Tengah
        const Center(
          child: Text(
            "Ready to achieve Great Things?",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            "Let's start by setting your first goal",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(height: 30),

        // Tombol Gradient Besar
        SizedBox(
          width: double.infinity,
          height: 60,
          child: GradientButton(
            borderRadius: 16,
            onPressed: _createNewGoal, // Panggil fungsi navigasi
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Color(0xFF5CDFFB), size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Create your first goal",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(flex: 2),
      ],
    );
  }

  // ==========================================
  // VIEW 2: DASHBOARD (JIKA DATA ADA)
  // ==========================================
  Widget _buildDashboardView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            "MyGoal",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E89EF),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Keep Spirit & Never Give Up",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),

          // LIST GOAL DINAMIS DARI SERVICE
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _dataService.roadmaps.length,
            itemBuilder: (context, index) {
              final roadmap = _dataService.roadmaps[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: GestureDetector(
                  onTap: () {
                    context.pushNamed('goalDetail', extra: roadmap).then((_) {
                      setState(() {});
                    });
                  },
                  child: GoalCard(
                    title: roadmap.title,
                    time: roadmap.time,
                    progress: roadmap.progress,
                    status: roadmap.status,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),
          const Text(
            "My Stats",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Stats Cards
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: "Goals\nCreated",
                  value: "${_dataService.roadmaps.length}", // Dinamis
                  icon: Icons.rocket_launch_outlined,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: StatCard(
                  label: "Goals\nAchieved",
                  value: "0", // Bisa diupdate nanti sesuai logika completed
                  icon: Icons.assignment_turned_in_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(
                child: StatCard(
                  label: "Days\nActive",
                  value: "1",
                  icon: Icons.bar_chart_rounded,
                  isBlue: true,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: SizedBox(),
              ),
            ],
          ),
          const SizedBox(height: 100), // Space untuk FAB
        ],
      ),
    );
  }
}
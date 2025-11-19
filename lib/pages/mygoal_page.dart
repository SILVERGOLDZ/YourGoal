import 'package:flutter/material.dart';
import 'package:tes/Widget/base_page.dart';
import 'package:tes/Widget/gradient_button.dart';

import 'package:tes/Widget/goal_card.dart';
import 'package:tes/Widget/stat_card.dart';

class MyGoalPage extends StatefulWidget {
  const MyGoalPage({super.key});

  @override
  State<MyGoalPage> createState() => _MyGoalPageState();
}

class _MyGoalPageState extends State<MyGoalPage> {
  // Simple state variable to toggle views for testing
  bool _hasGoals = false;

  void _createNewGoal() {
    setState(() {
      _hasGoals = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BasePage(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: _hasGoals ? _buildDashboardView() : _buildEmptyStateView(),
          ),
        ),
      ),
      floatingActionButton: _hasGoals
          ? FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF1E89EF),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      )
          : null,
    );
  }

  // ==========================================
  // VIEW 1: EMPTY STATE (First Image)
  // ==========================================
  Widget _buildEmptyStateView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          "GOOAL",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900, // Extra bold
            color: const Color(0xFF1E89EF), // Blue color from image
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
        const Spacer(), // Pushes content to the middle/bottom

        // Big Rocket Logo from assets
        Center(
          child: Image.asset(
            'assets/images/RocketLogo.png',
            width: 150, // Customize ni ukuran hehehehe
            height: 150,
          ),
        ),
        const SizedBox(height: 24),

        // Center Text
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

        // The Gradient Button
        SizedBox(
          width: double.infinity,
          height: 60,
          child: GradientButton(
            borderRadius: 16,
            onPressed: _createNewGoal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // The white plus circle icon
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
        const Spacer(flex: 2), // Adds more space at bottom
      ],
    );
  }

  // ==========================================
  // VIEW 2: DASHBOARD / POPULATED (Second Image)
  // ==========================================
  Widget _buildDashboardView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // ... Header texts ...

          // NOW USING CLEAN CUSTOM WIDGETS
          const GoalCard(
            title: "Menjadi Software Designer\nProfessional",
            time: "2 Weeks",
            progress: 0.75,
            status: "In Progress",
          ),
          const SizedBox(height: 16),
          const GoalCard(
            title: "Mengikuti Marathon Tingkat\nNasional",
            time: "3 Weeks",
            progress: 0.50,
            status: "In Progress",
          ),

          const SizedBox(height: 24),
          // ... Stats Header ...

          Row(
            children: const [
              Expanded(
                child: StatCard(
                  label: "Goals\nCreated",
                  value: "2",
                  icon: Icons.rocket_launch_outlined,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  label: "Goals\nAchieved",
                  value: "7",
                  icon: Icons.assignment_turned_in_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const StatCard(
            label: "Days\nActive",
            value: "14",
            icon: Icons.bar_chart_rounded,
            isBlue: true,
            fullWidth: true,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

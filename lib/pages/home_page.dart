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
  final GoalDataService _dataService = GoalDataService();

  void _showDeleteDialog(BuildContext context, RoadmapModel roadmap) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Goal"),
        content: Text(
          'Delete goal "${roadmap.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);

              if (roadmap.id != null) {
                await GoalDataService().deleteRoadmap(roadmap.id!);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }


  void _createNewGoal() {
    context.pushNamed('newgoal');
    // Tidak perlu setState karena StreamBuilder akan otomatis update
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan StreamBuilder untuk membungkus seluruh konten
    return StreamBuilder<List<RoadmapModel>>(
      stream: _dataService.getRoadmapsStream(),
      builder: (context, snapshot) {
        // 1. Loading State
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // 2. Error State
        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text("Error: ${snapshot.error}")));
        }

        // 3. Ambil Data
        final roadmaps = snapshot.data ?? [];
        final bool hasGoals = roadmaps.isNotEmpty;

        return Scaffold(
          body: BasePage(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                // Pass data roadmaps ke dashboard view
                child: hasGoals ? _buildDashboardView(roadmaps) : _buildEmptyStateView(),
              ),
            ),
          ),

          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: hasGoals
              ? Padding(
            padding: const EdgeInsets.only(bottom: 80.0),
            child: SizedBox(
              width: 70, height: 70,
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
              : null,
        );
      },
    );
  }

  // View Kosong
  Widget _buildEmptyStateView() {
    return Column(
      children: [
        const SizedBox(height: 50),
        const Text("YourGoal", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1E89EF))),
        const Spacer(),
        Image.asset('assets/images/RocketLogo.png', width: 150),
        const SizedBox(height: 20),
        const Text("Let's create your first goal!"),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: GradientButton(
            borderRadius: 16,
            onPressed: _createNewGoal,
            child: const Text("Create your first goal", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const Spacer(flex: 2),
      ],
    );
  }

  // View Dashboard (Menerima Data dari Stream)
  Widget _buildDashboardView(List<RoadmapModel> roadmaps) {
    // Hitung Stats Real
    int totalCreated = roadmaps.length;
    int totalAchieved = roadmaps.where((r) => r.progress == 1.0).length;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text("MyGoal", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1E89EF))),
          const SizedBox(height: 16),
          const Text("Keep Spirit & Never Give Up", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),

          // LISTVIEW BUILDER (Data dari Firebase)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: roadmaps.length,
            itemBuilder: (context, index) {
              final roadmap = roadmaps[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: GestureDetector(
                  onTap: () {
                    // Kirim data ke detail
                    context.pushNamed('goalDetail', extra: roadmap);
                  },
                  onLongPress: () {
                    _showDeleteDialog(context, roadmap);
                  },
                  child: GoalCard(
                    title: roadmap.title,
                    time: roadmap.time,
                    progress: roadmap.progress,
                    status: roadmap.dynamic_status,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),
          const Text("My Stats", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // STATS REALTIME
          Row(
            children: [
              Expanded(child: StatCard(label: "Goals\nCreated", value: "$totalCreated", icon: Icons.rocket_launch_outlined)),
              const SizedBox(width: 16),
              Expanded(child: StatCard(label: "Goals\nAchieved", value: "$totalAchieved", icon: Icons.assignment_turned_in_outlined)),
            ],
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/goaldata_service.dart';

class RoadmapDetailScreen extends StatefulWidget {
  final RoadmapModel? roadmap;
  const RoadmapDetailScreen({super.key, this.roadmap});

  @override
  State<RoadmapDetailScreen> createState() => _RoadmapDetailScreenState();
}

class _RoadmapDetailScreenState extends State<RoadmapDetailScreen> {
  late RoadmapModel _currentRoadmap;

  @override
  void initState() {
    super.initState();
    if (widget.roadmap != null) {
      _currentRoadmap = widget.roadmap!;
    }
  }

  // --- FUNGSI UPDATE FIREBASE ---
  void _markStepAsComplete(StepModel step, String? comment) async {
    setState(() {
      step.isCompleted = true;
      step.status = "Complete";
      step.comment = comment?.isNotEmpty == true ? comment : null;
      step.completedAt = DateTime.now();
    });

    await GoalDataService().updateRoadmap(_currentRoadmap);
  }


  @override
  Widget build(BuildContext context) {
    if (widget.roadmap == null) return const Scaffold(body: Center(child: Text("No Data")));

    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => context.pop()),
        title: Text('Roadmap Detail', style: textTheme.titleLarge?.copyWith(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_currentRoadmap.title, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 24)),
            const SizedBox(height: 8),
            Text(_currentRoadmap.description, style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
            const SizedBox(height: 30),

            // Progress Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Progress", style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
                Text("${(_currentRoadmap.progress * 100).toInt()}%", style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF1E89EF))),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(value: _currentRoadmap.progress, minHeight: 8, backgroundColor: Colors.grey[200], valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1E89EF))),
            ),
            const SizedBox(height: 30),

            Text("Goals", style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20)),
            const SizedBox(height: 16),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _currentRoadmap.steps.length,
              itemBuilder: (context, index) {
                final step = _currentRoadmap.steps[index];
                return _buildGoalCard(context, step, index);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget Card & Popup Logic (Sama, tapi panggil _markStepAsComplete di tombol Finish)
  Widget _buildGoalCard(BuildContext context, StepModel step, int index) {
    final bool isCompleted = step.isCompleted;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: step.isCompleted
              ? null
              : () => _showGoalDetailDialog(context, step),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Row(
              children: [
                IgnorePointer(child: Transform.scale(scale: 1.3, child: Checkbox(value: isCompleted, onChanged: (val){}, activeColor: const Color(0xFF1E89EF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))))),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(step.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)), Text(step.status, style: const TextStyle(color: Color(0xFF1E89EF), fontWeight: FontWeight.w500, fontSize: 14)), if (step.isCompleted) ...[
                  const SizedBox(height: 4),
                  Text(
                    "Completed at: ${step.completedAt}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  if (step.comment != null)
                    Text(
                      "Comment: ${step.comment}",
                      style: const TextStyle(fontSize: 13),
                    ),
                ]
                ]))
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showGoalDetailDialog(BuildContext context, StepModel step) {
    final commentController = TextEditingController();
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step.title,
                    style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                Text(step.description),
                const SizedBox(height: 12),

                Text("Message", style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(step.message),

                const SizedBox(height: 20),

                /// COMMENT (OPSIONAL)
                TextField(
                  controller: commentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Optional comment...",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),

                const SizedBox(height: 20),

                /// WARNING
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "Jika kamu menyelesaikan step ini, kamu tidak bisa membatalkannya.\n"
                        "Apakah kamu yakin dan berintegritas dalam menyelesaikan step ini?",
                    style: TextStyle(color: Colors.red),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      _markStepAsComplete(
                        step,
                        commentController.text.trim(),
                      );
                      Navigator.pop(context);
                    },
                    child: const Text("I have completed this goal"),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
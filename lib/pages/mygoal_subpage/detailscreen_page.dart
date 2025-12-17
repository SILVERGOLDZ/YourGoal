import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/goal_model.dart';
import '../../services/goaldata_service.dart';

class RoadmapDetailScreen extends StatefulWidget {
  final RoadmapModel? roadmap;
  final bool isReadOnly; // Tambahkan parameter ini

  const RoadmapDetailScreen({
    super.key,
    this.roadmap,
    this.isReadOnly = false, // Default false agar fitur utama tetap normal
  });

  @override
  State<RoadmapDetailScreen> createState() => _RoadmapDetailScreenState();
}

class _RoadmapDetailScreenState extends State<RoadmapDetailScreen> {
  late RoadmapModel _currentRoadmap;
  List<StepModel> _steps = [];

  @override
  void initState() {
    super.initState();
    if (widget.roadmap != null) {
      _currentRoadmap = widget.roadmap!;
      _steps = List.from(_currentRoadmap.steps);
    }
  }

  // --- FUNGSI UPDATE FIREBASE ---
  void _markStepAsComplete(StepModel step, String? comment) async {
    // Validasi: deadline sudah lewat (gunakan date comparison yang konsisten)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadlineDate = DateTime(step.deadline.year, step.deadline.month, step.deadline.day);

    if (deadlineDate.isBefore(today)) {
      _showIntegrityWarning(
        "Deadline Already Passed",
        "The deadline for this step was ${step.deadline.day}/${step.deadline.month}/${step.deadline.year}. "
            "Are you sure you completed this on time with integrity?",
            () {
          _completeStep(step, comment);
        },
      );
      return;
    }

    _completeStep(step, comment);
  }

  void _completeStep(StepModel step, String? comment) async {
    setState(() {
      step.isCompleted = true;
      step.status = "Complete";
      step.comment = comment?.isNotEmpty == true ? comment : null;
      step.completedAt = DateTime.now();
    });

    await GoalDataService().updateRoadmap(_currentRoadmap);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _showIntegrityWarning(String title, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Yes, I'm Sure"),
          ),
        ],
      ),
    );
  }

  // Navigasi ke NewRoadmapScreen dengan data existing
  void _editRoadmap() {
    context.push('/newgoal', extra: _currentRoadmap);
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
        actions: [
          if (!widget.isReadOnly)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.black),
              onPressed: _editRoadmap,
              tooltip: 'Edit Roadmap',
            ),
        ],
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

            widget.isReadOnly
                ? ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _steps.length,
              itemBuilder: (context, index) => _buildGoalCard(context, _steps[index], index, key: ValueKey(index)),
            )
                :
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _steps.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = _steps.removeAt(oldIndex);
                  _steps.insert(newIndex, item);
                  _currentRoadmap.steps = _steps;
                });
                GoalDataService().updateRoadmap(_currentRoadmap);
              },
              itemBuilder: (context, index) {
                final step = _steps[index];
                return _buildGoalCard(context, step, index, key: ValueKey(step.title + index.toString()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, StepModel step, int index, {required Key key}) {
    final bool isCompleted = step.isCompleted;
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: (widget.isReadOnly || step.isCompleted)
              ? null
              : () => _showGoalDetailDialog(context, step),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Row(
              children: [
                if (!widget.isReadOnly) ...[
                  Icon(Icons.drag_handle, color: Colors.grey[400]),
                  const SizedBox(width: 8),
                ],                const SizedBox(width: 8),
                IgnorePointer(child: Transform.scale(scale: 1.3, child: Checkbox(value: isCompleted, onChanged: (val){}, activeColor: const Color(0xFF1E89EF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))))),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(step.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  Text(step.status, style: const TextStyle(color: Color(0xFF1E89EF), fontWeight: FontWeight.w500, fontSize: 14)),
                  Text(
                    "Deadline: ${step.deadline.day}/${step.deadline.month}/${step.deadline.year}",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  if (step.isCompleted) ...[
                    const SizedBox(height: 4),
                    Text(
                      "Completed at: ${step.completedAt?.day}/${step.completedAt?.month}/${step.completedAt?.year}",
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

    // Cek apakah deadline sudah lewat (bukan hari ini)
    // Cek apakah deadline sudah lewat (termasuk hari ini masih bisa)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadlineDate = DateTime(step.deadline.year, step.deadline.month, step.deadline.day);
    final isDeadlinePassed = deadlineDate.isBefore(today);

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
                    color: isDeadlinePassed ? Colors.orange.withOpacity(0.1) : Colors.red.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isDeadlinePassed
                        ? "⚠️ Deadline is overdue (${step.deadline.day}/${step.deadline.month}/${step.deadline.year}).\n"
                        : "After finishing this step, you can't undo it.\n"
                        "Are you sure you have completed this step?",
                    style: TextStyle(color: isDeadlinePassed ? Colors.orange[800] : Colors.red),
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDeadlinePassed ? Colors.orange : null,
                    ),
                    child: Text(
                        isDeadlinePassed
                            ? "Complete (Late)"
                            : "I have completed this goal"
                    ),
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
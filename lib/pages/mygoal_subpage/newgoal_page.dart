import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/goaldata_service.dart'; // Import Model & Service

class NewRoadmapScreen extends StatefulWidget {
  const NewRoadmapScreen({super.key});

  @override
  State<NewRoadmapScreen> createState() => _NewRoadmapScreenState();
}

class _NewRoadmapScreenState extends State<NewRoadmapScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final List<StepModel> _addedSteps = [];
  bool _isLoading = false; // Loading indicator saat save

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // --- SAVE LOGIC (FIREBASE) ---
  Future<void> _saveNewGoal() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Title is required")));
      return;
    }
    if (_addedSteps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please add at least 1 step")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Buat Model
      RoadmapModel newRoadmap = RoadmapModel(
        title: _titleController.text,
        description: _descController.text.isNotEmpty ? _descController.text : _titleController.text,
        time: "Just Started", // Bisa diupdate logicnya nanti
        status: "In Progress",
        steps: _addedSteps,
      );

      // 2. Simpan ke Firestore via Service
      await GoalDataService().addRoadmap(newRoadmap);

      if (mounted) {
        context.pop(); // Kembali ke MyGoalPage
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... Bagian UI build TextField dan List Step sama persis dengan sebelumnya ...
    // ... Hanya ubah tombol "Create Goal" untuk handle loading state ...

    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black, size: 28),
          onPressed: () => context.pop(),
        ),
        title: Text('New Roadmap', style: textTheme.titleLarge?.copyWith(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveNewGoal, // Disable saat loading
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0B57CF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text('Create Goal', style: textTheme.labelLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMainTextField(context, controller: _titleController, hint: 'Roadmap Title (e.g. Master Flutter)', maxLines: 1),
            const SizedBox(height: 20),
            _buildMainTextField(context, controller: _descController, hint: 'Goal Description / Motivation', maxLines: 4),
            const SizedBox(height: 30),
            Text('Goals / Steps', style: textTheme.headlineSmall?.copyWith(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 16),

            // List Preview Steps
            if (_addedSteps.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text("No steps added yet.\nPress 'Add Step' to start planning.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500]))),
              )
            else
              ..._addedSteps.asMap().entries.map((entry) => _buildStepPreviewCard(context, entry.key + 1, entry.value)),

            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity, height: 55,
              child: TextButton(
                onPressed: () => _showStepEditorDialog(context),
                style: TextButton.styleFrom(backgroundColor: const Color(0xFFE3F2FD), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text('Add Step', style: textTheme.labelLarge?.copyWith(color: const Color(0xFF1E88E5), fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets & Popup Logic sama persis dengan kode sebelumnya ---
  // (Pastikan method _showStepEditorDialog, _buildMainTextField, _buildStepPreviewCard tetap ada seperti sebelumnya)
  // ... Paste helper widgets here if full rewrite is needed, otherwise keep them ...

  Widget _buildMainTextField(BuildContext context, {required TextEditingController controller, required String hint, required int maxLines}) {
    final textTheme = Theme.of(context).textTheme;
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: textTheme.bodyLarge?.copyWith(fontSize: 16, color: Colors.grey[800]),
      decoration: InputDecoration(
        hoverColor: Colors.transparent,
        filled: true,
        fillColor: const Color(0xFFF0F0F0),
        hintText: hint,
        hintStyle: textTheme.bodyLarge?.copyWith(color: Colors.grey[600], fontSize: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.all(20),
      ),
    );
  }

  Widget _buildStepPreviewCard(BuildContext context, int number, StepModel step) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
      child: Row(
        children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFD1E5FA), borderRadius: BorderRadius.circular(8)), child: Center(child: Text("$number", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1976D2))))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(step.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 4), Text(step.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600], fontSize: 13))])),
          IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => setState(() => _addedSteps.remove(step)))
        ],
      ),
    );
  }

  void _showStepEditorDialog(BuildContext context) {
    // ... (Kode popup sama seperti sebelumnya, hanya memastikan import StepModel benar) ...
    final textTheme = Theme.of(context).textTheme;
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final deadlineController = TextEditingController();
    final subtaskController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        bool isSubTaskInputVisible = false;
        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor: Colors.white,
            insetPadding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel(context, "What I should do :"),
                    const SizedBox(height: 8),
                    _buildPopupTextField(context, controller: titleController, hint: "e.g Win a Tournament"),
                    const SizedBox(height: 20),
                    _buildLabel(context, "Description :"),
                    const SizedBox(height: 8),
                    _buildPopupTextField(context, controller: descriptionController, hint: "Details..."),
                    const SizedBox(height: 20),
                    _buildLabel(context, "Deadline :"),
                    const SizedBox(height: 8),
                    _buildPopupTextField(context, controller: deadlineController, hint: "25/06/2025", icon: Icons.calendar_today),
                    const SizedBox(height: 20),
                    _buildLabel(context, "Letter for future me :"),
                    const SizedBox(height: 8),
                    _buildPopupTextField(context, controller: messageController, hint: "Don't give up..."),
                    const SizedBox(height: 30),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          if (titleController.text.isEmpty) return;
                          // Gabung deskripsi + deadline
                          String fullDesc = descriptionController.text;
                          if (deadlineController.text.isNotEmpty) fullDesc += "\nDeadline: ${deadlineController.text}";
                          if (fullDesc.isEmpty) fullDesc = "No details.";

                          StepModel newStep = StepModel(
                            title: titleController.text,
                            status: "In Progress",
                            isCompleted: false,
                            description: fullDesc,
                            subtasks: subtaskController.text.split('\n').where((s)=>s.trim().isNotEmpty).toList(),
                            message: messageController.text.isNotEmpty ? messageController.text : "Keep going!",
                          );
                          this.setState(() => _addedSteps.add(newStep));
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF007BFF), foregroundColor: Colors.white),
                        child: const Text("Finish"),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    return Text(text, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 15));
  }
  Widget _buildPopupTextField(BuildContext context, {required TextEditingController controller, required String hint, IconData? icon}) {
    return TextField(controller: controller, decoration: InputDecoration(hintText: hint, filled: true, fillColor: const Color(0xFFF0F0F0), suffixIcon: icon != null ? Icon(icon) : null, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)));
  }
}
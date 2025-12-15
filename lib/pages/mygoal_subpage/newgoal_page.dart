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
              ..._addedSteps.asMap().entries.map((entry) => _buildStepPreviewCard(context, entry.key, entry.value)),

            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity, height: 55,
              //Add step button
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

  Widget _buildStepPreviewCard(BuildContext context, int index, StepModel step) {
    return GestureDetector(
      onTap: () => _showStepEditorDialog(
        context,
        existingStep: step,
        editIndex: index,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          color: Colors.white,
        ),
        child: Row(
          children: [
            CircleAvatar(child: Text("${index + 1}")),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    "Deadline: ${step.deadline.day}/${step.deadline.month}/${step.deadline.year}",
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),

            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                setState(() => _addedSteps.removeAt(index));
              },
            ),
          ],
        ),
      ),
    );
  }



  void _showStepEditorDialog(BuildContext context, {StepModel? existingStep, int? editIndex}) {
    final titleController = TextEditingController(text: existingStep?.title);
    final descController = TextEditingController(text: existingStep?.description == "No description added" ? "" : existingStep?.description);
    final messageController = TextEditingController(text: existingStep?.message == "No message added" ? "" : existingStep?.message);

    DateTime? selectedDeadline = existingStep?.deadline;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> pickDate() async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDeadline ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setDialogState(() => selectedDeadline = picked);
              }
            }

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel(context, "What should I do *"),
                        const SizedBox(height: 10),
                        _buildPopupTextField(context, controller: titleController, hint: "Win a tournament"),

                        const SizedBox(height: 16),

                        _buildLabel(context, "Deadline *"),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: pickDate,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F0F0),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today),
                                const SizedBox(width: 12),
                                Text(
                                  selectedDeadline == null
                                      ? "Select deadline"
                                      : "${selectedDeadline!.day}/${selectedDeadline!.month}/${selectedDeadline!.year}",
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        _buildLabel(context, "Sub task to complete this target (optional)"),
                        const SizedBox(height: 10),
                        _buildPopupTextField(context, controller: descController, hint: "1. Talk to senior for guidance\n2. Learn by watching others compete\n3. etc"),

                        const SizedBox(height: 16),

                        _buildLabel(context, "Letter for future me (optional)"),
                        const SizedBox(height: 10),
                        _buildPopupTextField(context, controller: messageController, hint: "Don't give up..."),

                        const SizedBox(height: 24),

                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              if (titleController.text.trim().isEmpty || selectedDeadline == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Title & Deadline are required")),
                                );
                                return;
                              }

                              final step = StepModel(
                                title: titleController.text.trim(),
                                deadline: selectedDeadline!,
                                description: descController.text.trim().isEmpty ? "No description added" : descController.text.trim(),
                                message: messageController.text.trim().isEmpty ? "No message added" : messageController.text.trim(),

                                // 🔑 pertahankan data lama saat edit
                                isCompleted: existingStep?.isCompleted ?? false,
                                status: existingStep?.status ?? 'In Progress',
                                comment: existingStep?.comment,
                                completedAt: existingStep?.completedAt,
                              );

                              setState(() {
                                if (editIndex != null) {
                                  _addedSteps[editIndex] = step;
                                } else {
                                  _addedSteps.add(step);
                                }
                              });

                              Navigator.pop(context);
                            },
                            child: Text(existingStep != null ? "Update Step" : "Add Step"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            );
          },
        );
      },
    );
  }



  Widget _buildLabel(BuildContext context, String text) {
    return Text(text, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 15));
  }
  Widget _buildPopupTextField(BuildContext context, {required TextEditingController controller, required String hint, IconData? icon}) {
    return TextField(controller: controller, maxLines: null, decoration: InputDecoration(hintText: hint, filled: true, fillColor: const Color(0xFFF0F0F0), suffixIcon: icon != null ? Icon(icon) : null, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)));
  }
}
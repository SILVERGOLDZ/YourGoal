import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/goaldata_service.dart';

class NewRoadmapScreen extends StatefulWidget {
  final RoadmapModel? existingRoadmap; // untuk edit mode
  const NewRoadmapScreen({super.key, this.existingRoadmap});

  @override
  State<NewRoadmapScreen> createState() => _NewRoadmapScreenState();
}

class _NewRoadmapScreenState extends State<NewRoadmapScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final List<StepModel> _addedSteps = [];
  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingRoadmap != null) {
      _isEditMode = true;
      _titleController.text = widget.existingRoadmap!.title;
      _descController.text = widget.existingRoadmap!.description;
      _addedSteps.addAll(widget.existingRoadmap!.steps);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // Validasi deadline steps - hanya saat save, bukan saat edit individual
  String? _validateStepDeadlines() {
    for (int i = 1; i < _addedSteps.length; i++) {
      if (_addedSteps[i].deadline.isBefore(_addedSteps[i - 1].deadline) ||
          _addedSteps[i].deadline.isAtSameMomentAs(_addedSteps[i - 1].deadline)) {
        return "Step ${i + 1} deadline must be after Step $i deadline.\n"
            "Step $i: ${_addedSteps[i - 1].deadline.day}/${_addedSteps[i - 1].deadline.month}/${_addedSteps[i - 1].deadline.year}\n"
            "Step ${i + 1}: ${_addedSteps[i].deadline.day}/${_addedSteps[i].deadline.month}/${_addedSteps[i].deadline.year}";
      }
    }
    return null;
  }

  String _formattedToday() {
    final now = DateTime.now();
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return "${now.day} ${months[now.month - 1]} ${now.year}";
  }



  Future<void> _saveNewGoal() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Title is required")));
      return;
    }
    if (_addedSteps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please add at least 1 step")));
      return;
    }

    // Validasi deadline
    String? deadlineError = _validateStepDeadlines();
    if (deadlineError != null) {
      _showErrorDialog("Invalid Deadline Order", deadlineError);
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isEditMode && widget.existingRoadmap != null) {
        // UPDATE
        widget.existingRoadmap!.title = _titleController.text;
        widget.existingRoadmap!.description = _descController.text.isNotEmpty ? _descController.text : _titleController.text;
        widget.existingRoadmap!.steps = _addedSteps;
        await GoalDataService().updateRoadmap(widget.existingRoadmap!);
      } else {
        // CREATE
        RoadmapModel newRoadmap = RoadmapModel(
          title: _titleController.text,
          description: _descController.text.isNotEmpty ? _descController.text : _titleController.text,
          time: _formattedToday(),
          steps: _addedSteps,
        );
        await GoalDataService().addRoadmap(newRoadmap);
      }

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK"),
          ),
        ],
      ),
    );
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
        title: Text(
          _isEditMode ? 'Edit Roadmap' : 'New Roadmap',
          style: textTheme.titleLarge?.copyWith(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveNewGoal,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0B57CF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
              _isEditMode ? 'Update Goal' : 'Create Goal',
              style: textTheme.labelLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
            ),
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

            if (_addedSteps.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text("No steps added yet.\nPress 'Add Step' to start planning.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500]))),
              )
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _addedSteps.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex -= 1;
                    final item = _addedSteps.removeAt(oldIndex);
                    _addedSteps.insert(newIndex, item);
                  });
                },
                itemBuilder: (context, index) {
                  final step = _addedSteps[index];
                  return _buildStepPreviewCard(context, index, step, key: ValueKey(step.title + index.toString()));
                },
              ),

            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 55,
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

  Widget _buildStepPreviewCard(BuildContext context, int index, StepModel step, {required Key key}) {
    final bool isCompleted = step.isCompleted;

    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isCompleted ? Colors.green[300]! : Colors.grey[300]!),
        color: isCompleted ? Colors.green[50] : Colors.white,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isCompleted
              ? null
              : () => _showStepEditorDialog(
            context,
            existingStep: step,
            editIndex: index,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.drag_handle, color: Colors.grey[400]),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: isCompleted ? Colors.green : const Color(0xFF1E89EF),
                  child: Text("${index + 1}", style: const TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isCompleted ? Colors.grey[700] : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Deadline: ${step.deadline.day}/${step.deadline.month}/${step.deadline.year}",
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      if (isCompleted)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, size: 16, color: Colors.green[700]),
                              const SizedBox(width: 4),
                              Text(
                                "Completed",
                                style: TextStyle(color: Colors.green[700], fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                if (!isCompleted)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      setState(() => _addedSteps.removeAt(index));
                    },
                  )
                else
                  Icon(Icons.lock, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showStepEditorDialog(BuildContext context, {StepModel? existingStep, int? editIndex}) {
    final bool isCompletedStep = existingStep?.isCompleted ?? false;

    if (isCompletedStep) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completed steps cannot be edited or deleted")),
      );
      return;
    }

    final titleController = TextEditingController(text: existingStep?.title);
    final descController = TextEditingController(text: existingStep?.description == "No description added" ? "" : existingStep?.description);
    final messageController = TextEditingController(text: existingStep?.message == "No message added" ? "" : existingStep?.message);

    DateTime? selectedDeadline = existingStep?.deadline;

    // Minimum deadline adalah hari ini (tidak lagi bergantung pada step sebelumnya)
    DateTime minDeadline = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> pickDate() async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDeadline ?? minDeadline,
                firstDate: minDeadline,
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
                              Expanded(
                                child: Text(
                                  selectedDeadline == null
                                      ? "Select deadline"
                                      : "${selectedDeadline!.day}/${selectedDeadline!.month}/${selectedDeadline!.year}",
                                ),
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
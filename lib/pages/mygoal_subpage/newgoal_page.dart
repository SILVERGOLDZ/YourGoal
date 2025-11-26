import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/goaldata_service.dart'; // Import Model & Service

class NewRoadmapScreen extends StatefulWidget {
  const NewRoadmapScreen({super.key});

  @override
  State<NewRoadmapScreen> createState() => _NewRoadmapScreenState();
}

class _NewRoadmapScreenState extends State<NewRoadmapScreen> {
  // Controller untuk Judul & Deskripsi Roadmap Utama (Parent)
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  // List untuk menampung Step yang sudah dibuat lewat Popup
  final List<StepModel> _addedSteps = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // --- LOGIKA UTAMA: SIMPAN KE DATABASE ---
  void _saveNewGoal() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Roadmap Title cannot be empty")),
      );
      return;
    }

    if (_addedSteps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add at least 1 step")),
      );
      return;
    }

    // Buat Object RoadmapModel
    RoadmapModel newRoadmap = RoadmapModel(
      title: _titleController.text,
      description: _descController.text.isNotEmpty
          ? _descController.text
          : _titleController.text,
      time: "Just Started",
      status: "In Progress",
      steps: _addedSteps, // Masukkan list step yang sudah diisi lewat popup
    );

    // Simpan ke Service
    GoalDataService().addRoadmap(newRoadmap);

    // Kembali ke halaman MyGoal
    context.pop();
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
          'New Roadmap',
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
            onPressed: _saveNewGoal,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0B57CF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              'Create Goal',
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
            // Input Judul Roadmap Utama
            _buildMainTextField(
                context,
                controller: _titleController,
                hint: 'Roadmap Title (e.g. Master Flutter)',
                maxLines: 1
            ),
            const SizedBox(height: 20),

            // Input Deskripsi Roadmap Utama
            _buildMainTextField(
                context,
                controller: _descController,
                hint: 'Goal Description / Motivation',
                maxLines: 4
            ),
            const SizedBox(height: 30),

            Text(
              'Goals / Steps',
              style: textTheme.headlineSmall?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // LIST STEP YANG SUDAH DITAMBAHKAN
            if (_addedSteps.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    "No steps added yet.\nPress 'Add Step' to start planning.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ),
              )
            else
              ..._addedSteps.asMap().entries.map((entry) {
                return _buildStepPreviewCard(context, entry.key + 1, entry.value);
              }),

            const SizedBox(height: 10),

            // Tombol Tambah Step (MEMBUKA POPUP)
            SizedBox(
              width: double.infinity,
              height: 55,
              child: TextButton(
                onPressed: () => _showStepEditorDialog(context),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFE3F2FD),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Add Step',
                  style: textTheme.labelLarge?.copyWith(
                    color: const Color(0xFF1E88E5),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- WIDGET INPUT UTAMA ---
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(20),
      ),
    );
  }

  // --- WIDGET CARD PREVIEW STEP ---
  Widget _buildStepPreviewCard(BuildContext context, int number, StepModel step) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: const Color(0xFFD1E5FA), borderRadius: BorderRadius.circular(8)),
            child: Center(child: Text("$number", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1976D2)))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                // Tampilkan sedikit deskripsi di preview
                Text(
                    step.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13)
                ),
                const SizedBox(height: 2),
                Text(
                    "${step.subtasks.length} Subtasks",
                    style: const TextStyle(color: Color(0xFF1E89EF), fontSize: 12, fontWeight: FontWeight.bold)
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              setState(() {
                _addedSteps.remove(step);
              });
            },
          )
        ],
      ),
    );
  }

  // --- INTEGRASI POPUP EDITOR ---
  void _showStepEditorDialog(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Controller lokal untuk popup
    final titleController = TextEditingController();
    final descriptionController = TextEditingController(); // Controller Baru
    final deadlineController = TextEditingController();
    final subtaskController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        bool isSubTaskInputVisible = false;

        return StatefulBuilder(
          builder: (context, setState) {
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
                      // 1. JUDUL STEP
                      _buildLabel(context, "What I should do :"),
                      const SizedBox(height: 8),
                      _buildPopupTextField(context, controller: titleController, hint: "e.g Win a Tournament (top 3)"),

                      const SizedBox(height: 20),

                      // 2. DESKRIPSI STEP (BARU DITAMBAHKAN)
                      _buildLabel(context, "Description :"),
                      const SizedBox(height: 8),
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        minLines: 2,
                        style: textTheme.bodyMedium,
                        decoration: InputDecoration(
                          hoverColor: Colors.transparent,
                          filled: true,
                          fillColor: const Color(0xFFF0F0F0),
                          hintText: "Explain the details of this step...",
                          hintStyle: textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 3. DEADLINE
                      _buildLabel(context, "Deadline :"),
                      const SizedBox(height: 8),
                      _buildPopupTextField(context, controller: deadlineController, hint: "e.g 25/06/2025", icon: Icons.calendar_today),

                      const SizedBox(height: 20),

                      // 4. SUBTASKS
                      _buildLabel(context, "Sub task to complete this target :"),
                      const SizedBox(height: 8),

                      if (!isSubTaskInputVisible)
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                isSubTaskInputVisible = true;
                              });
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFFD6E4FF),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            child: Text("Add sub task", style: textTheme.labelLarge?.copyWith(color: const Color(0xFF2F80ED), fontWeight: FontWeight.w600, fontSize: 16)),
                          ),
                        )
                      else
                        TextField(
                          controller: subtaskController,
                          maxLines: 5,
                          minLines: 2,
                          autofocus: true,
                          style: textTheme.bodyMedium,
                          decoration: InputDecoration(
                            hoverColor: Colors.transparent,
                            hintText: "e.g 1. Talk to senior\n2. Learn by watching",
                            hintStyle: textTheme.bodyMedium?.copyWith(color: Colors.grey[400], height: 1.5),
                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
                            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                          ),
                        ),

                      const SizedBox(height: 20),

                      // 5. MESSAGE
                      _buildLabel(context, "Letter for future me (optional) :"),
                      const SizedBox(height: 8),
                      TextField(
                        controller: messageController,
                        maxLines: 3,
                        minLines: 1,
                        style: textTheme.bodyMedium,
                        decoration: InputDecoration(
                          hoverColor: Colors.transparent,
                          hintText: "e.g Don't give up now...",
                          hintStyle: textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
                          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                        ),
                      ),

                      const SizedBox(height: 30),

                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {
                            if (titleController.text.isEmpty) return;

                            // Proses Subtasks
                            List<String> subtasks = [];
                            if (subtaskController.text.isNotEmpty) {
                              subtasks = subtaskController.text.split('\n').where((s) => s.trim().isNotEmpty).toList();
                            }

                            // Gabungkan Deadline ke dalam deskripsi jika ada, atau gunakan deskripsi saja
                            String fullDescription = descriptionController.text;
                            if (deadlineController.text.isNotEmpty) {
                              if (fullDescription.isNotEmpty) fullDescription += "\n\n";
                              fullDescription += "Deadline: ${deadlineController.text}";
                            }
                            if (fullDescription.isEmpty) fullDescription = "No details provided.";

                            // Buat StepModel
                            StepModel newStep = StepModel(
                              title: titleController.text,
                              status: "In Progress",
                              isCompleted: false,
                              description: fullDescription, // Simpan deskripsi + deadline
                              subtasks: subtasks,
                              message: messageController.text.isNotEmpty
                                  ? messageController.text
                                  : "Keep going!",
                            );

                            // Tambahkan ke List Parent
                            this.setState(() {
                              _addedSteps.add(newStep);
                            });

                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF007BFF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          child: Text("Finish", style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
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
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
    );
  }

  Widget _buildPopupTextField(BuildContext context, {required TextEditingController controller, required String hint, IconData? icon}) {
    final textTheme = Theme.of(context).textTheme;
    return TextField(
      controller: controller,
      style: textTheme.bodyMedium,
      decoration: InputDecoration(
        hoverColor: Colors.transparent,
        filled: true,
        fillColor: const Color(0xFFF0F0F0),
        hintText: hint,
        hintStyle: textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
        suffixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
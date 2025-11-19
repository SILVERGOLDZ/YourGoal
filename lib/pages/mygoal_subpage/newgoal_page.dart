import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
class NewRoadmapScreen extends StatefulWidget {
  const NewRoadmapScreen({super.key});

  @override
  State<NewRoadmapScreen> createState() => _NewRoadmapScreenState();
}

class _NewRoadmapScreenState extends State<NewRoadmapScreen> {
  final List<TextEditingController> _stepControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void dispose() {
    for (var controller in _stepControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addNewStep() {
    setState(() {
      _stepControllers.add(TextEditingController());
    });
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil TextTheme agar font sesuai dengan AppTheme (Nunito Sans)
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black, size: 28),
          onPressed: () {
            // MENGGUNAKAN GO ROUTER UNTUK PINDAH KE PAGE 'mygoal'
            // Pastikan nama 'mygoal' sesuai dengan properti 'name' di GoRoute Anda
            context.goNamed('mygoal');

            // ATAU jika Anda ingin menggunakan path (misal AppRoutes.mygoal berisi '/mygoal')
            // context.go(AppRoutes.mygoal);
          },
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
            onPressed: () {
              _showStepEditorDialog(context);
            },
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
            _buildCustomTextField(context, hint: 'Roadmap Title', maxLines: 1),
            const SizedBox(height: 20),
            _buildCustomTextField(context, hint: 'Goal Description', maxLines: 6),
            const SizedBox(height: 30),
            Text(
              'Goals',
              style: textTheme.headlineSmall?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            ..._stepControllers.asMap().entries.map((entry) {
              int index = entry.key;
              TextEditingController controller = entry.value;
              return _buildGoalItem(
                context,
                number: index + 1,
                controller: controller,
              );
            }),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: TextButton(
                onPressed: _addNewStep,
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

  // ============================================================
  // WIDGET CARD STEP
  // ============================================================
  Widget _buildGoalItem(BuildContext context, {required int number, required TextEditingController controller}) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFD1E5FA),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF1976D2),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Step $number",
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),

                TextField(
                  controller: controller,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  style: textTheme.bodyLarge?.copyWith(
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: "Description of Goal",
                    hintStyle: textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                        fontSize: 16
                    ),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Input Utama (Goal Description & Title) ---
  Widget _buildCustomTextField(BuildContext context, {required String hint, required int maxLines}) {
    final textTheme = Theme.of(context).textTheme;

    return TextField(
      maxLines: maxLines,
      style: textTheme.bodyLarge?.copyWith(
          fontSize: 16,
          color: Colors.grey[800]
      ),
      decoration: InputDecoration(
        hoverColor: Colors.transparent,
        filled: true,
        fillColor: const Color(0xFFF0F0F0),
        hintText: hint,
        hintStyle: textTheme.bodyLarge?.copyWith(
            color: Colors.grey[600],
            fontSize: 16
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(20),
      ),
    );
  }

  // --- POPUP EDITOR ---
  void _showStepEditorDialog(BuildContext context) {
    // Ambil TextTheme untuk dialog
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (context) {
        bool isSubTaskInputVisible = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
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
                      _buildPopupTextField(context, hint: "e.g Win a Tournament (top 3)"),
                      const SizedBox(height: 20),

                      _buildLabel(context, "Deadline :"),
                      const SizedBox(height: 8),
                      _buildPopupTextField(
                        context,
                        hint: "e.g 25/06/2025",
                        icon: Icons.keyboard_arrow_down,
                      ),
                      const SizedBox(height: 20),

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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              "Add sub task",
                              style: textTheme.labelLarge?.copyWith(
                                color: const Color(0xFF2F80ED),
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        )
                      else
                        TextField(
                          maxLines: 5,
                          minLines: 1,
                          autofocus: true,
                          style: textTheme.bodyMedium,
                          decoration: InputDecoration(
                            hoverColor: Colors.transparent,
                            hintText: "e.g 1. Talk to senior for guidance\n      2. Learn by watching others compete\n      3. etc",
                            hintStyle: textTheme.bodyMedium?.copyWith(color: Colors.grey[400], height: 1.5),
                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                          ),
                        ),

                      const SizedBox(height: 20),

                      _buildLabel(context, "Letter for future me (optional) :"),
                      const SizedBox(height: 8),
                      TextField(
                        maxLines: 3,
                        minLines: 1,
                        style: textTheme.bodyMedium,
                        decoration: InputDecoration(
                          hoverColor: Colors.transparent,
                          hintText: "e.g Don't give up now. If I reach this phase, I believe I am 90% closer!",
                          hintStyle: textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF007BFF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text(
                            "Finish",
                            style: textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white
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
      },
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 15,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildPopupTextField(BuildContext context, {required String hint, IconData? icon}) {
    final textTheme = Theme.of(context).textTheme;
    return TextField(
      style: textTheme.bodyMedium,
      decoration: InputDecoration(
        hoverColor: Colors.transparent,
        filled: true,
        fillColor: const Color(0xFFF0F0F0),
        hintText: hint,
        hintStyle: textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
        suffixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
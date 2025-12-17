import 'package:cloud_firestore/cloud_firestore.dart';

class StepModel {
  final String title;
  final String description;
  final String message;
  final DateTime deadline;
  bool isCompleted;
  String status;
  final List<String> subtasks;

  // Data tambahan saat selesai
  String? comment;
  DateTime? completedAt;

  StepModel({
    required this.title,
    required this.deadline,
    this.description = '',
    this.message = '',
    this.subtasks = const [],
    this.isCompleted = false,
    this.status = 'In Progress',
    this.comment,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'message': message,
      'deadline': Timestamp.fromDate(deadline),
      'subtasks': subtasks,
      'isCompleted': isCompleted,
      'status': status,
      "comment": comment,
      "completedAt": completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  factory StepModel.fromMap(Map<String, dynamic> map) {
    return StepModel(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      message: map['message'] ?? '',
      deadline: map['deadline'] != null
          ? (map['deadline'] as Timestamp).toDate()
          : DateTime.now(),
      subtasks: List<String>.from(map['subtasks'] ?? []),
      isCompleted: map['isCompleted'] ?? false,
      status: map['status'] ?? 'In Progress',
      comment: map['comment'],
      completedAt: map['completedAt'] != null
          ? (map['completedAt'] as Timestamp).toDate()
          : null,
    );
  }
}

class RoadmapModel {
  String? id; // ID Dokumen Firestore
  String title;
  String time;
  String description;
  List<StepModel> steps;

  RoadmapModel({
    this.id,
    required this.title,
    required this.time,
    required this.description,
    required this.steps,
  });

  // Hitung progress
  double get progress {
    if (steps.isEmpty) return 0.0;
    int completedCount = steps.where((s) => s.isCompleted).length;
    return completedCount / steps.length;
  }

  String get dynamic_status {
    return progress == 1.0 ? "Completed" : "In Progress";
  }

  // Ke Map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'time': time,
      'description': description,
      'steps': steps.map((x) => x.toMap()).toList(),
      'createdAt': FieldValue.serverTimestamp(),
      'status': dynamic_status,
    };
  }

  // Dari Firestore Snapshot
  factory RoadmapModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RoadmapModel(
      id: doc.id,
      title: data['title'] ?? '',
      time: data['time'] ?? '',
      description: data['description'] ?? '',
      steps: List<StepModel>.from(
        (data['steps'] ?? []).map((x) => StepModel.fromMap(x)),
      ),
    );
  }// Di dalam class RoadmapModel file goal_model.dart
  factory RoadmapModel.fromFirestoreData(Map<String, dynamic> data) {
    return RoadmapModel(
      id: null, // Berikan null karena ini adalah data sharing, bukan dari koleksi user asli
      title: data['title'] ?? '',
      time: data['time'] ?? '',
      description: data['description'] ?? '',
      steps: List<StepModel>.from(
        (data['steps'] ?? []).map((x) => StepModel.fromMap(x)),
      ),
    );
  }
}
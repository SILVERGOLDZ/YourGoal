import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ==========================================
// 1. MODEL DATA (Updated for Firebase)
// ==========================================

class StepModel {
  String title;
  String status;
  bool isCompleted;
  String description;
  List<String> subtasks;
  String message;

  StepModel({
    required this.title,
    required this.status,
    required this.isCompleted,
    required this.description,
    required this.subtasks,
    required this.message,
  });

  // Convert Object ke Map (Untuk simpan ke Firestore)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'status': status,
      'isCompleted': isCompleted,
      'description': description,
      'subtasks': subtasks,
      'message': message,
    };
  }

  // Convert Map ke Object (Untuk baca dari Firestore)
  factory StepModel.fromMap(Map<String, dynamic> map) {
    return StepModel(
      title: map['title'] ?? '',
      status: map['status'] ?? 'In Progress',
      isCompleted: map['isCompleted'] ?? false,
      description: map['description'] ?? '',
      subtasks: List<String>.from(map['subtasks'] ?? []),
      message: map['message'] ?? '',
    );
  }
}

class RoadmapModel {
  String? id; // ID Dokumen Firestore (Penting untuk Update/Delete)
  String title;
  String time;
  String status;
  String description;
  List<StepModel> steps;

  RoadmapModel({
    this.id,
    required this.title,
    required this.time,
    required this.status,
    required this.description,
    required this.steps,
  });

  // Hitung progress
  double get progress {
    if (steps.isEmpty) return 0.0;
    int completedCount = steps.where((s) => s.isCompleted).length;
    return completedCount / steps.length;
  }

  // Ke Map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'time': time,
      'status': status,
      'description': description,
      'steps': steps.map((x) => x.toMap()).toList(), // Convert list of objects to list of maps
      'createdAt': FieldValue.serverTimestamp(), // Untuk sorting
    };
  }

  // Dari Firestore Snapshot
  factory RoadmapModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return RoadmapModel(
      id: doc.id,
      title: data['title'] ?? '',
      time: data['time'] ?? '',
      status: data['status'] ?? 'In Progress',
      description: data['description'] ?? '',
      steps: List<StepModel>.from(
        (data['steps'] as List<dynamic>? ?? []).map((x) => StepModel.fromMap(x)),
      ),
    );
  }
}

// ==========================================
// 2. FIREBASE SERVICE (User Specific)
// ==========================================

class GoalDataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper: Mendapatkan User ID saat ini
  String? get _userId => _auth.currentUser?.uid;

  // Helper: Referensi ke Sub-Collection 'goals' milik user yang login
  CollectionReference? get _goalsCollection {
    if (_userId == null) return null;
    return _db.collection('users').doc(_userId).collection('goals');
  }

  // CREATE: Tambah Goal Baru
  Future<void> addRoadmap(RoadmapModel roadmap) async {
    if (_goalsCollection == null) return;
    await _goalsCollection!.add(roadmap.toMap());
  }

  // READ: Stream Data (Realtime Updates)
  Stream<List<RoadmapModel>> getRoadmapsStream() {
    if (_goalsCollection == null) return Stream.value([]);

    return _goalsCollection!
        .orderBy('createdAt', descending: true) // Urutkan dari yang terbaru
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => RoadmapModel.fromFirestore(doc)).toList();
    });
  }

  // UPDATE: Update Progress / Edit Goal
  Future<void> updateRoadmap(RoadmapModel roadmap) async {
    if (_goalsCollection == null || roadmap.id == null) return;
    await _goalsCollection!.doc(roadmap.id).update(roadmap.toMap());
  }

  // DELETE: Hapus Goal (Opsional)
  Future<void> deleteRoadmap(String id) async {
    if (_goalsCollection == null) return;
    await _goalsCollection!.doc(id).delete();
  }
}
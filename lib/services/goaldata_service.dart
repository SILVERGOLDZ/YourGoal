import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/goal_model.dart';
import '../models/journey_model.dart';
import 'notification_helper.dart';


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
    DocumentReference docRef = await _goalsCollection!.add(roadmap.toMap());
    _scheduleNotificationsForRoadmap(roadmap, docRef.id);
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

  // untuk mengambil isCompleted
  Stream<List<JourneyItem>> getCompletedJourneyStream() {
    if (_goalsCollection == null) return Stream.value([]);

    return _goalsCollection!
        .snapshots()
        .map((snapshot) {
      final List<JourneyItem> journeys = [];

      for (var doc in snapshot.docs) {
        final roadmap = RoadmapModel.fromFirestore(doc);

        for (var step in roadmap.steps) {
          if (step.isCompleted && step.completedAt != null) {
            journeys.add(
              JourneyItem(
                title: step.title,
                goalTitle: roadmap.title,
                time: step.completedAt!, // ← gunakan completedAt dari step
                comment: step.comment,
              ),
            );
          }
        }
      }

      // Sort by time, newest first
      journeys.sort((a, b) => b.time.compareTo(a.time));

      return journeys;
    });
  }
  void _scheduleNotificationsForRoadmap(RoadmapModel roadmap, String roadmapId) {
    for (int i = 0; i < roadmap.steps.length; i++) {
      StepModel step = roadmap.steps[i];

      // Buat ID unik untuk notifikasi berdasarkan hashcode string kombinasi
      // (Agar setiap step punya ID notifikasi yang unik dan konsisten)
      int notificationId = (roadmapId + i.toString()).hashCode;

      if (!step.isCompleted) {
        // Jadwalkan Notifikasi HANYA jika belum selesai
        NotificationHelper.scheduleNotification(
          id: notificationId,
          title: "Deadline Reminder: ${step.title}",
          body: "Goal '${roadmap.title}' is due soon!",
          scheduledDate: step.deadline,
        );

        // Opsi tambahan: Jadwalkan notifikasi "Peringatan H-1"
        NotificationHelper.scheduleNotification(
          id: notificationId + 99999, // ID beda
          title: "Tomorrow: ${step.title}",
          body: "Don't forget to complete your task!",
          scheduledDate: step.deadline.subtract(Duration(days: 1)),
        );

      } else {
        // Jika step sudah selesai, batalkan notifikasi yang mungkin sudah terpasang
        NotificationHelper.cancelNotification(notificationId);
        NotificationHelper.cancelNotification(notificationId + 99999);
      }
    }
  }
}


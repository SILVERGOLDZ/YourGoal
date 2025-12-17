import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/goal_model.dart';

class PostService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Stream<QuerySnapshot> getPostsStream() {
    return _db.collection('posts').orderBy('timestamp', descending: true).snapshots();
  }
  // 1. Ambil postingan khusus milik user tertentu (untuk Profile Page)
  Stream<QuerySnapshot> getUserPostsStream(String uid) {
    return _db
        .collection('posts')
        .where('userId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }


  // 2. Ambil daftar ID postingan yang di-bookmark user (untuk Collection Page)
  Stream<QuerySnapshot> getBookmarksStream() {
    final uid = currentUserId;
    if (uid == null) return const Stream.empty();

    // Ambil semua post dimana array 'savedBy' mengandung UID saya
    return _db
        .collection('posts')
        .where('savedBy', arrayContains: uid)
    // Note: orderBy timestamp mungkin butuh Composite Index baru jika digabung dengan where
        .snapshots();
  }
  // 3. Helper untuk mengambil data satu postingan berdasarkan ID (untuk item di Collection)
  Stream<DocumentSnapshot> getSinglePostStream(String postId) {
    return _db.collection('posts').doc(postId).snapshots();
  }

  Future<void> shareRoadmapAsPost(String text, RoadmapModel roadmap) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // 1. Ambil nama lengkap user untuk ditampilkan di postingan
    final userDoc = await _db.collection('users').doc(user.uid).get();
    String displayName = "User";

    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;
      displayName = '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim();
    }

    // 2. Simpan postingan dengan tambahan field 'sharedRoadmap'
    await _db.collection('posts').add({
      'userId': user.uid,
      'username': displayName,
      'text': text,
      'likedBy': [],
      'savedBy': [],
      'timestamp': FieldValue.serverTimestamp(),
      'sharedRoadmap': roadmap.toMap(), // Mengonversi model roadmap menjadi Map
    });
  }
  Future<void> addPost(String text) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userDoc = await _db.collection('users').doc(user.uid).get();

    String displayName = "Anonymous";

    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;
      final firstName = userData['firstName'] ?? '';
      final lastName = userData['lastName'] ?? '';

      // Gabungkan nama
      displayName = '$firstName $lastName'.trim();

      // Fallback jika nama ternyata kosong
      if (displayName.isEmpty) {
        displayName = user.email?.split('@')[0] ?? 'User';
      }
    }

    // 2. Simpan postingan dengan nama lengkap di field 'username'
    await _db.collection('posts').add({
      'userId': user.uid,
      'username': displayName, // Sekarang berisi Nama Lengkap
      'text': text,
      'likedBy': [],
      'savedBy': [], // Pastikan ini ada sesuai model baru Anda
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // --- LOGIKA LIKE ---
  Future<void> toggleLike(String postId, List<String> likedBy) async {
    final uid = currentUserId;
    if (uid == null) return;

    final docRef = _db.collection('posts').doc(postId);

    if (likedBy.contains(uid)) {
      // Jika sudah like, hapus ID user dari array (Unlike)
      await docRef.update({
        'likedBy': FieldValue.arrayRemove([uid])
      });
    } else {
      // Jika belum like, tambahkan ID user ke array (Like)
      await docRef.update({
        'likedBy': FieldValue.arrayUnion([uid])
      });
    }
  }

  // --- LOGIKA BOOKMARK SEDERHANA ---
  // Menyimpan bookmark ke sub-collection di dalam data user
// Toggle Bookmark -> LOGIKA BARU (SAMA DENGAN LIKE)
  Future<void> toggleBookmark(String postId, List<String> savedBy) async {
    final uid = currentUserId;
    if (uid == null) return;
    final docRef = _db.collection('posts').doc(postId);

    if (savedBy.contains(uid)) {
      // Jika sudah simpan -> Hapus (Unsave)
      await docRef.update({'savedBy': FieldValue.arrayRemove([uid])});
    } else {
      // Jika belum simpan -> Tambah (Save)
      await docRef.update({'savedBy': FieldValue.arrayUnion([uid])});
    }
  }
  Future<void> deletePost(String postId) async {
    try {
      await _db.collection('posts').doc(postId).delete();
    } catch (e) {
      print("Error deleting post: $e");
      rethrow;
    }
  }

}



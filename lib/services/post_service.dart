import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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


  Future<void> addPost(String text) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db.collection('posts').add({
      'userId': user.uid,
      'username': user.email?.split('@')[0] ?? 'Anonymous',
      'text': text,
      'likedBy': [], // Inisialisasi list kosong
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
}


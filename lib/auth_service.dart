import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // --- 1. REGISTER MANUAL (Dengan Verifikasi Email) ---
  Future<String?> registerWithEmailPassword(
      String email,
      String password,
      String firstName,
      String lastName,
      String? phone) async {
    try {
      // 1. Create Auth User
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // 2. Kirim Email Verifikasi
        await user.sendEmailVerification();

        // 3. Simpan ke Firestore dengan status isActive = false
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid, // IMPORTANT for Security Rules
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phone': phone ?? '',
          'authMethod': 'email',
          'isActive': false, // Belum aktif sampai email diklik
          'createdAt': FieldValue.serverTimestamp(), // Use Server Timestamp, not client time
          'createdAt': Timestamp.now(),
        });

        // BARIS signOut() DIHAPUS SESUAI INSTRUKSI
        // Dengan ini, user akan tetap login dan redirect-lah yang akan menangani
        // apakah user bisa masuk ke home atau harus ke halaman verifikasi.

        return null; // Sukses (return null artinya tidak ada error string)
      }
      return "User creation failed";
    } on FirebaseAuthException catch (e) {
      return e.message; // Return error message
    }
  }

  // --- 2. LOGIN GOOGLE (Dengan Logic Redirect ke Form) ---
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Inisialisasi _googleSignIn jika belum
      await _googleSignIn.initialize();
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();

      if (googleUser == null) return {'status': 'cancelled'};

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: null, // accessToken tidak diperlukan untuk idToken flow
        idToken: googleAuth.idToken,
      );

      // Sign in ke Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // CEK FIRESTORE: Apakah user ini sudah punya data lengkap?
        final userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          // Kasus A: User Lama -> Langsung Masuk
          return {'status': 'success', 'user': user};
        } else {
          // Kasus B: User Baru (Database belum ada)
          String firstName = googleUser.displayName?.split(' ').first ?? '';
          String lastName = '';
          if ((googleUser.displayName?.split(' ').length ?? 0) > 1) {
            lastName = googleUser.displayName!.substring(firstName.length).trim();
          }

          return {
            'status': 'needs_registration',
            'email': user.email,
            'firstName': firstName,
            'lastName': lastName,
            'uid': user.uid,
          };
        }
      }
      return {'status': 'error', 'message': 'Authentication failed'};
    } catch (e) {
      debugPrint(e.toString());
      return {'status': 'error', 'message': e.toString()};
    }
  }

  // --- 3. FINALIZE GOOGLE REGISTRATION ---
  Future<void> completeGoogleRegistration({
    required String uid,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) async {
    // Using SetOptions(merge: true) is safer to avoid destroying data if it exists
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
    await _firestore.collection('users').doc(uid).set({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'authMethod': 'google',
      'isActive': true, // Google dianggap auto-verified
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
      'createdAt': Timestamp.now(),
    });
  }

  // --- 4. SIGN OUT ---
  Future<void> signOut() async {
    await _googleSignIn.disconnect().catchError((e) => debugPrint("Google disconnect error: $e"));
    await _auth.signOut();
  }

  // --- Metode yang sudah ada sebelumnya ---
  Future<UserCredential?> signInWithEmailPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message);
      return null;
    }
  }

  Future<bool> updateUserData(Map<String, dynamic> data) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update(data);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error updating user data: $e");
      return false;
    }
  }

  Future<bool> deleteUserAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Hapus dari Firestore dulu
        await _firestore.collection('users').doc(user.uid).delete();
        // Kemudian hapus dari Firebase Auth
        await user.delete();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      debugPrint("Error deleting account: ${e.code}");
      // Re-authentication might be required
      return false;
    } catch (e) {
      debugPrint("General error deleting account: $e");
      return false;
    }
  }
}

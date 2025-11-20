import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // --- REGISTER MANUAL (Dengan Verifikasi Email) ---
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

        // 3. Simpan ke Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phone': phone ?? '',
          'authMethod': 'email', // Hardcode ke email
          'isActive': false, // Belum aktif sampai email diklik
          'createdAt': FieldValue.serverTimestamp(),
        });

        return null; // Sukses
      }
      return "User creation failed";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // --- LOGIN MANUAL ---
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

  // --- UPDATE DATA ---
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

  // --- DELETE ACCOUNT ---
  Future<bool> deleteUserAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).delete();
        await user.delete();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      debugPrint("Error deleting account: ${e.code}");
      return false;
    } catch (e) {
      debugPrint("General error deleting account: $e");
      return false;
    }
  }

  // --- SIGN OUT ---
  Future<void> signOut() async {
    // Cukup sign out dari Firebase saja
    await _auth.signOut();
  }

  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Null artinya sukses (tidak ada error)
    } on FirebaseAuthException catch (e) {
      return e.message; // Kembalikan pesan error jika gagal
    }
  }
}
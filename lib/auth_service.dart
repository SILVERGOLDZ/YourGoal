import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<void> _ensureGoogleSignInInitialized() async {
    await _googleSignIn.initialize();
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // --- LOGIN & REGISTER (Existing) ---

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

  Future<UserCredential?> registerWithEmailPassword(
      String email,
      String password,
      String firstName,
      String lastName,
      String? phone) async {
    try {
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phone': phone ?? '',
          'createdAt': Timestamp.now(),
        });
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message);
      return null;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      await _ensureGoogleSignInInitialized();
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: null,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      User? user = userCredential.user;

      if (user != null && userCredential.additionalUserInfo?.isNewUser == true) {
        String? firstName = googleUser.displayName?.split(' ').first;
        String? lastName = googleUser.displayName?.contains(' ') == true
            ? googleUser.displayName?.substring(googleUser.displayName!.indexOf(' ') + 1)
            : '';

        await _firestore.collection('users').doc(user.uid).set({
          'firstName': firstName ?? '',
          'lastName': lastName ?? '',
          'email': user.email ?? '',
          'phone': user.phoneNumber ?? '',
          'createdAt': Timestamp.now(),
        });
      }

      return userCredential;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.disconnect();
    await _auth.signOut();
  }

  // --- NEW CRUD METHODS ---

  // UPDATE: Update specific fields in Firestore
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

  // DELETE: Delete Firestore Data AND Auth Account
  Future<bool> deleteUserAccount(String passwordForReauth) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // 1. Delete Firestore Data
        await _firestore.collection('users').doc(user.uid).delete();

        // 2. Delete Auth Account
        // Note: This requires 'recent login'. If it fails, you might need to re-authenticate the user first.
        await user.delete();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      debugPrint("Error deleting account: ${e.code}");
      // Handle 'requires-recent-login' error specifically in UI if needed
      return false;
    } catch (e) {
      debugPrint("General error deleting account: $e");
      return false;
    }
  }
}
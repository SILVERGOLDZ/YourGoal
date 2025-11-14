import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // The GoogleSignIn instance is now a singleton
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // It's recommended to initialize GoogleSignIn early, for example, in main()
  // or in a loading screen. For simplicity, we'll ensure it's initialized here.
  Future<void> _ensureGoogleSignInInitialized() async {
    // The initialize method can be called multiple times, it will only run once.
    await _googleSignIn.initialize();
  }

  // Stream for auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with Email & Password
  Future<UserCredential?> signInWithEmailPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Handle errors
      debugPrint(e.message);
      return null;
    }
  }

  // Register with Email & Password
  Future<UserCredential?> registerWithEmailPassword(
      String email,
      String password,
      String firstName,
      String lastName,
      String? phone) async {
    try {
      // 1. Create user in Firebase Auth
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // 2. Save additional user data to Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phone': phone ?? '', // Store empty string if null
          'createdAt': Timestamp.now(),
        });
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Handle errors
      debugPrint(e.message);
      return null;
    }
  }

  // Sign in with Google (Updated for google_sign_in ^7.x)
  Future<UserCredential?> signInWithGoogle() async {
    try {
      await _ensureGoogleSignInInitialized();
      // 1. Trigger the Google Authentication flow
      // authenticate() replaces the deprecated signIn()
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) {
        // The user canceled the sign-in
        return null;
      }

      // 2. Obtain the auth details from the request
      // The `authentication` getter is now synchronous
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // 3. Create a new credential for Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        // accessToken is no longer directly available on GoogleSignInAuthentication
        // and is often not needed for Firebase sign-in with an ID token.
        // If you need it for other Google APIs, you must request scopes separately.
        accessToken: null, // Pass null if not explicitly needed/retrieved.
        idToken: googleAuth.idToken,
      );

      // 4. Sign in to Firebase with the credential
      final UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      User? user = userCredential.user;

      // 5. Check if this is a new user to save data to Firestore
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
      // Handle errors
      debugPrint(e.toString());
      return null;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    // It's good practice to also disconnect from Google Sign-In to allow
    // the user to choose a different account next time.
    await _googleSignIn.disconnect();
    await _auth.signOut();
  }

  // Helper to show a SnackBar
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

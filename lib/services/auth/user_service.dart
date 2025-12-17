import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tes/models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _usersCollection = FirebaseFirestore.instance.collection('users');

  Future<void> createUser(User user, String firstName, String lastName, String? phone) async {
    final userModel = UserModel(
      uid: user.uid,
      firstName: firstName,
      lastName: lastName,
      email: user.email!,
      phone: phone ?? '',
      // Default profile image URL
      profileImageUrl: 'https://firebasestorage.googleapis.com/v0/b/your-goal-d5267.appspot.com/o/profileImages%2Fdefault_profile.png?alt=media&token=e1a5b855-6e35-4294-9e32-37c76d82c4a4',
    );
    await _usersCollection.doc(user.uid).set(userModel.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
    } catch (e) {
      print("Error getting user data: $e");
    }
    return null;
  }

  Future<bool> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _usersCollection.doc(uid).update(data);
      return true;
    } catch (e) {
      print("Error updating user data: $e");
      return false;
    }
  }

  Future<void> deleteUserData(String uid) async {
    await _usersCollection.doc(uid).delete();
  }

  Future<List<UserModel>> searchUsers(String query) async {
    if (query.isEmpty) {
      return [];
    }

    final firstNameQuery = _usersCollection
        .where('firstName', isGreaterThanOrEqualTo: query)
        .where('firstName', isLessThan: query + '\uf8ff')
        .get();

    final lastNameQuery = _usersCollection
        .where('lastName', isGreaterThanOrEqualTo: query)
        .where('lastName', isLessThan: query + '\uf8ff')
        .get();

    final emailQuery = _usersCollection
        .where('email', isGreaterThanOrEqualTo: query)
        .where('email', isLessThan: query + '\uf8ff')
        .get();

    try {
      final results = await Future.wait([firstNameQuery, lastNameQuery, emailQuery]);

      // FIX: Use a Map keyed by UID to prevent duplicates
      final Map<String, UserModel> uniqueUsers = {};

      for (var result in results) {
        for (var doc in result.docs) {
          final user = UserModel.fromFirestore(doc);
          // This will overwrite the entry if it already exists, ensuring uniqueness
          uniqueUsers[user.uid] = user;
        }
      }

      return uniqueUsers.values.toList();
    } catch (e) {
      print("Error searching users: $e");
      return [];
    }
  }
}

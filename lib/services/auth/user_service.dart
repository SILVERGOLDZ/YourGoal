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
}

import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String userId;
  final String username;
  final String text;
  final List<String> likedBy;
  final List<String> savedBy;
  final Timestamp timestamp;

  PostModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.text,
    required this.likedBy,
    required this.savedBy,
    required this.timestamp,
  });

  int get likeCount => likedBy.length;

  factory PostModel.fromMap(String id, Map<String, dynamic> map) {
    return PostModel(
      id: id,
      userId: map['userId'] ?? '',
      username: map['username'] ?? 'User',
      text: map['text'] ?? '',
      likedBy: List<String>.from(map['likedBy'] ?? []),
      savedBy: List<String>.from(map['savedBy'] ?? []),
      timestamp: map['timestamp'] ?? Timestamp.now(),
    );
  }
}
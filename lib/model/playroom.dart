import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:word_wolf/model/user.dart';

class Playroom {
  Playroom({
    required this.id,
    required this.adminUserId,
    required this.users,
    required this.createdAt,
  });

  String id;
  String adminUserId;
  List<User> users;
  final Timestamp createdAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'admin': adminUserId,
      'users': users.map((user) => user.toMap()).toList(),
      'createdAt': createdAt,
    };
  }
}

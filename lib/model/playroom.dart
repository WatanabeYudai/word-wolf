import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:word_wolf/model/topic.dart';
import 'package:word_wolf/model/user.dart';

class Playroom {
  Playroom({
    required this.id,
    required this.adminUserId,
    required this.users,
    required this.wolfCount,
    required this.timeLimitMinutes,
    required this.topic,
    required this.createdAt,
  });

  String id;
  String adminUserId;
  List<User> users;
  int wolfCount;
  int timeLimitMinutes;
  Topic topic;
  final Timestamp createdAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'adminUserId': adminUserId,
      'users': users.map((user) => user.toMap()).toList(),
      'wolfCount': wolfCount,
      'timeLimitMinutes': timeLimitMinutes,
      'topic': topic.name(),
      'createdAt': createdAt,
    };
  }
}
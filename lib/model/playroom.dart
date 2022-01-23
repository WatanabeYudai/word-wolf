import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:word_wolf/model/playroom_status.dart';
import 'package:word_wolf/model/topic.dart';
import 'package:word_wolf/model/player.dart';

class Playroom {
  Playroom({
    required this.id,
    required this.adminPlayerId,
    required this.players,
    required this.wolfCount,
    required this.timeLimitMinutes,
    required this.topic,
    required this.status,
    required this.createdAt,
  });

  String id;
  String adminPlayerId;
  List<Player> players;
  int wolfCount;
  int timeLimitMinutes;
  Topic topic;
  PlayroomStatus status;
  final Timestamp createdAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'adminUserId': adminPlayerId,
      'players': Player.transform(players),
      'wolfCount': wolfCount,
      'timeLimitMinutes': timeLimitMinutes,
      'topic': topic.name(),
      'status': status.name,
      'createdAt': createdAt,
    };
  }
}
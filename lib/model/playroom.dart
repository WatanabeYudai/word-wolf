import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:word_wolf/common/c.dart';
import 'package:word_wolf/model/game_status.dart';
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
    required this.gameStatus,
    required this.createdAt,
  });

  String id;
  String adminPlayerId;
  List<Player> players;
  int wolfCount;
  int timeLimitMinutes;
  Topic topic;
  GameStatus gameStatus;
  final Timestamp createdAt;

  Map<String, dynamic> toMap() {
    return {
      C.playroom.id: id,
      C.playroom.adminPlayerId: adminPlayerId,
      C.playroom.players: Player.transform(players),
      C.playroom.wolfCount: wolfCount,
      C.playroom.timeLimitMinutes: timeLimitMinutes,
      C.playroom.topic: topic.name(),
      C.playroom.gameStatus: gameStatus.name,
      C.playroom.createdAt: createdAt,
    };
  }
}

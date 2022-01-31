import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:word_wolf/common/c.dart';
import 'package:word_wolf/model/game_status.dart';
import 'package:word_wolf/model/topic.dart';
import 'package:word_wolf/model/player.dart';
import 'package:word_wolf/repository/playroom_repository.dart';

class Playroom {
  Playroom({
    required this.id,
    required this.adminPlayerId,
    required this.players,
    required this.wolfCount,
    required this.timeLimitMinutes,
    required this.topic,
    required this.gameState,
    required this.createdAt,
  });

  String id;
  String adminPlayerId;
  List<Player> players;
  int wolfCount;
  int timeLimitMinutes;
  Topic topic;
  GameState gameState;
  final Timestamp createdAt;

  late final _repository = PlayroomRepository(playroomId: id);

  Map<String, dynamic> toMap() {
    return {
      C.playroom.id: id,
      C.playroom.adminPlayerId: adminPlayerId,
      C.playroom.players: Player.transform(players),
      C.playroom.wolfCount: wolfCount,
      C.playroom.timeLimitMinutes: timeLimitMinutes,
      C.playroom.topic: topic.name(),
      C.playroom.gameStatus: gameState.name,
      C.playroom.createdAt: createdAt,
    };
  }

  static Future<bool> exists(String id) => PlayroomRepository.exists(id);

  static Future<String?> create(Player admin) => PlayroomRepository.create(admin);

  static Future<Playroom?> find(String id) => PlayroomRepository.find(id);

  static Stream<Playroom> getStream(String id) => PlayroomRepository.stream(id);

  Future<void> addPlayer(Player player) => _repository.addPlayer(player);

  Future<void> removePlayer(String playerId) => _repository.removePlayer(playerId);

}

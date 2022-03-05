import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:word_wolf/common/c.dart';
import 'package:word_wolf/model/game_settings.dart';
import 'package:word_wolf/model/game_state.dart';
import 'package:word_wolf/model/player.dart';
import 'package:word_wolf/repository/playroom_repository.dart';

class Playroom {
  Playroom({
    required this.id,
    required this.adminPlayerId,
    required this.gameSettings,
    required this.gameState,
    required this.createdAt,
  });

  String id;
  String adminPlayerId;
  GameSettings gameSettings;
  GameState gameState;
  bool isClosed = false;
  final Timestamp createdAt;

  late final _repository = PlayroomRepository(playroomId: id);

  Map<String, dynamic> toMap() {
    return {
      C.playroom.id: id,
      C.playroom.adminPlayerId: adminPlayerId,
      C.playroom.gameSettings: gameSettings.toMap(),
      C.playroom.gameState: gameState.name,
      C.playroom.isClosed: isClosed,
      C.playroom.createdAt: createdAt,
    };
  }

  static Future<bool> exists(String id) => PlayroomRepository.exists(id);

  static Future<String?> create(Player admin) => PlayroomRepository.create(admin);

  static Future<Playroom?> find(String id) => PlayroomRepository.findPlayroom(id);

  static Stream<Playroom> getPlayroomStream(String id) => PlayroomRepository.playroomStream(id);

  static Stream<List<Player>> getPlayersStream(String id) => PlayroomRepository.playersStream(id);

  Future<String?> enter(Player player) => _repository.enter(player);

  Future<void> leave(String playerId) => _repository.leave(playerId);

  Future<Player?> findPlayer(String playerId) => _repository.findPlayer(playerId);

  Future<void> updateSetting(GameSettings setting) => _repository.updateSetting(setting);

  bool nowPlaying() => gameState != GameState.standby;
}

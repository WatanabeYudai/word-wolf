import 'package:word_wolf/common/c.dart';

class Player {
  Player({
    required this.id,
    required this.name,
    required this.isWolf,
    required this.isActive,
  });

  final String id;
  final String name;
  final bool isWolf;
  final bool isActive;

  Map<String, dynamic> toMap() {
    return {
      C.player.id: id,
      C.player.name: name,
      C.player.isWolf: isWolf,
      C.player.isActive: isActive,
    };
  }

  static Map<String, dynamic> transform(List<Player> players) {
    Map<String, dynamic> playersMap = {};
    for (var player in players) {
      playersMap[player.id] = {
        C.player.id: player.id,
        C.player.name: player.name,
        C.player.isWolf: player.isWolf,
        C.player.isActive:player.isActive,
      };
    }
    return playersMap;
  }
}

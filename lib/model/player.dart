

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
      'id': id,
      'name': name,
      'isWolf': isWolf,
      'isActive': isActive,
    };
  }

  static Map<String, dynamic> transform(List<Player> players) {
    Map<String, dynamic> playersMap = {};
    for (var player in players) {
      playersMap[player.id] = {
        'id': player.id,
        'name': player.name,
        'isWolf': player.isWolf,
        'isActive':player.isActive,
      };
    }
    return playersMap;
  }
}

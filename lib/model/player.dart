

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

  static Map<String, dynamic> toMap(List<Player> players) {
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

class C {
  static var playroom = const PlayroomColumn();
  static var player = const PlayerColumn();
}

class PlayroomColumn {
  const PlayroomColumn();
  String get id => 'id';
  String get adminPlayerId => 'adminPlayerId';
  String get players => 'players';
  String get wolfCount => 'wolfCount';
  String get timeLimitMinutes => 'timeLimitMinutes';
  String get topic => 'topic';
  String get gameStatus => 'gameStatus';
  String get createdAt => 'createdAt';
}

class PlayerColumn {
  const PlayerColumn();
  String get id => 'id';
  String get name => 'name';
  String get isWolf => 'isWolf';
  String get isActive => 'isActive';
}

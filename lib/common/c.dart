class C {
  static const playroom = PlayroomColumn();
  static const player = PlayerColumn();
  static const user = UserColumn();
}

class PlayroomColumn {
  const PlayroomColumn();
  String get id => 'id';
  String get adminPlayerId => 'adminPlayerId';
  String get players => 'players';
  String get wolfCount => 'wolfCount';
  String get timeLimitMinutes => 'timeLimitMinutes';
  String get topic => 'topic';
  String get gameState => 'gameState';
  String get isClosed => 'isClosed';
  String get createdAt => 'createdAt';
}

class PlayerColumn {
  const PlayerColumn();
  String get id => 'id';
  String get name => 'name';
  String get isWolf => 'isWolf';
  String get isActive => 'isActive';
}

class UserColumn {
  const UserColumn();
  String get id => 'id';
  String get state => 'state';
  String get currentPlayroom => 'currentPlayroom';
  String get lastChanged => 'lastChanged';
}

enum GameStatus {
  standby,
  playing,
  voting,
  ended,
}

class GameStatusHelper {
  static GameStatus fromName(String name) {
    if (name == 'standby') {
      return GameStatus.standby;
    }
    if (name == 'playing') {
      return GameStatus.playing;
    }
    if (name == 'voting') {
      return GameStatus.voting;
    }
    if (name == 'ended') {
      return GameStatus.ended;
    }
    return GameStatus.standby;
  }
}

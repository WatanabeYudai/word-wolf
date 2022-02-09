enum GameState {
  standby,
  playing,
  voting,
  ended,
}

class GameStateHelper {
  static GameState fromName(String name) {
    if (name == 'standby') {
      return GameState.standby;
    }
    if (name == 'playing') {
      return GameState.playing;
    }
    if (name == 'voting') {
      return GameState.voting;
    }
    if (name == 'ended') {
      return GameState.ended;
    }
    throw ArgumentError();
  }
}

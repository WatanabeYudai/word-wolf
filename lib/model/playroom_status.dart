enum PlayroomStatus {
  standby,
  playing,
  voting,
  ended,
}

class PlayroomStatusHelper {
  static PlayroomStatus fromName(String name) {
    if (name == 'standby') {
      return PlayroomStatus.standby;
    }
    if (name == 'playing') {
      return PlayroomStatus.playing;
    }
    if (name == 'voting') {
      return PlayroomStatus.voting;
    }
    if (name == 'ended') {
      return PlayroomStatus.ended;
    }
    return PlayroomStatus.standby;
  }
}

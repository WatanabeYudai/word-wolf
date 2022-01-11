import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:word_wolf/model/topic.dart';

final gameSettingProvider =
StateNotifierProvider.autoDispose<GameSetting, GameSettingState>((ref) {
  return GameSetting(
    const GameSettingState(
      humanCount: 3,
      wolfCount: 1,
      timeLimitMinute: 10,
      topic: Topic.all,
    ),
  );
});

class GameSetting extends StateNotifier<GameSettingState> {
  GameSetting(GameSettingState state) : super(state);

  void incrementHumanCount() {
    state = state.copy(humanCount: state.humanCount + 1);
  }

  void decrementHumanCount() {
    int newHumanCount = state.humanCount - 1;
    int newWolfCount = newHumanCount % 2 == 0
        ? (newHumanCount ~/ 2) - 1
        : (newHumanCount / 2).floor();
    state = state.copy(
      humanCount: state.humanCount - 1,
      wolfCount: newWolfCount,
    );
  }

  void incrementWolfCount() {
    state = state.copy(wolfCount: state.wolfCount + 1);
  }

  void decrementWolfCount() {
    state = state.copy(wolfCount: state.wolfCount - 1);
  }

  void incrementTimeLimit() {
    state = state.copy(timeLimitMinute: state.timeLimitMinute + 1);
  }

  void decrementTimeLimit() {
    state = state.copy(timeLimitMinute: state.timeLimitMinute - 1);
  }

  void nextTopic() {
    state = state.copy(topic: state.topic.next());
  }

  void prevTopic() {
    state = state.copy(topic: state.topic.prev());
  }
}

class GameSettingState {
  const GameSettingState({
    required this.humanCount,
    required this.wolfCount,
    required this.timeLimitMinute,
    required this.topic,
  });

  final int humanCount;
  final int wolfCount;
  final int timeLimitMinute;
  final Topic topic;

  GameSettingState copy({
    int? humanCount,
    int? wolfCount,
    int? timeLimitMinute,
    Topic? topic,
  }) {
    return GameSettingState(
      humanCount: humanCount ?? this.humanCount,
      wolfCount: wolfCount ?? this.wolfCount,
      timeLimitMinute: timeLimitMinute ?? this.timeLimitMinute,
      topic: topic ?? this.topic,
    );
  }
}
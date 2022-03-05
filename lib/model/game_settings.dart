import 'package:word_wolf/common/c.dart';
import 'package:word_wolf/model/topic.dart';

class GameSettings {
  const GameSettings({
    required this.wolfCount,
    required this.timeLimitMinutes,
    required this.topic,
  });

  final int wolfCount;
  final int timeLimitMinutes;
  final Topic topic;

  Map<String, dynamic> toMap() {
    return {
      C.playroom.wolfCount: wolfCount,
      C.playroom.timeLimitMinutes: timeLimitMinutes,
      C.playroom.topic: topic.name,
    };
  }
}
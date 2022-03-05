enum Topic {
  all,
  food,
  sports,
}

extension TopicExt on Topic {
  String displayName() {
    switch (this) {
      case Topic.all:
        return 'ランダム';
      case Topic.food:
        return '食べもの';
      case Topic.sports:
        return 'スポーツ';
      default:
        return 'ランダム';
    }
  }
}

class TopicHelper {
  static List<String> displayNameList() {
    return [
      Topic.all.displayName(),
      Topic.food.displayName(),
      Topic.sports.displayName(),
    ];
  }

  static Topic fromName(String name) {
    if (name == Topic.all.name) {
      return Topic.all;
    }
    if (name == Topic.food.name) {
      return Topic.food;
    }
    if (name == Topic.sports.name) {
      return Topic.sports;
    }
    return Topic.all;
  }

  static Topic fromDisplayName(String name) {
    if (name == Topic.all.displayName()) {
      return Topic.all;
    }
    if (name == Topic.food.displayName()) {
      return Topic.food;
    }
    if (name == Topic.sports.displayName()) {
      return Topic.sports;
    }
    return Topic.all;
  }
}

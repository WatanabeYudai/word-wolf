enum Topic {
  all,
  food,
  sports,
}

extension TopicExt on Topic {
  int id() {
    switch (this) {
      case Topic.all:
        return 0;
      case Topic.food:
        return 1;
      case Topic.sports:
        return 2;
      default:
        return 0;
    }
  }

  Topic fromId(int id) {
    if (id == Topic.all.id()) {
      return Topic.all;
    }
    if (id == Topic.food.id()) {
      return Topic.food;
    }
    if (id == Topic.sports.id()) {
      return Topic.sports;
    }
    return Topic.all;
  }

  static Topic fromName(String name) {
    if (name == Topic.all.name()) {
      return Topic.all;
    }
    if (name == Topic.food.name()) {
      return Topic.food;
    }
    if (name == Topic.sports.name()) {
      return Topic.sports;
    }
    return Topic.all;
  }

  Topic next() {
    if (id() == Topic.values.length - 1) {
      return this;
    }
    return fromId(id() + 1);
  }

  Topic prev() {
    if (id() == 0) {
      return this;
    }
    return fromId(id() - 1);
  }

  String name() {
    switch (this) {
      case Topic.all:
        return 'all';
      case Topic.food:
        return 'food';
      case Topic.sports:
        return 'sports';
      default:
        return 'all';
    }
  }

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
  static Topic fromName(String name) {
    if (name == Topic.all.name()) {
      return Topic.all;
    }
    if (name == Topic.food.name()) {
      return Topic.food;
    }
    if (name == Topic.sports.name()) {
      return Topic.sports;
    }
    return Topic.all;
  }
}

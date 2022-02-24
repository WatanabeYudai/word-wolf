import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:word_wolf/repository/user_repository.dart';

class User {
  User({
    required this.id,
    required this.state,
    required this.currentPlayroom,
    required this.lastChanged,
  });

  final String id;
  final UserState state;
  String currentPlayroom;
  final Timestamp lastChanged;

  late final _repository = UserRepository(userId: id);

  static Future<User> find(String userId) => UserRepository.find(userId);

  Future<void> setCurrentPlayroom(String playroomId) => _repository.setCurrentPlayroom(playroomId);

  Future<void> clearCurrentPlayroom() => _repository.clearCurrentPlayroom();
}

enum UserState {
  online,
  offline,
}

class UserStateUtil {
  static toUserState(String name) {
    if (name == 'online') {
      return UserState.online;
    }
    if (name == 'offline') {
      return UserState.offline;
    }
    throw ArgumentError();
  }
}
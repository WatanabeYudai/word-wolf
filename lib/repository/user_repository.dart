import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:word_wolf/common/c.dart';
import 'package:word_wolf/model/user.dart';

class UserRepository {
  UserRepository({
    required this.userId,
});

  final String userId;

  late var userRef = FirebaseFirestore.instance.collection('users').doc(userId);

  static Future<User> find(String userId) async {
    final snapshot = await _getUserRef(userId).get();
    return _snapshotToUser(snapshot);
  }

  Future<void> clearCurrentPlayroom() {
    return userRef.update({
      C.user.currentPlayroom: '',
      C.user.lastChanged: Timestamp.now(),
    });
  }

  Future<void> setCurrentPlayroom(String playroomId) {
    return userRef.update({
      C.user.currentPlayroom: playroomId,
      C.user.lastChanged: Timestamp.now(),
    });
  }

  static User _snapshotToUser(DocumentSnapshot snapshot) {
    try {
      final stateName = snapshot.get(C.user.state);
      final state = UserStateUtil.toUserState(stateName);
      return User(
        id: snapshot.get(C.user.id),
        state: state,
        currentPlayroom: snapshot.get(C.user.currentPlayroom),
        lastChanged: snapshot.get(C.user.lastChanged),
      );
    } catch(e) {
      // TODO: エラー処理
      throw Exception(e);
    }
  }

  static DocumentReference _getUserRef(String userId) {
    return FirebaseFirestore.instance.collection('users').doc(userId);
  }
}

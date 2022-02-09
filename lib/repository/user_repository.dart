import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:word_wolf/common/c.dart';

class UserRepository {
  UserRepository({
    required this.userId,
});

  final String userId;

  late var documentRef = FirebaseFirestore.instance.collection('users').doc(userId);

  Future<void> clearCurrentPlayroom() {
    return documentRef.update({
      C.user.currentPlayroom: '',
      C.user.lastChanged: Timestamp.now(),
    });
  }

  Future<void> updateCurrentPlayroom(String playroomId) {
    return documentRef.update({
      C.user.currentPlayroom: playroomId,
      C.user.lastChanged: Timestamp.now(),
    });
  }
}

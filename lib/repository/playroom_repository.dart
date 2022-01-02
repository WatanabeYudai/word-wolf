import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:word_wolf/model/playroom.dart';
import 'package:word_wolf/model/user.dart';

class PlayroomRepository {

  late CollectionReference collectionRef = FirebaseFirestore.instance.collection('playrooms');

  Future<void> createPlayroom(User adminUser) async {
    final String playroomId = _generateRandomString(6);
    DocumentReference docRef = collectionRef.doc(playroomId);
    await docRef.get().then((value) {
      // 同じ ID の部屋が存在したらエラーを返す。
      if (value.exists) {
        return;
      }
      Playroom room = Playroom(
        id: playroomId,
        adminUserId: adminUser.id,
        users: [adminUser],
        createdAt: Timestamp.now(),
      );
      docRef.set(room.toMap());
    });
  }

  Future<void> addUser(String playroomId) async {
    collectionRef.doc(playroomId).get().then((value) {
      if (!value.exists) {
        return;
      }
    });
  }

  String _generateRandomString(int length) {
    const _randomChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    const _charsLength = _randomChars.length;

    final rand = Random();
    final codeUnits = List.generate(
      length,
      (index) {
        final n = rand.nextInt(_charsLength);
        return _randomChars.codeUnitAt(n);
      },
    );
    return String.fromCharCodes(codeUnits);
  }
}

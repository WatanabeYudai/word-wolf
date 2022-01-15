import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:word_wolf/model/playroom.dart';
import 'package:word_wolf/model/topic.dart';
import 'package:word_wolf/model/user.dart';

class PlayroomRepository {
  CollectionReference collectionRef =
      FirebaseFirestore.instance.collection('playrooms');

  Future<String?> createPlayroom(User adminUser) async {
    final String playroomId = _generateRandomString(6);
    DocumentReference docRef = collectionRef.doc(playroomId);
    return docRef.get().then((value) {
      // 同じ ID の部屋が存在したらエラーを返す。
      if (value.exists) {
        return null;
      }
      Playroom room = Playroom(
        id: playroomId,
        adminUserId: adminUser.id,
        users: [adminUser],
        wolfCount: 1,
        timeLimitMinutes: 5,
        topic: Topic.sports,
        createdAt: Timestamp.now(),
      );
      // TODO: 保存できなかったときの処理を検討
      docRef.set(room.toMap());
      return playroomId;
    });
  }

  Future<void> addUser(String playroomId) async {
    collectionRef.doc(playroomId).get().then((value) {
      if (!value.exists) {
        return;
      }
    });
  }

  Stream<Playroom> getPlayroom(String id) {
    return collectionRef.doc(id).snapshots().transform(
        StreamTransformer<DocumentSnapshot<Map<String, dynamic>>, Playroom>
            .fromHandlers(handleData: (snapshot, sink) {
      if (snapshot.exists) {
        var anyList = snapshot.get('users') as List<dynamic>;
        var mapList = anyList.map((e) => e as Map<String, dynamic>).toList();
        var users = mapList.map((e) => User(
          id: e['id'],
          name: e['name'],
          isWolf: e['isWolf'],
        )).toList();
        var topic = TopicHelper.fromName(snapshot.get('topic'));
        var room = Playroom(
          id: snapshot.get('id'),
          adminUserId: snapshot.get('adminUserId'),
          users: users,
          wolfCount: snapshot.get('wolfCount'),
          timeLimitMinutes: snapshot.get('timeLimitMinutes'),
          topic: topic,
          createdAt: snapshot.get('createdAt'),
        );
        sink.add(room);
      }
    }));
  }

  Future<bool> exists(String roomId) async {
    return collectionRef.doc(roomId).get().then((room) {
      return room.exists;
    });
  }

  String _generateRandomString(int length) {
    const _randomChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    const _charsLength = _randomChars.length;

    final rand = Random();
    final codeUnits = List.generate(length, (index) {
      final n = rand.nextInt(_charsLength);
      return _randomChars.codeUnitAt(n);
    });
    return String.fromCharCodes(codeUnits);
  }
}

import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:word_wolf/model/player.dart';
import 'package:word_wolf/model/playroom.dart';
import 'package:word_wolf/model/topic.dart';

class PlayroomRepository {
  PlayroomRepository({
    required this.playroomId,
  });

  final String playroomId;

  final collectionRef = FirebaseFirestore.instance.collection('playrooms');

  static Future<String?> createPlayroom(Player admin) {
    final String playroomId = _generateRandomString(6);
    DocumentReference docRef =
        FirebaseFirestore.instance.collection('playrooms').doc(playroomId);
    return docRef.get().then((value) {
      // 同じ ID の部屋が存在したらエラーを返す。
      if (value.exists) {
        return null;
      }
      Playroom room = Playroom(
        id: playroomId,
        adminPlayerId: admin.id,
        players: [admin],
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

  Future<void> addUser(User user) {
    return collectionRef.doc(playroomId).update({
      'users': FieldValue.arrayUnion([user.toMap()]),
    });
  }

  void setIsActive(String playerId, bool isActive) async {
    var target = await findPlayer(playerId);
    if (target == null) {
      return;
    }

    collectionRef.doc(playroomId).update({
      'players.${target.id}.isActive': isActive,
    });
  }

  Future<Player?> findPlayer(String playerId) {
    return collectionRef.doc(playroomId).get().then((snapshot) {
      var players = _snapshotToPlayerList(snapshot);
      return players.firstWhereOrNull((player) => player.id == playerId);
    });
  }

  Stream<Playroom> getPlayroom() {
    return collectionRef
        .doc(playroomId)
        .snapshots()
        .transform(StreamTransformer<DocumentSnapshot<Map<String, dynamic>>, Playroom>
            .fromHandlers(handleData: (snapshot, sink) {
      if (snapshot.exists) {
        var players = _snapshotToPlayerList(snapshot);
        var topic = TopicHelper.fromName(snapshot.get('topic'));
        var room = Playroom(
          id: snapshot.get('id'),
          adminPlayerId: snapshot.get('adminUserId'),
          players: players,
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
    return collectionRef.doc(roomId).get().then((snapshot) {
      return snapshot.exists;
    });
  }

  List<Player> _snapshotToPlayerList(DocumentSnapshot snapshot) {
    try {
      var playerMap = snapshot.get('players') as Map<String, dynamic>;
      var playerList = playerMap.values.toList();
      return playerList
          .map((e) => Player(
                id: e['id'],
                name: e['name'],
                isWolf: e['isWolf'],
                isActive: e['isActive'],
              ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static String _generateRandomString(int length) {
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

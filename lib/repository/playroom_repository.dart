import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:word_wolf/common/c.dart';
import 'package:word_wolf/model/game_status.dart';
import 'package:word_wolf/model/player.dart';
import 'package:word_wolf/model/playroom.dart';
import 'package:word_wolf/model/topic.dart';
import 'package:word_wolf/util/constants.dart';

class PlayroomRepository {
  PlayroomRepository({
    required this.playroomId,
  });

  final String playroomId;

  late var documentRef = FirebaseFirestore.instance.collection('playrooms').doc(playroomId);

  final db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: Constants.databaseUrl,
  );

  static Future<String?> create(Player admin) {
    final playroomId = _generateRandomString(6);
    DocumentReference docRef =
        FirebaseFirestore.instance.collection('playrooms').doc(playroomId);
    return docRef.get().then((value) {
      // 同じ ID の部屋が存在したらエラーを返す。
      if (value.exists) {
        return null;
      }
      final room = _createDefaultPlayroom(playroomId, admin);
      // TODO: 保存できなかったときの処理を検討
      docRef.set(room.toMap());
      return playroomId;
    });
  }

  Future<void> addPlayer(Player player) {
    return documentRef.set({
      C.playroom.players: {
        player.id: player.toMap()
      },
    }, SetOptions(merge: true));
  }

  Future<void> removePlayer(String playerId) {
    // TODO: 退出ユーザーが管理者だったとき
    // TODO: 退出ユーザーが最後の一人だったとき
    return documentRef.update({
      '${C.playroom.players}.$playerId': FieldValue.delete(),
    });
  }

  void setIsActive(String playerId, bool isActive) async {
    final target = await findPlayer(playerId);
    if (target == null) {
      return;
    }

    documentRef.update({
      '${C.playroom.players}.${target.id}.${C.player.isActive}': isActive,
    });
  }

  Future<Player?> findPlayer(String playerId) {
    return documentRef.get().then((snapshot) {
      final players = _snapshotToPlayerList(snapshot);
      return players.firstWhereOrNull((player) => player.id == playerId);
    });
  }

  static Stream<Playroom> stream(String playroomId) {
    final documentRef = FirebaseFirestore.instance
        .collection('playrooms')
        .doc(playroomId);
    return documentRef.snapshots().transform(
        StreamTransformer<DocumentSnapshot<Map<String, dynamic>>, Playroom>
            .fromHandlers(handleData: (snapshot, sink) {
      final room = _snapshotToPlayroom(snapshot);
      if (room != null) {
        sink.add(room);
      }
    }));
  }

  static Future<Playroom?> find(String playroomId) {
    final documentRef = _getDocumentRef(playroomId);
    return documentRef.get().then((snapshot) {
      return _snapshotToPlayroom(snapshot);
    });
  }

  static Future<bool> exists(String playroomId) async {
    final documentRef = _getDocumentRef(playroomId);
    return documentRef.get().then((snapshot) {
      return snapshot.exists;
    });
  }

  Future<List<Player>> _fetchCurrentPlayers() {
    return documentRef.get().then((snapshot) {
      return _snapshotToPlayerList(snapshot);
    });
  }

  static DocumentReference _getDocumentRef(String playroomId) {
    return FirebaseFirestore.instance
        .collection('playrooms')
        .doc(playroomId);
  }

  static Playroom? _snapshotToPlayroom(DocumentSnapshot snapshot) {
    if (snapshot.exists) {
      try {
        var players = _snapshotToPlayerList(snapshot);
        var topic = TopicHelper.fromName(snapshot.get(C.playroom.topic));
        return Playroom(
          id: snapshot.get(C.playroom.id),
          adminPlayerId: snapshot.get(C.playroom.adminPlayerId),
          players: players,
          wolfCount: snapshot.get(C.playroom.wolfCount),
          timeLimitMinutes: snapshot.get(C.playroom.timeLimitMinutes),
          topic: topic,
          gameState: GameStatusHelper.fromName(
            snapshot.get(C.playroom.gameStatus),
          ),
          createdAt: snapshot.get(C.playroom.createdAt),
        );
      } catch(e) {
        // TODO エラー処理
        print(e);
      }
    }
  }

  static List<Player> _snapshotToPlayerList(DocumentSnapshot snapshot) {
    if (snapshot.exists) {
      try {
        var playerMap = snapshot.get(
            C.playroom.players,
        ) as Map<String, dynamic>;
        var playerList = playerMap.values.toList();
        return playerList
            .map(
              (e) => Player(
                id: e[C.player.id],
                name: e[C.player.name],
                isWolf: e[C.player.isWolf],
                isActive: e[C.player.isActive],
              ),
            ).toList();
      } catch (e) {
        print(e);
      }
    }
    return [];
  }

  static Playroom _createDefaultPlayroom(String playroomId, Player admin) {
    return Playroom(
      id: playroomId,
      adminPlayerId: admin.id,
      players: [admin],
      wolfCount: 1,
      timeLimitMinutes: 5,
      topic: Topic.sports,
      gameState: GameState.standby,
      createdAt: Timestamp.now(),
    );
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

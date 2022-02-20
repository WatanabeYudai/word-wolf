import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:word_wolf/common/c.dart';
import 'package:word_wolf/model/game_state.dart';
import 'package:word_wolf/model/player.dart';
import 'package:word_wolf/model/playroom.dart';
import 'package:word_wolf/model/topic.dart';
import 'package:word_wolf/model/user.dart';
import 'package:word_wolf/util/constants.dart';

class PlayroomRepository {
  PlayroomRepository({
    required this.playroomId,
  });

  final String playroomId;

  late var playroomRef = FirebaseFirestore.instance.collection('playrooms').doc(playroomId);

  late var playersRef = playroomRef.collection('players');

  final db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: Constants.databaseUrl,
  );

  /// プレイルームを作成する。
  static Future<String?> create(Player admin) async {
    final playroomId = _generateRandomString(6);
    final room = _createDefaultPlayroom(playroomId, admin);
    final playroomRef = _getPlayroomRef(playroomId);
    final playerRef = _getPlayerRef(playroomId, admin.id);
    final userRef = _getUserRef(admin.id);

    try {
      await playroomRef.set(room.toMap());
      await userRef.update({ C.user.currentPlayroom: room.id });
      await playerRef.set(admin.toMap());
    } catch(e) {
      // TODO: プレイルーム作成に失敗したときの処理
      print(e);
      return null;
    }

    return playroomId;
  }

  /// プレイルームへの入室処理を行う。
  ///
  /// 入室できたときは null、入室できなかったときはその理由を String で返却する。
  /// 入室の条件は以下のとおり。
  ///
  /// * ゲームがスタンバイ状態であれば入室できる
  /// * ゲームがプレイ中であれば基本的に入室できない
  /// * ゲームがプレイ中でも非アクティブな参加プレイヤーであれば入室できる
  Future<String?> enter(Player player) async {
    final roomSnapshot = await playroomRef.get();
    if (!roomSnapshot.exists) {
      return 'エラーが発生しました。';
    }
    final room = _snapshotToPlayroom(roomSnapshot);
    if (room?.gameState == GameState.standby) {
      // ゲームがスタンバイ状態であれば入室
      _addPlayer(player);
      return null;
    }

    final playersSnapshot = await playersRef.get();
    final players = _snapshotToPlayerList(playersSnapshot);
    final exists = players.firstWhereOrNull((e) {
      return e.id == player.id;
    }) != null;
    if (exists) {
      // 非アクティブな参加プレイヤーはゲームに復帰できる
      _addPlayer(player);
      return null;
    } else {
      // ゲームプレイ中は入室できない
      return 'ゲーム中のため少々お待ちください。';
    }
  }

  /// プレイルームからの退室処理を行う。
  ///
  /// 基本的な処理は以下のとおり。
  /// * ゲームがスタンバイ状態であればプレイヤーリストから削除する
  /// * ゲームがプレイ中であればプレイヤーを非アクティブ化する
  ///
  /// 【補足情報】
  /// * 退出後、プレイヤーが０人になる場合、部屋を閉じる処理のみを行う
  /// * 退出プレイヤーが管理者だった場合、別のプレイヤーを管理者にする
  Future<void> leave(String playerId) async {
    User.find(playerId).then((user) => user.clearCurrentPlayroom());
    final roomSnapshot = await playroomRef.get();
    if (!roomSnapshot.exists) return;
    final room = _snapshotToPlayroom(roomSnapshot);
    if (room == null) return;

    final playersSnapshot = await playersRef.get();
    final players = _snapshotToPlayerList(playersSnapshot);
    final activePlayers = players.where((player) => player.isActive);
    // 自分以外にアクティブなプレイヤーがいない場合は部屋を閉じる
    if (activePlayers.length <= 1) {
      _closePlayroom();
      return;
    }
    // プレイヤーが管理者だった場合は他のプレイヤーを管理者にする
    final isAdmin = room.adminPlayerId == playerId;
    final newAdmin = isAdmin
        ? activePlayers.firstWhere((player) => player.id != playerId)
        : null;
    if (room.gameState == GameState.standby) {
      _removePlayer(playerId, newAdmin?.id);
    } else {
      _inactivatePlayer(playerId, newAdmin?.id);
    }
  }

  Future<void> _addPlayer(Player player) {
    return playersRef.doc(player.id).set(player.toMap());
  }

  Future<void> _removePlayer(String playerId, String? nextAdmin) async {
    if (nextAdmin != null) {
      await playroomRef.update({C.playroom.adminPlayerId: nextAdmin});
    }
    return playersRef.doc(playerId).delete();
  }

  Future<void> _activatePlayer(String playerId) async {
    return playersRef.doc(playerId).update({
      C.player.isActive: true,
    });
  }

  Future<void> _inactivatePlayer(String playerId, String? nextAdmin) async {
    if (nextAdmin != null) {
      playroomRef.update({C.playroom.adminPlayerId: nextAdmin});
    }
    return playersRef.doc(playerId).update({
      C.player.isActive: false,
    });
  }

  Future<void> _closePlayroom() {
    return playroomRef.update({
      C.playroom.isClosed: true,
    });
  }

  Future<Player?> findPlayer(String playerId) async {
    final playersSnapshot = await playersRef.get();
    final players = _snapshotToPlayerList(playersSnapshot);
    return players.firstWhereOrNull((player) => player.id == playerId);
  }

  static Stream<Playroom> playroomStream(String playroomId) {
    final documentRef = _getPlayroomRef(playroomId);
    return documentRef.snapshots().transform(
        StreamTransformer<DocumentSnapshot<Map<String, dynamic>>, Playroom>
            .fromHandlers(handleData: (snapshot, sink) {
      final room = _snapshotToPlayroom(snapshot);
      if (room != null) {
        sink.add(room);
      }
    }));
  }

  static Stream<List<Player>> playersStream(String playroomId) {
    final playersRef = _getPlayersRef(playroomId);
    return playersRef.snapshots().transform(
        StreamTransformer<QuerySnapshot<Map<String, dynamic>>, List<Player>>
            .fromHandlers(handleData: (snapshot, sink) {
      final players = _snapshotToPlayerList(snapshot);
      sink.add(players);
    }));
  }

  static Future<Playroom?> findPlayroom(String playroomId) async {
    final snapshot = await _getPlayroomRef(playroomId).get();
    if (snapshot.exists) {
      return _snapshotToPlayroom(snapshot);
    } else {
      return null;
    }
  }

  static Future<bool> exists(String playroomId) async {
    final documentRef = _getPlayroomRef(playroomId);
    return documentRef.get().then((snapshot) {
      if (!snapshot.exists) return false;
      final room = _snapshotToPlayroom(snapshot);
      if (room?.isClosed == true) {
        return false;
      } else {
        return true;
      }
    });
  }

  static DocumentReference _getPlayroomRef(String playroomId) {
    return FirebaseFirestore.instance
        .collection('playrooms')
        .doc(playroomId);
  }

  static CollectionReference _getPlayersRef(String playroomId) {
    return FirebaseFirestore.instance
        .collection('playrooms')
        .doc(playroomId)
        .collection('players');
  }

  static DocumentReference _getPlayerRef(String playroomId, String playerId) {
    return FirebaseFirestore.instance
        .collection('playrooms')
        .doc(playroomId)
        .collection('players')
        .doc(playerId);
  }

  static DocumentReference _getUserRef(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId);
  }

  static Playroom? _snapshotToPlayroom(DocumentSnapshot snapshot) {
    if (snapshot.exists) {
      try {
        final topic = TopicHelper.fromName(snapshot.get(C.playroom.topic));
        return Playroom(
          id: snapshot.get(C.playroom.id),
          adminPlayerId: snapshot.get(C.playroom.adminPlayerId),
          wolfCount: snapshot.get(C.playroom.wolfCount),
          timeLimitMinutes: snapshot.get(C.playroom.timeLimitMinutes),
          topic: topic,
          gameState: GameStateHelper.fromName(
            snapshot.get(C.playroom.gameState),
          ),
          createdAt: snapshot.get(C.playroom.createdAt),
        );
      } catch(e) {
        // TODO エラー処理
        print(e);
      }
    }
  }

  static List<Player> _snapshotToPlayerList(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data()  as Map<String, dynamic>;
      return Player(
        id: data[C.player.id],
        name: data[C.player.name],
        isWolf: data[C.player.isWolf],
        isActive: data[C.player.isActive],
      );
    }).toList();
  }

  static Player _snapshotToPlayer(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Player(
        id: data['id'],
        name: data['name'],
        isWolf: data['isWolf'],
        isActive: data['isActive'],
    );
  }

  static Playroom _createDefaultPlayroom(String playroomId, Player admin) {
    return Playroom(
      id: playroomId,
      adminPlayerId: admin.id,
      // players: [admin],
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

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
import 'package:word_wolf/repository/user_repository.dart';
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

  /// プレイルームを作成する。
  static Future<String?> create(Player admin) {
    final playroomId = _generateRandomString(6);
    final playroomRef = FirebaseFirestore.instance
        .collection('playrooms')
        .doc(playroomId);
    return playroomRef.get().then((value) {
      // 同じ ID の部屋が存在したらエラーを返す。
      if (value.exists) {
        return null;
      }
      final room = _createDefaultPlayroom(playroomId, admin);
      // TODO: 保存できなかったときの処理を検討
      playroomRef.set(room.toMap());
      FirebaseFirestore.instance
          .collection('users')
          .doc(admin.id)
          .update({ C.user.currentPlayroom: room.id });
      return playroomId;
    });
  }

  /// プレイルームへの入室処理を行う。
  ///
  /// 入室できたときは null、入室できなかったときはその理由を Future<String?> で返却する。
  /// 入室の条件は以下のとおり。
  ///
  /// * ゲームがスタンバイ状態であれば入室できる
  /// * ゲームがプレイ中であれば基本的に入室できない
  /// * ゲームがプレイ中でも非アクティブな参加プレイヤーであれば入室できる
  Future<String?> enter(Player player) {
    return documentRef.get().then((snapshot) {
      if (!snapshot.exists) {
        return '部屋が見つかりませんでした';
      }
      final room = _snapshotToPlayroom(snapshot);
      if (room?.gameState == GameState.standby) {
        // ゲームがスタンバイ状態であれば入室
        _addPlayer(player);
        return null;
      }
      final exists = room?.players.firstWhereOrNull((e) {
        return e.id == player.id;
      }) != null;
      if (exists) {
        // 非アクティブな参加プレイヤーはゲームに復帰できる
        _activatePlayer(player.id);
        return null;
      } else {
        // ゲームプレイ中は入室できない
        return 'ゲーム中のため少々お待ちください';
      }
    });
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
  Future<void> leave(String playerId) {
    return documentRef.get().then((snapshot) {
      UserRepository(userId: playroomId).clearCurrentPlayroom();
      if (!snapshot.exists) return;

      final room = _snapshotToPlayroom(snapshot);
      if (room == null) return;

      final activePlayers = room.players.where((player) => player.isActive);
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
    });
  }

  Future<void> _addPlayer(Player player) {
    UserRepository(userId: player.id).updateCurrentPlayroom(playroomId);
    return documentRef.set({
      C.playroom.players: {
        player.id: player.toMap()
      },
    }, SetOptions(merge: true));
  }

  Future<void> _removePlayer(String playerId, String? nextAdmin) {
    if (nextAdmin != null) {
      return documentRef.update({
        C.playroom.adminPlayerId: nextAdmin,
        '${C.playroom.players}.$playerId': FieldValue.delete(),
      });
    } else {
      return documentRef.update({
        '${C.playroom.players}.$playerId': FieldValue.delete(),
      });
    }
  }

  Future<void> _activatePlayer(String playerId) async {
    UserRepository(userId: playerId).updateCurrentPlayroom(playroomId);
    return documentRef.update({
      '${C.playroom.players}.$playerId.${C.player.isActive}': true,
    });
  }

  Future<void> _inactivatePlayer(String playerId, String? nextAdmin) async {
    UserRepository(userId: playerId).clearCurrentPlayroom();
    if (nextAdmin != null) {
      return documentRef.update({
        C.playroom.adminPlayerId: nextAdmin,
        '${C.playroom.players}.$playerId.${C.player.isActive}': false,
      });
    } else {
      return documentRef.update({
        '${C.playroom.players}.$playerId.${C.player.isActive}': false,
      });
    }
  }

  Future<void> _closePlayroom() {
    return documentRef.update({
      C.playroom.isClosed: true,
    });
  }

  Future<Player?> findPlayer(String playerId) {
    return documentRef.get().then((snapshot) {
      final players = _snapshotToPlayerList(snapshot);
      return players.firstWhereOrNull((player) => player.id == playerId);
    });
  }

  static Stream<Playroom> stream(String playroomId) {
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

  static Future<Playroom?> find(String playroomId) {
    final documentRef = _getPlayroomRef(playroomId);
    return documentRef.get().then((snapshot) {
      return _snapshotToPlayroom(snapshot);
    });
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

  Future<List<Player>> _fetchCurrentPlayers() {
    return documentRef.get().then((snapshot) {
      return _snapshotToPlayerList(snapshot);
    });
  }

  static DocumentReference _getPlayroomRef(String playroomId) {
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

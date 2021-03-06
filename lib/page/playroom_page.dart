import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:word_wolf/custom_widget/full_width_button.dart';
import 'package:word_wolf/custom_widget/no_glow_scroll_view.dart';
import 'package:word_wolf/model/game_state.dart';
import 'package:word_wolf/model/player.dart';
import 'package:word_wolf/model/playroom.dart';
import 'package:word_wolf/model/topic.dart';
import 'package:word_wolf/page/game_settings_page.dart';
import 'package:word_wolf/repository/playroom_repository.dart';

class PlayroomPage extends StatelessWidget {
  PlayroomPage({
    Key? key,
    required this.playroomId,
    required this.playerId,
    required this.isAdmin,
  }) : super(key: key);

  final String playroomId;
  final String playerId;
  final bool isAdmin;

  late var repository = PlayroomRepository(playroomId: playroomId);
  var currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Playroom>(
      stream: Playroom.getPlayroomStream(playroomId),
      builder: (context, snapshot) {
        return WillPopScope(
          onWillPop: () {
            _showLeavingRoomDialog(context, () {
              _onPressedOk(context, snapshot.data);
            });
            return Future.value(true);
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('プレイルーム'),
              leading: TextButton(
                child: const Icon(
                  Icons.home,
                  color: Colors.white,
                ),
                onPressed: () => _showLeavingRoomDialog(context, () {
                  _onPressedOk(context, snapshot.data);
                }),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: NoGlowScrollView(
                child: Builder(builder: (context) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  // TODO: isClosed = true のときエラーダイアログを表示してロビーに戻す
                  if (snapshot.data != null) {
                    final room = snapshot.data!;
                    switch (room.gameState) {
                      case GameState.standby:
                        return ListView(
                          shrinkWrap: true,
                          children: [
                            _createRoomIdView(room),
                            _createGameRulesView(context, room),
                            _createMemberListView(room),
                            FullWidthButton(
                              text: 'ゲーム開始！',
                              onTap: () => {},
                            ),
                          ],
                        );
                      case GameState.playing:
                        return ListView();
                      case GameState.voting:
                        return ListView();
                      case GameState.ended:
                        return ListView();
                    }
                  } else {
                    return const Center(
                      child: Text('エラーが発生しました'),
                    );
                  }
                }),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _createRoomIdView(Playroom room) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            const Text('〜部屋コード〜'),
            Text(room.id),
          ],
        ),
      ),
    );
  }

  Widget _createGameRulesView(BuildContext context, Playroom room) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            const Text('〜ルール〜'),
            Text('人狼の数： ${room.gameSettings.wolfCount}人'),
            Text('制限時間： ${room.gameSettings.timeLimitMinutes}分'),
            Text('テーマ： ${room.gameSettings.topic.displayName()}'),
            ElevatedButton(
              onPressed: () => {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => GameSettingsPage(
                      initialSetting: room.gameSettings,
                      onSubmit: (settings) => room.updateSetting(settings),
                    ),
                  ),
                ),
              },
              child: const Text('編集'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createMemberListView(Playroom room) {
    return StreamBuilder<List<Player>>(
      stream: Playroom.getPlayersStream(playroomId),
      builder: (context, snapshot) {
        final rows = snapshot.data?.map((player) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.circle,
                color: player.isActive ? Colors.greenAccent : Colors.grey,
              ),
              Text(player.name),
            ],
          );
        }).toList();

        return Card(
          child: Column(
            children: [
              const Text('〜メンバー〜'),
              Column(children: rows ?? []),
            ],
          ),
        );
      },
    );
  }

  void _showLeavingRoomDialog(BuildContext context, Function onPressedOk) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('退出'),
        content: const Text('部屋から退出してもよろしいですか？'),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              onPressedOk();
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _onPressedOk(BuildContext context, Playroom? playroom) {
    if (playroom != null) {
      playroom.leave(playerId);
    }
    Navigator.of(context).pop();
  }
}

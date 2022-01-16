import 'package:flutter/material.dart';
import 'package:word_wolf/custom_widget/full_width_button.dart';
import 'package:word_wolf/custom_widget/no_glow_scroll_view.dart';
import 'package:word_wolf/model/playroom.dart';
import 'package:word_wolf/model/topic.dart';
import 'package:word_wolf/repository/playroom_repository.dart';

class PlayroomPage extends StatelessWidget {
  PlayroomPage({
    Key? key,
    required this.roomId,
    required this.userId,
    required this.isAdmin,
  }) : super(key: key);

  final String roomId;
  final String userId;
  final bool isAdmin;

  final PlayroomRepository repository = PlayroomRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プレイルーム'),
        leading: TextButton(
          child: const Icon(
            Icons.home,
            color: Colors.white,
          ),
          onPressed: () => _showLeavingRoomDialog(context, () {
            repository.removeUser(roomId, userId);
          }),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: NoGlowScrollView(
          child: StreamBuilder<Playroom>(
            stream: repository.getPlayroom(roomId),
            builder: (context, playroom) {
              if (!playroom.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (playroom.data != null) {
                var room = playroom.data!;
                return ListView(
                  shrinkWrap: true,
                  children: [
                    _createRoomIdView(room),
                    _createGameRulesView(room),
                    _createMemberListView(room),
                    FullWidthButton(
                      text: 'ゲーム開始！',
                      onTap: () => {},
                    ),
                  ],
                );
              } else {
                return const Center(
                  child: Text('エラーが発生しました'),
                );
              }
            },
          ),
        ),
      ),
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

  Widget _createGameRulesView(Playroom room) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            const Text('〜ルール〜'),
            Text('人狼の数： ${room.wolfCount}人'),
            Text('制限時間： ${room.timeLimitMinutes}分'),
            Text('テーマ： ${room.topic.displayName()}'),
          ],
        ),
      ),
    );
  }

  Widget _createMemberListView(Playroom room) {
    return Card(
      child: Column(
        children: const [Text('〜メンバー〜')] +
            room.users.map((user) => Text(user.name)).toList(),
      ),
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
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:word_wolf/custom_widget/no_glow_scroll_view.dart';
import 'package:word_wolf/custom_widget/simple_alert_dialog.dart';
import 'package:word_wolf/custom_widget/simple_input_field.dart';
import 'package:word_wolf/model/player.dart';
import 'package:word_wolf/model/playroom.dart';
import 'package:word_wolf/page/playroom_page.dart';

class NameInputPage extends StatelessWidget {
  NameInputPage({
    Key? key,
    required this.isAdmin,
    this.playroomId,
  }) : super(key: key);

  final bool isAdmin;
  String? playroomId;

  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('名前入力'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: NoGlowScrollView(
              child: ListView(
                shrinkWrap: true,
                children: [
                  SizedBox(
                    height: 200,
                    child: Image.asset('images/boy.png'),
                  ),
                  const SizedBox(height: 16),
                  SimpleInputField(
                    hintText: 'あなたの名前を入力してください',
                    buttonText: '完了',
                    validator: _validate,
                    onSubmit: (name) => {_onSubmit(context, name)},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<String?> _validate(String? name) async {
    if (name?.isEmpty ?? true) {
      return '名前を入力してください。';
    }

    if (isAdmin) {
      return null;
    }

    return await Playroom.exists(playroomId!).then((exists) {
      if (!exists) {
        return "部屋が見つかりませんでした。";
      } else {
        return null;
      }
    });
  }

  void _onSubmit(BuildContext context, String name) async {
    if (name.isEmpty) {
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // TODO: エラー表示
      return;
    }

    final player = Player(
      id: currentUser.uid,
      name: name,
      isWolf: false,
      isActive: true,
    );

    if (playroomId == null) {
      // 部屋を作成する場合
      playroomId = await _createPlayroom(player);
    } else {
      // 部屋に入る場合
      final playroom = await Playroom.find(playroomId!);
      final errorMessage = await playroom?.enter(player);
      if (errorMessage != null) {
        showDialog(
          context: context,
          builder: (_) => SimpleAlertDialog(message: errorMessage),
        );
        return;
      }
    }

    if (playroomId != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PlayroomPage(
            playroomId: playroomId!,
            playerId: player.id,
            isAdmin: isAdmin,
          ),
        ),
      );
    } else {
      // TODO: エラー処理
    }
  }

  Future<String?> _createPlayroom(Player player) {
    // TODO: 「お待ちください」的な表示
    // TODO: ボタンを複数回クリックできないようにする
    return Playroom.create(player).then((id) {
      if (id != null) {
        return id;
      } else {
        // TODO: 「エラーが発生しました」ダイアログ
        return null;
      }
    });
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:word_wolf/custom_widget/no_glow_scroll_view.dart';
import 'package:word_wolf/custom_widget/simple_input_field.dart';
import 'package:word_wolf/model/player.dart';
import 'package:word_wolf/page/playroom_page.dart';
import 'package:word_wolf/repository/playroom_repository.dart';

class NameInputPage extends StatelessWidget {
  NameInputPage({
    Key? key,
    required this.isAdmin,
    this.playroomId,
  }) : super(key: key);

  final bool isAdmin;
  String? playroomId;

  final GlobalKey<FormState> _formKey = GlobalKey();
  String? validationMessage;

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
                    prepareValidation: _prepareValidation,
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

  Future<void> _prepareValidation(String? name) async {
    if (name?.isEmpty ?? true) {
      validationMessage = '名前を入力してください';
      return;
    }

    if (isAdmin) {
      validationMessage = null;
      return;
    }

    var repository = PlayroomRepository(playroomId: playroomId!);
    return await repository.exists(playroomId!).then((exists) {
      if (!exists) {
        validationMessage = "部屋が見つかりませんでした";
      } else {
        validationMessage = null;
      }
    });
  }

  String? _validate(String? name) {
    return validationMessage;
  }

  void _onSubmit(BuildContext context, String name) async {
    if (name.isEmpty) {
      return;
    }

    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // TODO: エラー表示
      return;
    }

    var player = Player(
      id: currentUser.uid,
      name: name,
      isWolf: false,
      isActive: true,
    );

    if (playroomId == null) {
      await _createPlayroom(player).then((id) => playroomId = id);
    } else {
      var repository = PlayroomRepository(playroomId: playroomId!);
      await repository.addPlayer(player);
    }

    if (playroomId != null) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => PlayroomPage(
          playroomId: playroomId!,
          playerId: player.id,
          isAdmin: isAdmin,
        ),
      ));
    } else {
      // TODO: エラー処理
    }
  }

  Future<String?> _createPlayroom(Player player) async {
    // TODO: 「お待ちください」的な表示
    // TODO: ボタンを複数回クリックできないようにする
    return PlayroomRepository.createPlayroom(player).then((id) {
      if (id != null) {
        return id;
      } else {
        // TODO: 「エラーが発生しました」ダイアログ
        return null;
      }
    });
  }
}

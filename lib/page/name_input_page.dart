import 'package:flutter/material.dart';
import 'package:word_wolf/custom_widget/no_glow_scroll_view.dart';
import 'package:word_wolf/custom_widget/simple_input_field.dart';
import 'package:word_wolf/model/user.dart';
import 'package:word_wolf/page/playroom_page.dart';
import 'package:word_wolf/repository/playroom_repository.dart';

class NameInputPage extends StatelessWidget {
  NameInputPage({
    Key? key,
    required this.isAdminUser,
    this.roomId,
  }) : super(key: key);

  final bool isAdminUser;
  String? roomId;

  final GlobalKey<FormState> _formKey = GlobalKey();
  final PlayroomRepository repository = PlayroomRepository();

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
                    validator: (name) {
                      if (name?.isEmpty ?? true) {
                        return '名前を入力してください';
                      }
                      return null;
                    },
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

  void _onSubmit(BuildContext context, String name) async {
    if (name.isEmpty) {
      return;
    }

    User user = User.create(name: name, isWolf: false);
    if (isAdminUser) {
      await _createPlayroom(user).then((id) => roomId = id);
    } else {
      _addUser(user);
    }

    if (roomId != null) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => PlayroomPage(
          roomId: roomId ?? '', // TODO: 空文字が渡る余地を無くしたい
          isAdmin: true,
        ),
      ));
    } else {
      // TODO: エラー処理
    }
  }

  Future<String?> _createPlayroom(User user) async {
    // TODO: 「お待ちください」的な表示
    // TODO: ボタンを複数回クリックできないようにする
    return repository.createPlayroom(user).then((id) {
      if (id != null) {
        return id;
      } else {
        // TODO: 「エラーが発生しました」ダイアログ
        return null;
      }
    });
  }

  void _addUser(User user) {
    // TODO: 追加前にルームの存在チェックを行う
  }
}

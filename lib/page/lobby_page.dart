import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:word_wolf/custom_widget/no_glow_scroll_view.dart';
import 'package:word_wolf/model/playroom.dart';
import 'package:word_wolf/page/name_input_page.dart';
import 'package:word_wolf/repository/user_repository.dart';

import '../custom_widget/full_width_button.dart';
import '../custom_widget/simple_input_field.dart';

class LobbyPage extends StatelessWidget {
  LobbyPage({Key? key}) : super(key: key);

  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  Playroom? room;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ワードウルフ'),
      ),
      body: GestureDetector(
        onTap: () {
          final FocusScopeNode currentScope = FocusScope.of(context);
          if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
            FocusManager.instance.primaryFocus?.unfocus();
          }
        },
        child: Center(
          child: NoGlowScrollView(
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                /// TODO: デバッグ用なので最終的に削除
                Text(
                  uid ?? '',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  height: 200,
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  child: Image.asset('images/wolf.png'),
                ),
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  width: double.infinity,
                  child: const Text('部屋をつくってみんなを招待しよう！'),
                ),
                const SizedBox(height: 4),
                FullWidthButton(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  text: '部屋をつくる',
                  onTap: () => _onTapCreatePlayroom(context),
                ),
                const SizedBox(height: 32),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  width: double.infinity,
                  child: const Text('部屋コードを入力してゲームに参加しよう！'),
                ),
                const SizedBox(height: 4),
                SimpleInputField(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  hintText: '部屋コード',
                  buttonText: '部屋に入る',
                  // FIXME: このバリデーションだとボタン連打が可能 = 通信コストがかかるのでダイアログ表示にする
                  validator: _validate,
                  onSubmit: (code) => _onTapEnterPlayroom(context, code),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTapCreatePlayroom(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => NameInputPage(isAdmin: true),
    ));
  }

  void _onTapEnterPlayroom(BuildContext context, String code) async {
    await UserRepository(userId: uid!).setCurrentPlayroom(code);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => NameInputPage(
        isAdmin: false,
        playroomId: code,
      ),
    ));
  }

  Future<String?> _validate(String? code) async {
    room = null;
    if (code?.isEmpty ?? true) {
      return '部屋コードを入力してください。';
    }

    room = await Playroom.find(code!);
    if (room == null) {
      return '部屋コードが間違っています。';
    }
    if (room?.isClosed == true) {
      return 'この部屋には入室できません。';
    }

    return null;
  }
}

class AlignCenterTextFormField extends StatelessWidget {
  const AlignCenterTextFormField({
    Key? key,
    required this.hintText,
  }) : super(key: key);

  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textAlign: TextAlign.center,
      decoration: const InputDecoration(
        hintText: '部屋コード',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 8,
        ),
      ),
    );
  }
}

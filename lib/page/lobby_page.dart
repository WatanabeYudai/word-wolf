import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:word_wolf/custom_widget/no_glow_scroll_view.dart';
import 'package:word_wolf/model/player.dart';
import 'package:word_wolf/model/playroom.dart';
import 'package:word_wolf/page/name_input_page.dart';
import 'package:word_wolf/page/playroom_page.dart';

import '../custom_widget/full_width_button.dart';
import '../custom_widget/simple_input_field.dart';

class LobbyPage extends StatelessWidget {
  LobbyPage({Key? key}) : super(key: key);

  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  String? validationMessage;

  bool canReenter = false;

  Playroom? room;

  Player? player;

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
                  prepareValidation: _prepareValidation,
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
    if (canReenter) {
      // 再入室可能な場合
      if (room != null && player != null) {
        final error = await room?.enter(player!);
        if (error == null) {
          // FIXME: プレイヤーがアクティブ化しない
          room?.enter(player!);
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => PlayroomPage(
              playroomId: room!.id,
              playerId: player!.id,
              isAdmin: false,
            ),
          ));
        } else {
          // TODO: エラー処理
        }
      } else {
        // TODO: エラー処理
      }
    } else {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => NameInputPage(
          isAdmin: false,
          playroomId: code,
        ),
      ));
    }
  }

  Future<void> _prepareValidation(String? code) async {
    room = null;
    player = null;
    canReenter = false;
    validationMessage = null;

    if (code?.isEmpty ?? true) {
      validationMessage = '部屋コードを入力してください';
      return;
    }

    room = await Playroom.find(code!);
    if (room != null) {
      if (room?.isClosed == true) {
        validationMessage = 'この部屋には入室できません';
        return;
      }
      player = room?.findPlayer(uid ?? '');
      canReenter = player != null ? true : false;
      if (room?.isNowPlaying() == true && !canReenter) {
        validationMessage = '現在ゲームプレイ中のため終了までお待ちください';
        return;
      }
      validationMessage = null;
    } else {
      validationMessage = '部屋コードが間違っています';
    }
  }

  String? _validate(String? code) {
    return validationMessage;
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

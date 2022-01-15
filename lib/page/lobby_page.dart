import 'package:flutter/material.dart';
import 'package:word_wolf/custom_widget/no_glow_scroll_view.dart';
import 'package:word_wolf/page/name_input_page.dart';
import 'package:word_wolf/repository/playroom_repository.dart';

import '../custom_widget/full_width_button.dart';
import '../custom_widget/simple_input_field.dart';

class LobbyPage extends StatelessWidget {
  LobbyPage({Key? key}) : super(key: key);

  final repository = PlayroomRepository();

  String? validationMessage;

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
      builder: (_) => NameInputPage(isAdminUser: true),
    ));
  }

  void _onTapEnterPlayroom(BuildContext context, String code) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => NameInputPage(
        isAdminUser: false,
        roomId: code,
      ),
    ));
  }

  Future<void> _prepareValidation(String? code) async {
    if (code?.isEmpty ?? true) {
      validationMessage = '部屋コードを入力してください';
      return;
    }
    return await repository.exists(code!).then((exists) {
      if (exists) {
        validationMessage = null;
      } else {
        validationMessage = '部屋コードが間違ってます';
      }
    });
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

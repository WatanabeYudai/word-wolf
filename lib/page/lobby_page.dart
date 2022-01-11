import 'package:flutter/material.dart';
import 'package:word_wolf/custom_widget/no_glow_scroll_view.dart';
import 'package:word_wolf/page/name_input_page.dart';

import '../custom_widget/full_width_button.dart';
import '../custom_widget/simple_input_field.dart';

class LobbyPage extends StatefulWidget {
  const LobbyPage({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  State<LobbyPage> createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
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
                onTap: _onTapCreatePlayroom,
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
                validator: _validateName,
                onSubmit: (code) => _onTapEnterPlayroom(code),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _clearFocus() {
    FocusScopeNode focus = FocusScope.of(context);
    if (!focus.hasPrimaryFocus) {
      focus.unfocus();
    }
  }

  void _onTapCreatePlayroom() {
    _clearFocus();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => NameInputPage(isAdminUser: true),
    ));
  }

  void _onTapEnterPlayroom(String code) {
    _clearFocus();
  }

  String? _validateName(String? name) {
    if (name?.isEmpty ?? true) {
      return '部屋コードを入力してください';
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

import 'package:flutter/material.dart';
import 'package:word_wolf/custom_widget/no_glow_scroll_view.dart';
import 'package:word_wolf/custom_widget/simple_input_field.dart';
import 'package:word_wolf/playroom_page.dart';
import 'package:word_wolf/repository/playroom_repository.dart';

class NameInputPage extends StatefulWidget {

  const NameInputPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NameInputState();
}

class _NameInputState extends State<NameInputPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('名前入力'),
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
                child: Image.asset('images/boy.png'),
              ),
              const SizedBox(height: 16),
              SimpleInputField(
                hintText: 'ニックネーム',
                buttonText: '完了',
                margin: const EdgeInsets.symmetric(horizontal: 32),
                validator: _validateName,
                onSubmit: (name) => _onSubmit(name),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _onSubmit(String name) {
    PlayroomRepository repository = PlayroomRepository();
    repository.createPlayroom();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PlayroomPage(),
      ),
    );
  }

  String? _validateName(String? name) {
    if (name?.isEmpty ?? true) {
      return 'ニックネームを入力してください';
    }
    return null;
  }
}

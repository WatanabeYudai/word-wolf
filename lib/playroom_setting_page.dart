import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:word_wolf/custom_widget/no_glow_scroll_view.dart';
import 'package:word_wolf/custom_widget/simple_input_field.dart';
import 'package:word_wolf/model/user.dart';
import 'package:word_wolf/playroom_page.dart';
import 'package:word_wolf/repository/playroom_repository.dart';

class PlayroomSettingPage extends StatefulWidget {
  const PlayroomSettingPage({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PlayroomSettingState();
}

class _PlayroomSettingState extends State<PlayroomSettingPage> {

  TextEditingController controller = TextEditingController();

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
                controller: controller,
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
    User user = User(
      id: const Uuid().v1(),
      name: name,
    );
    repository.createPlayroom(user);
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

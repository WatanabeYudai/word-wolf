import 'package:flutter/material.dart';
import 'package:word_wolf/custom_widget/no_glow_scroll_view.dart';
import 'package:word_wolf/custom_widget/selection_view.dart';
import 'package:word_wolf/model/game_settings.dart';
import 'package:word_wolf/model/topic.dart';

import '../custom_widget/full_width_button.dart';

class GameSettingsPage extends StatefulWidget {
  const GameSettingsPage({
    required this.initialSetting,
    required this.onSubmit,
    Key? key,
  }) : super(key: key);

  final GameSettings initialSetting;
  final Function(GameSettings) onSubmit;

  @override
  State<StatefulWidget> createState() => _GameSettingsPageState();
}

class _GameSettingsPageState extends State<GameSettingsPage> {
  late int _wolfCount;
  late int _timeLimitMinutes;
  late Topic _topic;

  final List<String> _timeLimitMinutesData = [
    '無制限', '1分', '2分', '3分', '4分', '5分',
    '6分', '7分', '8分', '9分', '10分',
  ];

  final List<String> _wolfCountData = [
    '1人', '2人', '3人', '4人'
  ];

  final List<String> _topicData = TopicHelper.displayNameList();

  @override
  void initState() {
    super.initState();

    _wolfCount = widget.initialSetting.wolfCount;
    _timeLimitMinutes = widget.initialSetting.timeLimitMinutes;
    _topic = widget.initialSetting.topic;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ゲーム設定'),
      ),
      body: GestureDetector(
        onTap: () {
          final FocusScopeNode currentScope = FocusScope.of(context);
          if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
            FocusManager.instance.primaryFocus?.unfocus();
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Form(
            child: (NoGlowScrollView(
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  const SizedBox(height: 32),
                  _createTimeLimitInputView(),
                  const SizedBox(height: 16),
                  const Divider(thickness: 2),
                  const SizedBox(height: 16),
                  _createTopicInputView(),
                  const SizedBox(height: 16),
                  const Divider(thickness: 2),
                  const SizedBox(height: 16),
                  _createWolfCountInputView(),
                  const SizedBox(height: 48),
                  FullWidthButton(
                    text: '完了！',
                    onTap: () => {_onSubmit()},
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            )),
          ),
        ),
      ),
    );
  }

  Widget _createTimeLimitInputView() {
    return SelectionView(
      title: '制限時間',
      initialPosition: widget.initialSetting.timeLimitMinutes,
      data: _timeLimitMinutesData,
      onPressedNext: _updateTimeLimitMinutes,
      onPressedPrev: _updateTimeLimitMinutes,
    );
  }

  Widget _createTopicInputView() {
    final displayName = widget.initialSetting.topic.displayName();
    final pos = _topicData.indexWhere((data) => data == displayName);
    return SelectionView(
        title: 'テーマ',
        initialPosition: pos,
        data: _topicData,
        onPressedNext: _updateTopic,
        onPressedPrev: _updateTopic,
    );
  }

  Widget _createWolfCountInputView() {
    final count = widget.initialSetting.wolfCount - 1;
    return SelectionView(
        title: '人狼の数',
        description: '村人よりも少なくなるように設定してください。',
        initialPosition: count,
        data: _wolfCountData,
        onPressedNext: _updateWolfCount,
        onPressedPrev: _updateWolfCount,
    );
  }

  void _updateTimeLimitMinutes(int pos) => setState(() {
    _timeLimitMinutes = pos;
  });

  void _updateTopic(int pos) => setState(() {
    if (pos < 0 || _topicData.length <= pos) {
      return;
    }
    final displayName = _topicData[pos];
    _topic = TopicHelper.fromDisplayName(displayName);
  });

  void _updateWolfCount(int pos) => setState(() {
    _wolfCount = pos + 1;
  });

  void _onSubmit() {
    final setting = GameSettings(
      wolfCount: _wolfCount,
      timeLimitMinutes: _timeLimitMinutes,
      topic: _topic,
    );
    widget.onSubmit(setting);
    Navigator.of(context).pop();
  }
}

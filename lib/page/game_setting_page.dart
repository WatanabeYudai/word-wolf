import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:word_wolf/custom_widget/no_glow_scroll_view.dart';
import 'package:word_wolf/custom_widget/number_input_view.dart';
import 'package:word_wolf/model/topic.dart';
import 'package:word_wolf/model/user.dart';
import 'package:word_wolf/repository/playroom_repository.dart';
import 'package:word_wolf/state_manager/game_setting_state_manager.dart';
import '../custom_widget/full_width_button.dart';

class GameSettingPage extends HookConsumerWidget {
  GameSettingPage({
    Key? key,
  }) : super(key: key);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            key: _formKey,
            child: (
              NoGlowScrollView(
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    const SizedBox(height: 32),
                    _NumberOfPeopleInputView(),
                    const SizedBox(height: 16),
                    const Divider(thickness: 2),
                    const SizedBox(height: 16),
                    _TimeLimitInputView(),
                    const SizedBox(height: 16),
                    const Divider(thickness: 2),
                    const SizedBox(height: 16),
                    _TopicInputView(),
                    const SizedBox(height: 16),
                    const Divider(thickness: 2),
                    const SizedBox(height: 16),
                    _NameInputView(
                      controller: controller,
                    ),
                    const SizedBox(height: 48),
                    FullWidthButton(
                      text: '完了！',
                      onTap: () => {
                        _onSubmit()
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              )
            ),
          ),
        ),
      ),
    );
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    String name = controller.text;
    User adminUser = User.create(name: name, isWolf: false);
    PlayroomRepository.createPlayroom(adminUser);
  }
}

class _NumberOfPeopleInputView extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    GameSettingState state = ref.watch(gameSettingProvider);
    int wolfMaxCount = state.humanCount % 2 == 0
        ? (state.humanCount ~/ 2) - 1
        : (state.humanCount / 2).floor();
    return Column(
      children: [
        Text(
          '市民の人数',
          style: Theme.of(context).textTheme.headline6,
        ),
        NumberInputView(
          current: state.humanCount,
          min: 3,
          max: 10,
          unit: '人',
          onIncrement: () {
            ref.read(gameSettingProvider.notifier).incrementHumanCount();
          },
          onDecrement: () {
            ref.read(gameSettingProvider.notifier).decrementHumanCount();
          },
        ),
        const SizedBox(height: 16),
        Text(
          '狼の人数',
          style: Theme.of(context).textTheme.headline6,
        ),
        NumberInputView(
          current: state.wolfCount,
          min: 1,
          max: wolfMaxCount,
          unit: '人',
          onIncrement: () {
            ref.read(gameSettingProvider.notifier).incrementWolfCount();
          },
          onDecrement: () {
            ref.read(gameSettingProvider.notifier).decrementWolfCount();
          },
        ),
        const SizedBox(height: 16),
        Text(
          '合計 ${state.humanCount + state.wolfCount} 人',
          style: Theme.of(context).textTheme.headline5,
        ),
      ],
    );
  }
}

class _TimeLimitInputView extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    GameSettingState state = ref.watch(gameSettingProvider);
    return Column(
      children: [
        Text(
          '制限時間',
          style: Theme.of(context).textTheme.headline6,
        ),
        NumberInputView(
          current: state.timeLimitMinute,
          min: 0,
          max: 30,
          unit: '分',
          customTexts: const {0: '制限なし'},
          onIncrement: () {
            ref.read(gameSettingProvider.notifier).incrementTimeLimit();
          },
          onDecrement: () {
            ref.read(gameSettingProvider.notifier).decrementTimeLimit();
          },
        ),
      ],
    );
  }
}

class _TopicInputView extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    GameSettingState state = ref.watch(gameSettingProvider);
    Map<int, String> topicsMap = {
      Topic.all.id(): Topic.all.displayName(),
      Topic.food.id(): Topic.food.displayName(),
      Topic.sports.id(): Topic.sports.displayName(),
    };
    return Column(
      children: [
        Text(
          'テーマ',
          style: Theme.of(context).textTheme.headline6,
        ),
        NumberInputView(
          current: state.topic.id(),
          min: 0,
          max: Topic.values.length - 1,
          customTexts: topicsMap,
          onIncrement: () {
            ref.read(gameSettingProvider.notifier).nextTopic();
          },
          onDecrement: () {
            ref.read(gameSettingProvider.notifier).prevTopic();
          },
        ),
      ],
    );
  }
}

class _NameInputView extends HookConsumerWidget {

  const _NameInputView({
    this.formKey,
    this.controller,
  });

  final GlobalKey? formKey;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Text(
          '名前',
          style: Theme.of(context).textTheme.headline6,
        ),
        const SizedBox(height: 8),
        TextFormField(
          key: formKey,
          controller: controller,
          textAlign: TextAlign.center,
          validator: (name) {
            if (name?.isEmpty ?? true) {
              return '名前を入力してください';
            }
            return null;
          },
          decoration: const InputDecoration(
            hintText: 'あなたの名前を入力してください',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 8,
            ),
          ),
        ),
      ],
    );
  }
}

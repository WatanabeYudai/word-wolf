import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class NumberInputView extends HookConsumerWidget {
  const NumberInputView({
    Key? key,
    required this.current,
    this.min,
    this.max,
    this.unit,
    this.customTexts,
    this.onIncrement,
    this.onDecrement,
  }) : super(key: key);

  final int current;
  final int? min;
  final int? max;
  final String? unit;
  final Map<int, String>? customTexts;
  final Function()? onIncrement;
  final Function()? onDecrement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          child: const Icon(Icons.arrow_left),
          style: ElevatedButton.styleFrom(
            primary: Theme.of(context).colorScheme.primary,
            onPrimary: Colors.white,
            shape: const CircleBorder(),
          ),
          onPressed: _decrement,
        ),
        Text(
          _getText(),
          style: const TextStyle(
            fontSize: 24,
          ),
        ),
        ElevatedButton(
          child: const Icon(Icons.arrow_right),
          style: ElevatedButton.styleFrom(
            primary: Theme.of(context).colorScheme.primary,
            onPrimary: Colors.white,
            shape: const CircleBorder(),
          ),
          onPressed: _increment,
        ),
      ],
    );
  }

  String _getText() {
    bool hasKey = customTexts?.containsKey(current) ?? false;
    if (hasKey) {
      return customTexts?[current] ?? '';
    }
    return current.toString() + (unit ?? '');
  }

  void _increment() {
    if (current == max) {
      return;
    }
    onIncrement?.call();
  }

  void _decrement() {
    if (current == min) {
      return;
    }
    onDecrement?.call();
  }
}

import 'package:flutter/material.dart';

class SelectionView extends StatefulWidget {
  const SelectionView({
    Key? key,
    required this.title,
    this.description,
    this.initialPosition,
    required this.data,
    this.onPressedNext,
    this.onPressedPrev,
  }) : super(key: key);

  final String title;
  final String? description;
  final int? initialPosition;
  final List<String> data;
  final Function(int)? onPressedNext;
  final Function(int)? onPressedPrev;

  @override
  State<StatefulWidget> createState() => _SelectionViewState();
}

class _SelectionViewState extends State<SelectionView> {
  int _currentPosition = 0;
  String _item = '';

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.initialPosition ?? 0;
    _item = widget.data[_currentPosition];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          widget.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        if (widget.description != null) Text(widget.description ?? ''),
        const SizedBox(height: 8),
        _buildSelectionView(context),
      ],
    );
  }

  Widget _buildSelectionView(BuildContext context) {
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
          onPressed: () => {_onPressedPrev()},
        ),
        Text(
          _item,
          style: const TextStyle(fontSize: 24),
        ),
        ElevatedButton(
          child: const Icon(Icons.arrow_right),
          style: ElevatedButton.styleFrom(
            primary: Theme.of(context).colorScheme.primary,
            onPrimary: Colors.white,
            shape: const CircleBorder(),
          ),
          onPressed: () => {_onPressedNext()},
        ),
      ],
    );
  }

  void _onPressedNext() {
    if (widget.onPressedNext == null) {
      return;
    }
    if (_currentPosition <= widget.data.length - 1) {
      _currentPosition++;
      setState(() {
        _item = widget.data[_currentPosition];
      });
      widget.onPressedNext?.call(_currentPosition);
    }
  }

  void _onPressedPrev() {
    if (widget.onPressedPrev == null) {
      return;
    }
    if (_currentPosition > 0) {
      _currentPosition--;
      setState(() {
        _item = widget.data[_currentPosition];
      });
      widget.onPressedPrev?.call(_currentPosition);
    }
  }
}

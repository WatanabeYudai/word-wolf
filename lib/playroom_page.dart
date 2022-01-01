
import 'package:flutter/material.dart';

class PlayroomPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PlayroomState();
}

class _PlayroomState extends State<PlayroomPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プレイルーム'),
      ),
    );
  }
}
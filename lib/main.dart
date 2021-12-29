import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Wolf',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'ワードウルフ'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 300,
                child: Image.asset('images/wolf.png'),
              ),
              const SizedBox(height: 16,),
              const SizedBox(
                width: double.infinity,
                child: Text('部屋をつくってみんなを招待しよう！'),
              ),
              const SizedBox(height: 4),
              const FullWidthButton(text: '部屋をつくる'),
              const SizedBox(height: 16),
              const SizedBox(
                width: double.infinity,
                child: Text('部屋コードを入力してゲームに参加しよう！'),
              ),
              const SizedBox(height: 4),
              const AlignCenterTextFormField(hintText: '部屋コード'),
              const SizedBox(height: 8),
              const FullWidthButton(text: '部屋に入る'),
            ],
          ),
        ),
      ),
    );
  }
}

class FullWidthButton extends StatelessWidget {

  const FullWidthButton({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () => {},
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ),
    );
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

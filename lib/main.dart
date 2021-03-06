import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:word_wolf/common/presence_manager.dart';

import 'page/lobby_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  
  // const flavor = String.fromEnvironment('FLAVOR');
  // if (flavor == 'dev') {
  //   FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  //   FirebaseDatabase.instance.useDatabaseEmulator('localhost', 9000);
  //   FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  // }

  final auth = FirebaseAuth.instance;
  var currentUser = auth.currentUser;
  if (currentUser == null) {
    var userCredential = await auth.signInAnonymously();
    currentUser = userCredential.user;
  }

  if (currentUser != null) {
    var manager = PresenceManager();
    await manager.setUserPresenceListener(currentUser.uid);
    runApp(
      const ProviderScope(
        child: MyApp(),
      ),
    );
  } else {
    // TODO: エラー表示
  }
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
      home: LobbyPage(),
    );
  }
}

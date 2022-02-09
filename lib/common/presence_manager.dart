import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:word_wolf/model/user.dart';
import 'package:word_wolf/util/constants.dart';

class PresenceManager {

  final db = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: Constants.databaseUrl,
  );

  Future<void> setUserPresenceListener(String uid) async {
    final myConnectionRef = db.ref('users/$uid');
    final connectedRef = db.ref('.info/connected');
    final offlineStatus = {
      'state': UserState.offline.name,
      'lastChanged': ServerValue.timestamp,
    };
    final onlineStatus = {
      'state': UserState.online.name,
      'lastChanged': ServerValue.timestamp,
    };
    connectedRef.onValue.listen((event) {
      final connected = event.snapshot.value;
      if (connected == false) {
        myConnectionRef.set(offlineStatus);
        return;
      }
      myConnectionRef.onDisconnect().set(offlineStatus).then((value) {
        myConnectionRef.set(onlineStatus);
      });
    });
  }
}
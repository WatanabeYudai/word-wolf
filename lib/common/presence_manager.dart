import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:word_wolf/util/constants.dart';

class PresenceManager {

  final db = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: Constants.databaseUrl,
  );

  Future<void> updateUserPresence(String uid) async {
    var myConnectionRef = db.ref('users/$uid');
    var connectedRef = db.ref('.info/connected');
    connectedRef.onValue.listen((event) {
      var connected = event.snapshot.value;
      if (connected == false) {
        return;
      }
      myConnectionRef.onDisconnect().set({
        'isConnected': false,
        'lastChanged': ServerValue.timestamp,
      }).then((value) {
        myConnectionRef.set({
          'isConnected': true,
          'lastChanged': ServerValue.timestamp,
        });
      });
    });
  }
}
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:word_wolf/util/constants.dart';

class PresenceManager {

  final db = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: Constants.databaseUrl,
  );

  Future<void> setUserPresenceListener(String uid) async {
    var myConnectionRef = db.ref('users/$uid');
    var connectedRef = db.ref('.info/connected');
    var offlineStatus = {
      'isConnected': false,
      'lastChanged': ServerValue.timestamp,
    };
    var onlineStatus = {
      'isConnected': true,
      'lastChanged': ServerValue.timestamp,
    };
    connectedRef.onValue.listen((event) {
      var connected = event.snapshot.value;
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
import 'package:cloud_firestore/cloud_firestore.dart';

class PlayroomRepository {
  Future<void> createPlayroom() async {
    final int timestamp = DateTime.now().microsecondsSinceEpoch;
    final String id = 'ABCDE';
    await FirebaseFirestore.instance.collection('playrooms').doc(id).set({
      'name': 'test',
      'date_time': timestamp,
    });
  }
}
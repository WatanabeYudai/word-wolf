import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  User({
    required this.id,
    required this.state,
    required this.currentPlayroom,
    required this.lastChanged,
  });

  final String id;
  UserState state;
  String currentPlayroom;
  Timestamp lastChanged;
}

enum UserState {
  online,
  offline,
}

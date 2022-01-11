import 'package:uuid/uuid.dart';

class User {
  User({
    required this.id,
    required this.name,
    required this.isWolf,
  });

  User.create({
    required this.name,
    required this.isWolf,
  }) {
    id = const Uuid().v1();
  }

  late final String id;
  final String name;
  final bool isWolf;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isWolf': isWolf,
    };
  }
}

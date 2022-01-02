import 'package:uuid/uuid.dart';

class User {
  User({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}

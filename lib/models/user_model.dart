import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String name;
  final String email;
  final bool isAdmin;
  final DateTime created;

  User({
    this.name,
    this.email,
    this.isAdmin,
    this.created,
  });

  Map<String, dynamic> toMap() {
    return {
      'name' : name,
      'email': email,
      'isAdmin': isAdmin,
      'created' : created,
    };
  }

  User.fromMap(Map<String, dynamic> map)
    : assert(map['name'] != null),
      assert(map['email'] != null),
      assert(map['isAdmin'] != null),
      name = map['name'],
      email = map['email'],
      isAdmin = map['isAdmin'],
      created = map['created'].toDate(); 

  User.fromSnapshot(DocumentSnapshot snapshot)
    : this.fromMap(snapshot.data);
}
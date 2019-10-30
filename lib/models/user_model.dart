import 'package:badiup/models/user_setting_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String name;
  final RoleType role;
  final DocumentReference setting;
  final DateTime created;

  User({
    this.name,
    this.role,
    this.setting,
    this.created,
  });

  Map<String, dynamic> toMap() {
    return {
      'name' : name,
      'role': role.index,
      'setting': setting,
      'created' : created,
    };
  }

  bool isAdmin() {
    return ( role == RoleType.admin );
  }

  User.fromMap(Map<String, dynamic> map)
    : assert(map['name'] != null),
      assert(map['role'] != null),
      name = map['name'],
      role = RoleType.values[ map['role'] ],
      setting = map['setting'],
      created = map['created'].toDate(); 

  User.fromSnapshot(DocumentSnapshot snapshot)
    : this.fromMap(snapshot.data);
}

enum RoleType {
  admin,    // 0
  customer, // 1
}

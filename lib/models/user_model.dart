import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:badiup/models/user_setting_model.dart';

class User {
  final String email;
  final String name;
  final RoleType role;
  final UserSetting setting;
  final DateTime created;

  User({
    this.email,
    this.name,
    this.role,
    this.setting,
    this.created,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name' : name,
      'role': role.index,
      'setting': setting.toMap(),
      'created' : created,
    };
  }

  bool isAdmin() {
    return ( role == RoleType.admin );
  }

  User.fromMap(Map<String, dynamic> map)
    : assert(map['email'] != null),
      assert(map['name'] != null),
      assert(map['role'] != null),
      email = map['email'],
      name = map['name'],
      role = RoleType.values[ map['role'] ],
      setting = UserSetting.fromMap( map['setting'].cast<String, dynamic>() ),
      created = map['created'].toDate(); 

  User.fromSnapshot(DocumentSnapshot snapshot)
    : this.fromMap(snapshot.data);
}

enum RoleType {
  admin,    // 0
  customer, // 1
}

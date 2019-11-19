import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:badiup/models/user_model.dart';
import 'package:badiup/models/user_setting_model.dart';

class Admin extends User {
  Admin({
    String email,
    String name,
    RoleType role,
    UserSetting setting,
    DateTime created
  }) : super(
    email: email,
    name: name,
    role: role,
    setting: setting,
    created: created
  );

  Admin.fromMap(Map<String, dynamic> map)
    : super.fromMap(map);

  Admin.fromSnapshot(DocumentSnapshot snapshot)
    : super.fromMap(snapshot.data);
}

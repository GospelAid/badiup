import 'package:badiup/models/user_model.dart';
import 'package:badiup/models/user_setting_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Admin extends User {
  Admin({String name, RoleType role, UserSetting setting, DateTime created})
    : super(name: name, role: role, setting: setting, created: created);
  Admin.fromMap(Map<String, dynamic> map) : super.fromMap(map);
  Admin.fromSnapShot(DocumentSnapshot snapshot) : super.fromSnapshot(snapshot);
}
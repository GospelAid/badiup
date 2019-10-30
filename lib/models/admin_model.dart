import 'package:badiup/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Admin extends User {
  Admin({String email, String name, RoleType role, DocumentReference setting, DateTime created})
    : super(email: email, name: name, role: role, setting: setting, created: created);
  Admin.fromMap(Map<String, dynamic> map) : super.fromMap(map);
  Admin.fromSnapShot(DocumentSnapshot snapshot) : super.fromSnapshot(snapshot);
}
import 'package:cloud_firestore/cloud_firestore.dart';

class UserSetting {
  final bool pushNotifications;

  UserSetting({
    this.pushNotifications
  });

  Map<String, dynamic> toMap() {
    return {
      'pushNotifications': pushNotifications
    };
  }

  UserSetting.fromMap(Map<String, dynamic> map)
    : assert(map['pushNotifications'] != null),
      pushNotifications = map['pushNotifications'];

  UserSetting.fromSnapshot(DocumentSnapshot snapshot)
    : this.fromMap(snapshot.data);
}
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:badiup/models/user_setting_model.dart';
import 'package:badiup/models/user_model.dart';

class Customer extends User {
  final List<DocumentReference> shippingAddresses;

  Customer({
    String email,
    String name,
    RoleType role,
    DocumentReference setting,
    DateTime created,
    this.shippingAddresses
  }) : super(
    email: email,
    name: name,
    role: role,
    setting: setting,
    created: created
  );

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> userMap = super.toMap();
    userMap.addAll({
      'shippingAddresses': shippingAddresses
    });
    return userMap;
  }

  Future<UserSetting> getUserSetting() async {
    DocumentSnapshot snapshot = await this.setting.get();
    return UserSetting.fromSnapshot( snapshot );
  }

  Customer.fromMap(Map<String, dynamic> map)
    : shippingAddresses = map['shippingAddresses'],
    super.fromMap(map);
  
  Customer.fromSnapshot(DocumentSnapshot snapshot)
    : this.fromMap(snapshot.data);
}

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:badiup/constants.dart' as constants;
import 'package:badiup/models/user_model.dart';
import 'package:badiup/models/user_setting_model.dart';
import 'package:badiup/models/address_model.dart';

class Customer extends User {
  List<Address> shippingAddresses;

  Customer({
    String email,
    String name,
    RoleType role,
    UserSetting setting,
    DateTime created,
    this.shippingAddresses
  }) : super(
    email: email,
    name: name,
    role: role,
    setting: setting,
    created: created
  );

  Future<void> setShippingAddresses() async {
    QuerySnapshot qsnapshot =
      await Firestore.instance
        .collection( constants.DBCollections.customers )
        .document( this.email )
        .collection( constants.DBCollections.addresses )
        .getDocuments();

    this.shippingAddresses = qsnapshot.documents.map(
      (snapshot) => Address.fromSnapshot(snapshot)
    ).toList();
  }

  Customer.fromMap(Map<String, dynamic> map)
    : super.fromMap(map);

  Customer.fromSnapshot(DocumentSnapshot snapshot)
    : this.fromMap(snapshot.data);
}

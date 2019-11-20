import 'package:cloud_firestore/cloud_firestore.dart';

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
    this.shippingAddresses,
  }) : super(
    email: email,
    name: name,
    role: role,
    setting: setting,
    created: created,
  );

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> customerMap = super.toMap();
    customerMap['shippingAddresses'] = shippingAddresses.map(
        (address) => address.toMap()
    ).toList();
    return customerMap;
  }

  @override
  Customer.fromMap(Map<String, dynamic> map) : super.fromMap(map) {
    shippingAddresses = map['shippingAddresses'].map<Address>(
      (address) => Address.fromMap(address.cast<String, Address>())
    ).toList();
  }

  @override
  Customer.fromSnapshot(DocumentSnapshot snapshot)
    : this.fromMap(snapshot.data);
}

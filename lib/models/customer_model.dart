import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:badiup/models/user_model.dart';
import 'package:badiup/models/address_model.dart';

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

  Future<List<Address>> getShippingAddresses() async {
    List<Address> addresses = List<Address>();
    shippingAddresses.forEach(
      (reference) async {
        DocumentSnapshot snapshot = await reference.get();
        addresses.add( Address.fromSnapshot(snapshot) );
      }
    );
    return addresses;
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> userMap = super.toMap();
    userMap.addAll({
      'shippingAddresses': shippingAddresses
    });
    return userMap;
  }

  Customer.fromMap(Map<String, dynamic> map)
    : shippingAddresses = map['shippingAddresses'].cast<DocumentReference>(),
    super.fromMap(map);
  
  Customer.fromSnapshot(DocumentSnapshot snapshot)
    : this.fromMap(snapshot.data);
}

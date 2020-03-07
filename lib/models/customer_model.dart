import 'package:badiup/models/cart_model.dart';
import 'package:badiup/models/user_model.dart';
import 'package:badiup/models/user_setting_model.dart';
import 'package:badiup/models/address_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Customer extends User {
  List<Address> shippingAddresses;
  Cart cart;

  Customer({
    String email,
    String name,
    RoleType role,
    UserSetting setting,
    DateTime created,
    int timesOfSignIn,
    this.shippingAddresses,
  }) : super(
          email: email,
          name: name,
          role: role,
          setting: setting,
          created: created,
          timesOfSignIn: timesOfSignIn,
        );

  Address getAvailableShippingAddress() =>
      shippingAddresses.length == 0 ? Address() : shippingAddresses.first;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> customerMap = super.toMap();

    customerMap['shippingAddresses'] =
        shippingAddresses.map((address) => address.toMap()).toList();

    if (cart != null) {
      customerMap['cart'] = cart.toMap();
    }
    return customerMap;
  }

  @override
  Customer.fromMap(Map<String, dynamic> map) : super.fromMap(map) {
    shippingAddresses = map['shippingAddresses']
        .map<Address>(
            (address) => Address.fromMap(address.cast<String, dynamic>()))
        .toList();
    if (map['cart'] != null) {
      cart = Cart.fromMap(map['cart'].cast<String, dynamic>());
    }
  }

  @override
  Customer.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data);
}

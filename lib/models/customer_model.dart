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
    this.shippingAddresses,
  }) : super(
          email: email,
          name: name,
          role: role,
          setting: setting,
          created: created,
        );

  String getDefaultAddressPostcode() {
    if ( shippingAddresses.length == 0 ) return "";

    return shippingAddresses[0].postcode ?? "";
  }

  String getDefaultAddress() {
    if ( shippingAddresses.length == 0 ) return "";

    return (shippingAddresses[0].line1 ?? "") +
           (shippingAddresses[0].line2 ?? "");
  }

  String getDefaultPhoneNumber() {
    if ( shippingAddresses.length == 0 ) return "";

    return shippingAddresses[0].phoneNumber ?? "";
  }

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

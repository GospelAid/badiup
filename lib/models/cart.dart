class Cart {
  List<CartItem> items;

  Map<String, dynamic> toMap() {
    return {
      'items': items.map((item) => item.toMap()).toList(),
    };
  }

  Cart.fromMap(Map<String, dynamic> map) {
    items = map['items']
        .map<CartItem>(
            (cartItem) => CartItem.fromMap(cartItem.cast<String, CartItem>()))
        .toList();
  }
}

class CartItem {
  String productDocumentId;
  int quantity;

  Map<String, dynamic> toMap() {
    return {
      'productDocumentId': productDocumentId,
      'quantity': quantity,
    };
  }

  CartItem.fromMap(Map<String, dynamic> map)
      : assert(map['productDocumentId'] != null),
        assert(map['quantity'] != null),
        productDocumentId = map['productDocumentId'],
        quantity = map['quantity'];
}

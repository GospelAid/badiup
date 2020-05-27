import 'package:badiup/models/stock_model.dart';

class Cart {
  List<CartItem> items;

  Cart({
    this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'items': items.map((item) => item.toMap()).toList(),
    };
  }

  Cart.fromMap(Map<String, dynamic> map) {
    items = map['items'] != null
        ? map['items']
            .map<CartItem>((cartItem) =>
                CartItem.fromMap(cartItem.cast<String, dynamic>()))
            .toList()
        : [];
  }
}

class CartItem {
  String productDocumentId;
  StockItem stockRequest;

  CartItem({
    this.productDocumentId,
    this.stockRequest,
  });

  Map<String, dynamic> toMap() {
    return {
      'productDocumentId': productDocumentId,
      'stockRequest': stockRequest.toMap(),
    };
  }

  CartItem.fromMap(Map<String, dynamic> map)
      : assert(map['productDocumentId'] != null),
        productDocumentId = map['productDocumentId'],
        stockRequest = map['stockRequest'] != null
            ? StockItem.fromMap(map['stockRequest'].cast<String, dynamic>())
            : null;
}

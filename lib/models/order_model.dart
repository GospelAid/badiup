import 'package:cloud_firestore/cloud_firestore.dart';

class Order{
  final String documentId;
  final String customerId;
  final List<OrderItem> items;
  final OrderStatus status;
  final DateTime placedDate;
  final String details;
  final String trackingUrl;

  Order({
    this.documentId,
    this.customerId,
    this.items,
    this.status,
    this.placedDate,
    this.details,
    this.trackingUrl,
  });

  double getOrderPrice() {
    return items.map(
      (item) => item.price
    ).reduce( (a, b) => a + b );
  }

  String getOrderStatusText() {
    switch (status) {
      case OrderStatus.all:
        return '全て';
      case OrderStatus.pending:
        return '保留中';
      default:
        return 'その他';
    }
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'customerId': customerId,
      'status': status.index,
      'placedDate': placedDate,
      'details': details,
      'trackingUrl': trackingUrl,
    };
    map['items'] = items.map(
      (item) => item.toMap()
    ).toList();

    return map;
  }

  Order.fromMap(Map<String, dynamic> map, String documentId)
    : customerId = map['customerId'],
      status = OrderStatus.values[ map['status'] ],
      placedDate = map['placedDate'].toDate(),
      details = map['details'],
      trackingUrl = map['trackingUrl'],
      items = map['items'].map<OrderItem>(
        (item) => OrderItem.fromMap( item.cast<String, dynamic>() )
      ).toList(),
      documentId = documentId;

  Order.fromSnapshot(DocumentSnapshot snapshot)
    : this.fromMap(snapshot.data, snapshot.documentID);
}

class OrderItem{
  String productId;
  int quantity;
  double price;

  OrderItem({
    this.productId,
    this.quantity,
    this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'quantity': quantity,
      'price': price,
    };
  }

  OrderItem.fromMap(Map<String, dynamic> map)
    : assert(map['productId'] != null),
      assert(map['quantity'] != null),
      productId = map['productId'],
      quantity = map['quantity'],
      price = map['price'];
}

enum OrderStatus{
  all,
  pending,
  dispatched,
  delivered,
  cancelledByCustomer,
  deletedByAdmin,
}

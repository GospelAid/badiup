import 'package:badiup/models/address_model.dart';
import 'package:badiup/models/stock_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class Order {
  final String documentId;
  final String customerId;
  final List<OrderItem> items;
  final OrderStatus status;
  final DateTime placedDate;
  final String details;
  final String trackingUrl;
  final String orderId;
  final Address shippingAddress;

  Order({
    this.documentId,
    this.customerId,
    this.items,
    this.status,
    this.placedDate,
    this.details,
    this.trackingUrl,
    this.orderId,
    this.shippingAddress,
  });

  double getOrderPrice() {
    return items.map((item) => item.price).reduce((a, b) => a + b);
  }

  String getOrderStatusText() {
    switch (status) {
      case OrderStatus.all:
        return '全て';
      case OrderStatus.pending:
        return '未発送';
      case OrderStatus.dispatched:
        return '発送済';
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
      'orderId': orderId,
    };
    map['items'] = items.map((item) => item.toMap()).toList();
    map['shippingAddress'] = shippingAddress.toMap();

    return map;
  }

  Order.fromMap(Map<String, dynamic> map, String documentId)
      : customerId = map['customerId'],
        status = OrderStatus.values[map['status']],
        placedDate = map['placedDate'].toDate(),
        details = map['details'],
        trackingUrl = map['trackingUrl'],
        items = map['items']
            .map<OrderItem>(
                (item) => OrderItem.fromMap(item.cast<String, dynamic>()))
            .toList(),
        shippingAddress = Address.fromMap(
          map['shippingAddress'].cast<String, dynamic>()
        ),
        documentId = documentId,
        orderId = map['orderId'];

  Order.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, snapshot.documentID);

  static String generateOrderId() {
    return Uuid().v4().substring(0, 6).toUpperCase();
  }
}

class OrderItem {
  String productId;
  StockItem stockRequest;
  double price;

  OrderItem({
    this.productId,
    this.stockRequest,
    this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'stockRequest': stockRequest.toMap(),
      'price': price,
    };
  }

  OrderItem.fromMap(Map<String, dynamic> map)
      : assert(map['productId'] != null),
        productId = map['productId'],
        stockRequest = map['stockRequest'] != null
            ? StockItem.fromMap(map['stockRequest'].cast<String, dynamic>())
            : null,
        price = map['price'];
}

enum OrderStatus {
  all,
  pending,
  dispatched,
  delivered,
  cancelledByCustomer,
  deletedByAdmin,
}

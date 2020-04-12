import 'package:badiup/models/address_model.dart';
import 'package:badiup/models/stock_model.dart';
import 'package:badiup/models/tracking_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class Order {
  final String documentId;
  final String customerId;
  String pushNotificationMessage;
  final List<OrderItem> items;
  final DateTime placedDate;
  final String details;
  final String orderId;
  Address shippingAddress;
  OrderStatus status;
  DateTime dispatchedDate;
  TrackingDetails trackingDetails;
  double totalPrice;

  Order({
    this.documentId,
    this.customerId,
    this.pushNotificationMessage,
    this.items,
    this.status,
    this.placedDate,
    this.details,
    this.orderId,
    this.shippingAddress,
    this.dispatchedDate,
    this.trackingDetails,
    this.totalPrice,
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
      'pushNotificationMessage': pushNotificationMessage,
      'status': status.index,
      'placedDate': placedDate,
      'details': details,
      'orderId': orderId,
      'dispatchedDate': dispatchedDate,
      'trackingDetails':
          trackingDetails != null ? trackingDetails.toMap() : null,
      'totalPrice': totalPrice,
    };
    map['items'] = items.map((item) => item.toMap()).toList();
    map['shippingAddress'] = shippingAddress.toMap();

    return map;
  }

  Order.fromMap(Map<String, dynamic> map, String documentId)
      : customerId = map['customerId'],
        pushNotificationMessage = map['pushNotificationMessage'],
        status = OrderStatus.values[map['status']],
        placedDate = map['placedDate'].toDate(),
        details = map['details'],
        items = map['items']
            .map<OrderItem>(
                (item) => OrderItem.fromMap(item.cast<String, dynamic>()))
            .toList(),
        shippingAddress = map['shippingAddress'] != null
            ? Address.fromMap(map['shippingAddress'].cast<String, dynamic>())
            : Address(),
        trackingDetails = map['trackingDetails'] != null
            ? TrackingDetails.fromMap(
                map['trackingDetails'].cast<String, dynamic>())
            : TrackingDetails(),
        documentId = documentId,
        orderId = map['orderId'],
        dispatchedDate = map['dispatchedDate'] != null
            ? map['dispatchedDate'].toDate()
            : null,
        totalPrice = map['totalPrice'] ?? 0;

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

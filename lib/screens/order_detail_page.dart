import 'package:badiup/colors.dart';
import 'package:badiup/constants.dart' as constants;
import 'package:badiup/models/address_model.dart';
import 'package:badiup/models/customer_model.dart';
import 'package:badiup/models/order_model.dart';
import 'package:badiup/models/product_model.dart';
import 'package:badiup/models/stock_model.dart';
import 'package:badiup/models/tracking_details.dart';
import 'package:badiup/screens/admin_order_tracking_page.dart';
import 'package:badiup/sign_in.dart';
import 'package:badiup/utilities.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:transparent_image/transparent_image.dart';

class OrderDetailPage extends StatefulWidget {
  OrderDetailPage({Key key, this.orderDocumentId}) : super(key: key);

  final String orderDocumentId;

  @override
  _OrderDetailPageState createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  final currencyFormat = NumberFormat("#,##0");

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance
          .collection(constants.DBCollections.orders)
          .document(widget.orderDocumentId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        }
        var order = Order.fromSnapshot(snapshot.data);

        return Scaffold(
          appBar: _buildAppBar(context, order.orderId),
          body: _buildBody(context, order),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, String orderId) {
    return AppBar(
      title: Text(
        orderId,
        style: TextStyle(
          color: paletteBlackColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      backgroundColor: paletteLightGreyColor,
      elevation: 0.0,
      iconTheme: IconThemeData(color: paletteBlackColor),
    );
  }

  Widget _buildBody(BuildContext context, Order order) {
    return Container(
      color: paletteLightGreyColor,
      child: ListView(
        children: <Widget>[
          _buildOrderPlacedDateText(order.placedDate),
          SizedBox(height: 16.0),
          currentSignedInUser.isAdmin() &&
                  order.status != OrderStatus.dispatched
              ? _buildOrderStatusDescriptionBar(order)
              : Container(),
          Container(
            height: 56,
            color: order.status == OrderStatus.dispatched
                ? Color(0xFF688E26)
                : paletteGreyColor4,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: AlignmentDirectional.center,
            child: Text(
              _getOrderStatusDisplayText(order),
              style: TextStyle(
                color: order.status == OrderStatus.dispatched
                    ? kPaletteWhite
                    : paletteBlackColor,
              ),
            ),
          ),
          _buildOrderItemList(order.items),
          _buildOrderPriceDescriptionBar(order.totalPrice),
          SizedBox(height: 60.0),
          _buildCustomerDetails(order),
        ],
      ),
    );
  }

  String _getOrderStatusDisplayText(Order order) {
    return order.status == OrderStatus.dispatched &&
            order.trackingDetails.code != null
        ? "この商品は発送済みです。追跡番号は " + order.trackingDetails.code + " です"
        : "この商品は未発送です。";
  }

  Widget _buildOrderPlacedDateText(DateTime placedDate) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(right: 16.0),
          child: Text(
            DateFormat('yyyy.MM.dd').format(placedDate) + '受付',
            style: TextStyle(
              color: paletteBlackColor,
              fontSize: 12.0,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderStatusDescriptionBar(Order order) {
    return Container(
      child: Container(
        height: 56,
        color: paletteDarkRedColor,
        child: RaisedButton(
          color: Colors.transparent,
          onPressed: () async {
            await _updateOrder();
          },
          elevation: 0.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '未発送の商品です。追跡番号を入力する',
                style: TextStyle(
                  color: kPaletteWhite,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.launch),
            ],
          ),
        ),
      ),
    );
  }

  Future _updateOrder() async {
    TrackingDetails trackingDetails = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderTrackingDetailsPage(),
      ),
    );

    var _order = Order.fromSnapshot(await Firestore.instance
        .collection(constants.DBCollections.orders)
        .document(widget.orderDocumentId)
        .get());

    if (trackingDetails != null) {
      _order.trackingDetails = trackingDetails;
      _order.status = OrderStatus.dispatched;
      _order.dispatchedDate = DateTime.now().toUtc();

      await Firestore.instance
          .collection(constants.DBCollections.orders)
          .document(widget.orderDocumentId)
          .updateData(_order.toMap());
    }
  }

  Widget _buildOrderItemList(List<OrderItem> orderItems) {
    List<String> _orderProductIds =
        orderItems.map((orderItem) => orderItem.productId).toList();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection(constants.DBCollections.products)
            .where(FieldPath.documentId, whereIn: _orderProductIds)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return LinearProgressIndicator();
          }

          return Column(
            children: orderItems.map((orderItem) {
              DocumentSnapshot productSnapshot = snapshot.data.documents
                  .firstWhere(
                      (snapshot) => snapshot.documentID == orderItem.productId);
              return _buildOrderItemListRow(
                orderItem,
                Product.fromSnapshot(productSnapshot),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildOrderItemListRow(OrderItem orderItem, Product product) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: kPaletteBorderColor),
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _buildProductImage(product),
          _buildOrderItemTextInfo(orderItem, product),
          _buildOrderItemQuantity(orderItem, product),
        ],
      ),
    );
  }

  Widget _buildProductImage(Product product) {
    Widget productImage;
    double productImageSize = 85.0;

    if (product.imageUrls?.isEmpty ?? true) {
      productImage = Image.memory(
        kTransparentImage,
        height: productImageSize,
        width: productImageSize,
      );
    } else {
      productImage = FadeInImage.memoryNetwork(
        fit: BoxFit.cover,
        height: productImageSize,
        width: productImageSize,
        placeholder: kTransparentImage,
        image: product.imageUrls.first,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: productImage,
    );
  }

  Widget _buildOrderItemTextInfo(OrderItem orderItem, Product product) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(left: 16.0),
        height: 75,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildProductName(product),
            _buildOrderItemColorSize(orderItem, product),
            _buildOrderItemPrice(orderItem, product),
          ],
        ),
      ),
    );
  }

  Widget _buildProductName(Product product) {
    return Container(
      child: Text(
        product.name,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: paletteBlackColor,
        ),
      ),
    );
  }

  Widget _buildOrderItemColorSize(OrderItem orderItem, Product product) {
    String itemStockRequestText = "";

    if (orderItem.stockRequest.size != null) {
      itemStockRequestText +=
          getDisplayTextForItemSize(orderItem.stockRequest.size) + "サイズ";
      if (orderItem.stockRequest.color != null) {
        itemStockRequestText += "/";
      }
    }
    if (orderItem.stockRequest.color != null) {
      itemStockRequestText +=
          getDisplayTextForItemColor(orderItem.stockRequest.color);
    }

    return Container(
      child: Text(
        itemStockRequestText,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w300,
          color: paletteBlackColor,
        ),
      ),
    );
  }

  Widget _buildOrderItemPrice(OrderItem orderItem, Product product) {
    return Container(
      child: Text(
        "¥" + currencyFormat.format(orderItem.price),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: paletteBlackColor,
        ),
      ),
    );
  }

  Widget _buildOrderItemQuantity(OrderItem orderItem, Product product) {
    return Container(
      height: 85,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                color: kPaletteWhite,
                height: 30,
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  orderItem.stockRequest.quantity.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: paletteBlackColor,
                  ),
                ),
              ),
              Text(
                ' 点',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: paletteBlackColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderPriceDescriptionBar(double orderPrice) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      height: 40,
      child: Container(
        color: kPaletteWhite,
        padding: EdgeInsets.symmetric(horizontal: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: Text(
                '総合計',
                style: TextStyle(
                  color: paletteBlackColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              child: Text(
                "¥" + currencyFormat.format(orderPrice),
                style: TextStyle(
                  color: paletteDarkRedColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerDetails(Order order) {
    return Container(
      decoration: BoxDecoration(
        color: kPaletteWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: StreamBuilder<DocumentSnapshot>(
        stream: Firestore.instance
            .collection(constants.DBCollections.users)
            .document(order.customerId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return LinearProgressIndicator();
          }
          Customer _customer = Customer.fromSnapshot(snapshot.data);
          return Column(
            children: <Widget>[
              _buildGreyBar(),
              _buildBillingAddressInfoBox(_customer, order),
              _buildShippingAddressInfoBox(_customer, order),
              _buildPaymentMethodInfoBox(order.paymentMethod),
              order.status == OrderStatus.dispatched
                  ? _buildShippingMethodInfoBox(order)
                  : Container(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPaymentMethodInfoBox(PaymentOption paymentMethod) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: kPaletteBorderColor),
        ),
      ),
      padding: EdgeInsets.only(
        top: 12.0,
        left: 24.0,
        right: 24.0,
        bottom: 50.0,
      ),
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            child: Text(
              "支払い方法",
              style: TextStyle(
                fontSize: 18,
                color: paletteBlackColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 25.0),
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              _getPaymentMethodDisplayText(paymentMethod),
              style: TextStyle(
                fontSize: 16,
                color: paletteBlackColor,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPaymentMethodDisplayText(PaymentOption paymentMethod) {
    switch (paymentMethod) {
      case PaymentOption.card:
        return 'クレジットカード';
      case PaymentOption.furikomi:
        return '振り込み';
      default:
    }
    return null;
  }

  Widget _buildGreyBar() {
    return Container(
      padding: EdgeInsets.only(top: 24.0),
      child: Container(
        decoration: BoxDecoration(
          color: paletteGreyColor4,
          borderRadius: BorderRadius.all(Radius.circular(40)),
        ),
        height: 8,
        width: 115,
      ),
    );
  }

  Widget _buildBillingAddressInfoBox(Customer customer, Order order) {
    return Container(
      padding:
          EdgeInsets.only(top: 12.0, left: 24.0, right: 24.0, bottom: 36.0),
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            child: Text(
              "注文者情報",
              style: TextStyle(
                fontSize: 18,
                color: paletteBlackColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 24.0),
          _buildCustomerName(customer),
          SizedBox(height: 12.0),
          _buildBillingAddress(order),
          SizedBox(height: 6.0),
          _buildCustomerPhoneNumber(
            customer,
            order.shippingAddress.phoneNumber,
          ),
          SizedBox(height: 6.0),
          _buildCustomerEmailAddress(customer),
        ],
      ),
    );
  }

  Widget _buildCustomerName(Customer customer) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Row(
        children: <Widget>[
          Text(
            customer.name,
            style: TextStyle(
              fontSize: 16,
              color: paletteBlackColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            " 様",
            style: TextStyle(
              fontSize: 16,
              color: paletteBlackColor,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressRow(Address address) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "住所",
            style: TextStyle(
              fontSize: 16,
              color: paletteBlackColor,
              fontWeight: FontWeight.w300,
            ),
          ),
          SizedBox(width: 30.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "〒 " + (address.postcode ?? ""),
                  style: TextStyle(
                    fontSize: 16,
                    color: paletteBlackColor,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Text(
                  (address.line1 ?? "") + (address.line2 ?? ""),
                  style: TextStyle(
                    fontSize: 16,
                    color: paletteBlackColor,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingAddress(Order order) =>
      _buildAddressRow(order.billingAddress);

  Widget _buildCustomerPhoneNumber(Customer customer, String phoneNumber) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(top: 6.0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: paletteGreyColor4),
        ),
      ),
      child: Row(
        children: <Widget>[
          Text(
            "連絡先",
            style: TextStyle(
              fontSize: 16,
              color: paletteBlackColor,
              fontWeight: FontWeight.w300,
            ),
          ),
          SizedBox(width: 16.0),
          Text(
            phoneNumber ?? "",
            style: TextStyle(
              fontSize: 16,
              color: paletteBlackColor,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerEmailAddress(Customer customer) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(top: 6.0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: paletteGreyColor4),
        ),
      ),
      child: Row(
        children: <Widget>[
          Text(
            "メール",
            style: TextStyle(
              fontSize: 16,
              color: paletteBlackColor,
              fontWeight: FontWeight.w300,
            ),
          ),
          SizedBox(width: 16.0),
          Expanded(
            child: Text(
              customer.email,
              style: TextStyle(
                fontSize: 16,
                color: paletteBlackColor,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingAddressInfoBox(Customer customer, Order order) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: kPaletteBorderColor),
          bottom: BorderSide(color: kPaletteBorderColor),
        ),
      ),
      padding:
          EdgeInsets.only(top: 12.0, left: 24.0, right: 24.0, bottom: 36.0),
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            child: Text(
              "お届け先",
              style: TextStyle(
                fontSize: 18,
                color: paletteBlackColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 24.0),
          _buildCustomerName(customer),
          SizedBox(height: 12.0),
          _buildShippingAddress(order.shippingAddress),
        ],
      ),
    );
  }

  Widget _buildShippingAddress(Address shippingAddress) =>
      _buildAddressRow(shippingAddress);

  Widget _buildShippingMethodInfoBox(Order order) {
    return Container(
      padding:
          EdgeInsets.only(top: 12.0, left: 24.0, right: 24.0, bottom: 50.0),
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            child: Text(
              "配送方法",
              style: TextStyle(
                fontSize: 18,
                color: paletteBlackColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 25.0),
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              getDisplayTextForDeliveryMethod(
                order.trackingDetails.deliveryMethod,
              ),
              style: TextStyle(
                fontSize: 16,
                color: paletteBlackColor,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

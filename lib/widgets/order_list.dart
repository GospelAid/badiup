import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:intl/intl.dart';
import 'package:badiup/screens/admin_order_detail_page.dart';
import 'package:badiup/colors.dart';
import 'package:badiup/constants.dart' as constants;
import 'package:badiup/models/order_model.dart';

class OrderList extends StatefulWidget {
  OrderList({Key key, this.orderStatusToFilter}) : super(key: key);

  final OrderStatus orderStatusToFilter;

  @override
  _OrderListState createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection(constants.DBCollections.orders)
          .orderBy('placedDate', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        }

        return _buildOrderList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildOrderList(
    BuildContext context,
    List<DocumentSnapshot> snapshots,
  ) {
    List<Widget> widgetList = [];
    snapshots.forEach((snapshot) {
      final Order order = Order.fromSnapshot(snapshot);
      if (widget.orderStatusToFilter == OrderStatus.all ||
          order.status == widget.orderStatusToFilter) {
        widgetList.add(_buildOrderListItem(context, order));
      }
    });

    return ListView(
      children: widgetList,
    );
  }

  Widget _buildOrderListItem(BuildContext context, Order order) {
    return Container(
      padding: EdgeInsets.only(bottom: 12.0),
      child: Stack(
        alignment: AlignmentDirectional.bottomEnd,
        children: <Widget>[
          Container(
            height: 73.0,
            decoration: BoxDecoration(
              color: kPaletteWhite,
            ),
            child: _buildOrderListTile(order),
          ),
          _buildOrderStatus(order),
        ],
      ),
    );
  }

  Widget _buildOrderStatus(Order order) {
    return Container(
      height: 20,
      width: 50,
      decoration: BoxDecoration(
        color: Color(0xFFEFEFEF),
      ),
      child: Center(
        child: Text(
          order.getOrderStatusText(),
          style: TextStyle(
            color: paletteForegroundColor,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderListTile(Order order) {
    return ListTile(
      title: _buildOrderId(order),
      subtitle: _buildOrderPrice(order),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          _buildOrderPlacedDate(order),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminOrderDetailPage(order: order),
          ),
        );
      },
    );
  }

  Widget _buildOrderPlacedDate(Order order) {
    return Padding(
      padding: EdgeInsets.only(top: 4),
      child: Text(
        DateFormat('yyyy.MM.dd').format(order.placedDate),
        style: TextStyle(
          fontSize: 12,
          color: paletteBlackColor,
        ),
      ),
    );
  }

  Widget _buildOrderPrice(Order order) {
    final currencyFormat = NumberFormat("#,##0");

    return Row(
      children: <Widget>[
        Text(
          "¥${currencyFormat.format(order.getOrderPrice())}",
          style: TextStyle(
            fontSize: 20,
            color: paletteDarkRedColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "（税込）",
          style: TextStyle(
            color: paletteBlackColor,
            fontSize: 14.0,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderId(Order order) {
    return Padding(
      padding: EdgeInsets.only(top: 16),
      child: Text(
        order.orderId,
        style: TextStyle(
          fontSize: 12,
          color: paletteBlackColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

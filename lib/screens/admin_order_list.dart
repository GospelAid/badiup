import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:intl/intl.dart';
import 'package:badiup/colors.dart';
import 'package:badiup/constants.dart' as constants;
import 'package:badiup/models/order_model.dart';

class AdminOrderList extends StatefulWidget {
  AdminOrderList({Key key, this.orderStatusToFilter}) : super(key: key);

  final OrderStatus orderStatusToFilter;

  @override
  _AdminOrderListState createState() => _AdminOrderListState();
}

class _AdminOrderListState extends State<AdminOrderList> {
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
      padding: EdgeInsets.only(bottom: 16.0),
      child: Container(
        height: 73.0,
        decoration: BoxDecoration(
          color: kPaletteWhite,
          borderRadius: BorderRadius.circular(0.0),
        ),
        child: _buildOrderListTile(order),
      ),
    );
  }

  Widget _buildOrderListTile(Order order) {
    return ListTile(
      title: _buildOrderTitle(order),
      subtitle: _buildOrderSubtitle(order),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          _buildOrderPlacedDate(order),
          _buildOrderStatus(order),
        ],
      ),
      onTap: () {},
    );
  }

  Widget _buildOrderStatus(Order order) {
    return Text(
      order.getOrderStatusText(),
      style: TextStyle(
        fontSize: 10,
        color: paletteDarkRedColor,
      ),
    );
  }

  Widget _buildOrderPlacedDate(Order order) {
    return Text(
      DateFormat('yyyy年MM月dd日').format(order.placedDate),
      style: TextStyle(
        fontSize: 14,
        color: paletteBlackColor,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildOrderSubtitle(Order order) {
    return Text(
      order.getOrderPrice().toString(),
      style: TextStyle(
        fontSize: 18,
        color: paletteDarkRedColor,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildOrderTitle(Order order) {
    return Text(
      order.orderId,
      style: TextStyle(
        fontSize: 10,
        color: paletteBlackColor,
      ),
    );
  }
}

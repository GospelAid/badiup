import 'package:badiup/colors.dart';
import 'package:badiup/constants.dart' as constants;
import 'package:badiup/models/order_model.dart';
import 'package:badiup/screens/order_detail_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderList extends StatefulWidget {
  OrderList({
    Key key,
    this.orderStatusToFilter,
    this.placedByFilter,
    this.placedDateStartFilter,
    this.placedDateEndFilter,
  }) : super(key: key);

  final OrderStatus orderStatusToFilter;
  final String placedByFilter;
  final DateTime placedDateStartFilter;
  final DateTime placedDateEndFilter;

  @override
  _OrderListState createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection(constants.DBCollections.orders)
          .orderBy(getSortByFilter(), descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }

        return _buildOrderList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildEmptyOrders() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: kPaletteWhite,
              borderRadius: BorderRadius.all(Radius.circular(6)),
              boxShadow: [
                BoxShadow(
                  color: paletteDialogShadowColor.withOpacity(0.10),
                  blurRadius: 30.0,
                  spreadRadius: 0.0,
                  offset: Offset(0.0, 30.0),
                ),
              ],
            ),
            child: _buildNoOrdersDialogInternal(),
          ),
        ),
      ],
    );
  }

  Widget _buildNoOrdersDialogInternal() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            "注文履歴はありません",
            style: TextStyle(
              color: paletteForegroundColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          Text(
            "ぜひお買い物をお楽しみください。\nご利用をお待ちしております。",
            style: TextStyle(color: paletteBlackColor),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  Widget _buildOrderList(
    BuildContext context,
    List<DocumentSnapshot> snapshots,
  ) {
    List<Widget> widgetList = [];
    snapshots.forEach((snapshot) {
      var order = Order.fromSnapshot(snapshot);

      bool shouldDisplay = true;

      shouldDisplay = shouldDisplay &&
          (widget.orderStatusToFilter == null ||
              widget.orderStatusToFilter == OrderStatus.all ||
              widget.orderStatusToFilter == order.status);

      shouldDisplay = shouldDisplay &&
          (widget.placedByFilter == null ||
              widget.placedByFilter == order.customerId);

      shouldDisplay = shouldDisplay &&
          (widget.placedDateStartFilter == null ||
              widget.placedDateStartFilter.isBefore(order.placedDate));

      shouldDisplay = shouldDisplay &&
          (widget.placedDateEndFilter == null ||
              widget.placedDateEndFilter.isAfter(order.placedDate));

      if (shouldDisplay) {
        widgetList.add(_buildOrderListItem(
          context,
          order,
        ));
      }
    });

    return widgetList.length != 0
        ? ListView(
            children: widgetList,
          )
        : _buildEmptyOrders();
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
      height: 24,
      width: 52,
      decoration: BoxDecoration(
        color: order.status == OrderStatus.dispatched
            ? paletteRoseColor
            : paletteGreyColor4,
      ),
      child: Center(
        child: Text(
          order.getOrderStatusText(),
          style: TextStyle(
            color: order.status == OrderStatus.dispatched
                ? paletteForegroundColor
                : paletteBlackColor,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderListTile(Order order) {
    return ListTile(
      title: _buildCustomerName(order),
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
            builder: (context) => OrderDetailPage(
              orderDocumentId: order.documentId,
            ),
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
          "¥${currencyFormat.format(order.totalPrice)}",
          style: TextStyle(
            fontSize: 16,
            color: paletteDarkRedColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "（税込）",
          style: TextStyle(
            color: paletteBlackColor,
            fontSize: 12.0,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerName(Order order) {
    return Text(
      order.billingAddress.recipientName,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 18,
        color: paletteBlackColor,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  String getSortByFilter() {
    if (widget.orderStatusToFilter == OrderStatus.dispatched) {
      return 'dispatchedDate';
    } else {
      return 'placedDate';
    }
  }
}

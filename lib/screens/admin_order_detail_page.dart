import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:intl/intl.dart';
import 'package:badiup/colors.dart';
import 'package:badiup/models/order_model.dart';

class AdminOrderDetailPage extends StatefulWidget {
  AdminOrderDetailPage({Key key, this.order}) : super(key: key);

  final Order order;

  @override
  _AdminOrderDetailPageState createState() => _AdminOrderDetailPageState();
}

class _AdminOrderDetailPageState extends State<AdminOrderDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        widget.order.orderId,
        style: TextStyle(
          color: paletteBlackColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        )
      ),
      centerTitle: true,
      backgroundColor: paletteLightGreyColor,
      elevation: 0.0,
      iconTheme: IconThemeData(color: paletteBlackColor),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      color: paletteLightGreyColor,
      child: Column(
        children: <Widget>[
          _buildOrderPlacedDateText(),
          _buildOrderStatusDescriptionBar(),
          _buildOrderItemList(),
          _buildOrderPriceDescriptionBar(),
        ],
      ),
    );
  }

  Widget _buildOrderPlacedDateText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only( right: 16.0 ),
          child: Text(
            DateFormat('yyyy.MM.dd').format(widget.order.placedDate) + '受付',
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

  Widget _buildOrderStatusDescriptionBar() {
    return Container(
      padding: EdgeInsets.symmetric( vertical: 8.0 ),
      child: Container(
        height: 56,
        color: widget.order.status == 
            OrderStatus.pending ? paletteDarkRedColor: paletteDarkGreyColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              widget.order.getOrderStatusText(),
              style: TextStyle(
                color: kPaletteWhite,
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemList() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Expanded(
          //   child: ListView(
          //     children: <Widget>[],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildOrderPriceDescriptionBar() {
    return Container(
      padding: EdgeInsets.symmetric( horizontal: 16.0 ),
      height: 40.0,
      child: Container(
        color: kPaletteWhite,
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
                widget.order.getOrderPrice().toString(),
                style: TextStyle(
                  color: paletteDarkRedColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        )
      ),
    );
  }

}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:badiup/colors.dart';
import 'package:badiup/constants.dart' as constants;
import 'package:badiup/models/order_model.dart';

class AdminOrderList extends StatefulWidget {
  AdminOrderList({Key key, this.orderStatusToSearch}) : super(key: key);
  
  final OrderStatus orderStatusToSearch;

  @override
  _AdminOrderListState createState() => _AdminOrderListState();
}

class _AdminOrderListState extends State<AdminOrderList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
              .collection( constants.DBCollections.orders )
              .where('status', isEqualTo: widget.orderStatusToSearch.index )
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildOrderList(context, snapshot.data.documents);
      }
    );
  }

  Widget _buildOrderList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      children: snapshot.map(
        (data) => _buildOrderListItem(context, data)
      ).toList(),
    );
  }

  Widget _buildOrderListItem(BuildContext context, DocumentSnapshot data) {
    final Order order = Order.fromSnapshot(data);
    double orderPrice = order.items.map(
      (item) => item.price
    ).reduce( (a, b) => a + b );

    return Container(
      padding: EdgeInsets.only( bottom: 16.0 ),
      child: Container(
        height: 73.0,
        decoration: BoxDecoration(
          color: kPaletteWhite,
          borderRadius: BorderRadius.circular(0.0),
        ),
        child: ListTile(
          title: Text(
            order.trackingUrl,
            style: TextStyle( fontSize: 10, color: paletteBlackColor, ),
          ),
          subtitle: Text(
            orderPrice.toString(),
            style: TextStyle( fontSize: 18, color: paletteDarkRedColor, fontWeight: FontWeight.bold),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                order.placedDate.toString(),
                style: TextStyle( fontSize: 14, color: paletteBlackColor, fontWeight: FontWeight.bold),
              ),
              Text(
                order.status.toString(),
                style: TextStyle( fontSize: 10, color: paletteDarkRedColor, ),
              ),
            ],
          ),
          onTap: () {},
        ),
      ),
    );
  }
}

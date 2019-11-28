import 'package:badiup/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final dummySnapshot = [
  { 'id': '#12345', 'price': '¥6,000', 'time': '2019年10月17日', 'status': '保留中' },
  { 'id': '#12345', 'price': '¥6,000', 'time': '2019年10月17日', 'status': '保留中' },
  { 'id': '#12345', 'price': '¥6,000', 'time': '2019年10月17日', 'status': '保留中' },
  { 'id': '#12345', 'price': '¥6,000', 'time': '2019年10月17日', 'status': '保留中' },
  { 'id': '#12345', 'price': '¥6,000', 'time': '2019年10月17日', 'status': '保留中' },
  { 'id': '#12345', 'price': '¥6,000', 'time': '2019年10月17日', 'status': '保留中' },
  { 'id': '#12345', 'price': '¥6,000', 'time': '2019年10月17日', 'status': '保留中' },
  { 'id': '#12345', 'price': '¥6,000', 'time': '2019年10月17日', 'status': '保留中' },
  { 'id': '#12345', 'price': '¥6,000', 'time': '2019年10月17日', 'status': '保留中' },
  { 'id': '#12345', 'price': '¥6,000', 'time': '2019年10月17日', 'status': '保留中' },
  { 'id': '#12345', 'price': '¥6,000', 'time': '2019年10月17日', 'status': '保留中' },
];

class AdminOrderList extends StatefulWidget {
  @override
  _AdminOrderListState createState() => _AdminOrderListState();
}

class _AdminOrderListState extends State<AdminOrderList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: _buildOrderList(context, dummySnapshot),
    );
  }

  Widget _buildOrderList(BuildContext context, List<Map> snapshot) {
    return ListView(
      children: snapshot.map(
        (data) => _buildOrderListItem(context, data)
      ).toList(),
    );
  }

  Widget _buildOrderListItem(BuildContext context, Map data) {
    final record = Record.fromMap(data);

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
            record.id,
            style: TextStyle( fontSize: 10, color: paletteBlackColor, ),
          ),
          subtitle: Text(
            record.price,
            style: TextStyle( fontSize: 18, color: paletteDarkRedColor, fontWeight: FontWeight.bold),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                record.time,
                style: TextStyle( fontSize: 14, color: paletteBlackColor, fontWeight: FontWeight.bold),
              ),
              Text(
                record.status,
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

class Record {
 final String id;
 final String price;
 final String time;
 final String status;

 Record.fromMap(Map<String, dynamic> map)
  : id = map['id'],
    price = map['price'],
    time = map['time'],
    status = map['status'];

 Record.fromSnapshot(DocumentSnapshot snapshot)
   : this.fromMap(snapshot.data);
}

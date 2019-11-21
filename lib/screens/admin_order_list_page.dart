import 'package:flutter/material.dart';

class AdminOrderListPage extends StatefulWidget {
  @override
  _AdminOrderListPageState createState() => _AdminOrderListPageState();
}

class _AdminOrderListPageState extends State<AdminOrderListPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric( horizontal: 16 ),
      color: Color(0xFFD2D1D1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '注文',
            style: TextStyle( fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF151515)),
          ),
          Row(
            children: <Widget>[
              RaisedButton(
                color: Color(0xFFFFFFFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Container(
                  child: Text(
                    '全て',
                    style: TextStyle( fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF151515)),
                  ),
                ),
                onPressed: () {},
              ),
              RaisedButton(
                color: Color(0xFFFFFFFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Container(
                  child: Text(
                    '保留中',
                    style: TextStyle( fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF151515)),
                  ),
                ),
                onPressed: () {},
              ),
            ],
          ),
          Container(
            height: 400, 
            child: _buildOrderList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, int index) {
        return Card(
          child: ListTile(
            leading: Icon(Icons.album),
            title: Text('The Enchanted Nightingale'),
            subtitle: Text(
              'Music by Julie Gable. Lyrics by Sidney Stein.',
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderListTile() {
    return ListTile(
      title: Text('a list tile'),
    );
  }
}
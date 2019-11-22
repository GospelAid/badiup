import 'package:flutter/material.dart';

import 'package:badiup/screens/admin_main_menu.dart';
import 'package:badiup/screens/admin_order_list.dart';

class AdminHomePage extends StatefulWidget {
  AdminHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      drawer: _buildDrawer(context),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return SizedBox(
      width: width * 0.7,
      child: Drawer(
        child: AdminMainMenu(),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'ホーム',
        style: TextStyle(
          color: Color(0xFF151515),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        )
      ),
      centerTitle: true,
      backgroundColor: Color(0xFFD2D1D1),
      elevation: 0.0,
      iconTheme: new IconThemeData( color: Color(0xFF151515) ),
      leading: IconButton(
        icon: Icon(Icons.menu),
        onPressed: () => _scaffoldKey.currentState.openDrawer(),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.close),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric( horizontal: 16.0 ),
      color: Color(0xFFD2D1D1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric( vertical: 8 ),
            child: Text(
              '注文',
              style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF151515),
              ),
            ),
          ),
          Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only( right: 16.0 ),
                child: _buildAllOrdersButton(context)
              ),
              Container(
                child: _buildPendingOrdersButton(context),
              ),
            ],
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only( top: 16.0 ),
              child: AdminOrderList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllOrdersButton(BuildContext context) {
    return RaisedButton(
      elevation: 0.0,
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
    );
  }

  Widget _buildPendingOrdersButton(BuildContext context) {
    return RaisedButton(
      elevation: 0.0,
      color: Color(0xFFFFFFFF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      child: Container(
        child: Text(
          '保留中',
          style: TextStyle( fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF151515)),
        ),
      ),
      onPressed: () {},
    );
  }
}

import 'package:flutter/material.dart';
import 'package:badiup/colors.dart';

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

  bool allOrdersButtonSelected = true;
  bool pendingOrdersButtonSelected = false;

  //Color unselectedButtonColor TextStyle( fontSize: 14, fontWeight: FontWeight.bold, color: paletteBlackColor )

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
          color: paletteBlackColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        )
      ),
      centerTitle: true,
      backgroundColor: paletteLightGreyColor,
      elevation: 0.0,
      iconTheme: IconThemeData( color: paletteBlackColor ),
      leading: IconButton(
        icon: Icon(Icons.menu),
        onPressed: () => _scaffoldKey.currentState.openDrawer(),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric( horizontal: 16.0 ),
      color: paletteLightGreyColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded (
                child: Text(
                  '注文',
                  style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold, color: paletteBlackColor,
                  ),
                ),
              ),
              Expanded(
                child: Container (
                  height: 35.0,
                  padding: EdgeInsets.only( left: 16 ),
                  child: _buildAllOrdersButton(context)
                ),
              ),
              Expanded(
                child: Container(
                  height: 35.0,
                  padding: EdgeInsets.only( left: 16 ),
                  child: _buildPendingOrdersButton(context),
                ),
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
      key: Key('all_orders_button'),
      elevation: 0.0,
      color: allOrdersButtonSelected ? paletteDarkRedColor : kPaletteWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      child: Container(
        child: Text(
          '全て',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: allOrdersButtonSelected ? kPaletteWhite : paletteBlackColor
          ),
        ),
      ),
      onPressed: () {
        setState(() {
          allOrdersButtonSelected = true;
          pendingOrdersButtonSelected = false;
        });
      },
    );
  }

  Widget _buildPendingOrdersButton(BuildContext context) {
    return RaisedButton(
      key: Key('pending_orders_button'),
      elevation: 0.0,
      color: pendingOrdersButtonSelected ? paletteDarkRedColor : kPaletteWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      child: Container(
        child: Text(
          '保留中',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: pendingOrdersButtonSelected ? kPaletteWhite : paletteBlackColor
          ),
        ),
      ),
      onPressed: () {
        setState(() {
          allOrdersButtonSelected = false;
          pendingOrdersButtonSelected = true;
        });
      },
    );
  }
}

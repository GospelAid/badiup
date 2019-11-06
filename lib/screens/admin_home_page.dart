import 'package:flutter/material.dart';

import 'package:badiup/colors.dart';
import 'package:badiup/screens/admin_product_listing_page.dart';

class AdminHomePage extends StatefulWidget {
  AdminHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Center(
        child: Text('ADMIN HOME PAGE : ORDERS'),
      ),
      drawer: _buildDrawer(),
    );
  }

  Drawer _buildDrawer() {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    return Drawer(
      key: scaffoldKey,
      child: ListView(
        children: <Widget>[
          _buildDrawerHeader(),
          _buildDrawerProductsTile(),
        ],
      ),
    );
  }

  ListTile _buildDrawerProductsTile() {
    return ListTile(
          title: Text('Products'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdminProductListingPage(),
              ),
            );
          },
        );
  }

  DrawerHeader _buildDrawerHeader() {
    return DrawerHeader(
      child: Center(
        child: Text(
          'Welcome!',
          style: TextStyle(
            color: kPaletteWhite,
          ),
        ),
      ),
      decoration: BoxDecoration(
        color: kPaletteDeepPurple,
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text("BADI UP"),
      centerTitle: true,
    );
  }
}

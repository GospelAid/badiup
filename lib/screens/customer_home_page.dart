import 'package:flutter/material.dart';

import 'package:badiup/widgets/main_menu.dart';
import 'package:badiup/widgets/product_listing.dart';

class CustomerHomePage extends StatefulWidget {
  CustomerHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _CustomerHomePageState createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: ProductListing(),
      drawer: _buildDrawer(),
    );
  }

  Widget _buildDrawer() {
    double width = MediaQuery.of(context).size.width;
    final scaffoldKey = GlobalKey<ScaffoldState>();
    return SizedBox(
      width: width * 0.7,
      child: Drawer(
        key: scaffoldKey,
        child: MainMenu(),
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

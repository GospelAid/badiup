import 'package:badiup/screens/customer_main_menu.dart';
import 'package:flutter/material.dart';

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
      body: Center(
        child: Text('CUSTOMER HOME PAGE : Product list'),
      ),
      drawer: _buildDrawer(),
    );
  }

  Drawer _buildDrawer() {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    return Drawer(
      key: scaffoldKey,
      child: CustomerMainMenu(),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text("BADI UP"),
      centerTitle: true,
    );
  }
}

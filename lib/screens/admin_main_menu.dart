import 'package:flutter/material.dart';

import 'package:badiup/screens/admin_product_listing_page.dart';
import 'package:badiup/screens/login_page.dart';
import 'package:badiup/sign_in.dart';

class AdminMainMenu extends StatefulWidget {
  @override
  _AdminMainMenuState createState() => _AdminMainMenuState();
}

class _AdminMainMenuState extends State<AdminMainMenu> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        _buildAccountsDrawerHeader(context),
        _buildDrawerProductsButton(context),
        _buildDrawerSettingsButton(context),
        Divider(),
        _buildDrawerLogoutButton(context),
      ],
    );
  }

  Widget _buildDrawerSettingsButton(BuildContext context) {
    return FlatButton(
      onPressed: () {},
      child: Text('Settings'),
    );
  }

  Widget _buildDrawerProductsButton(BuildContext context) {
    return FlatButton (
      child: Text('Products'),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminProductListingPage(),
          ),
        );
      },
    );
  }

  Widget _buildDrawerLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric( horizontal: 16.0, ),
      child: RaisedButton(
        onPressed: () {
          signOutGoogle();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) {
                return LoginPage();
              }
            ),
            ModalRoute.withName('/')
          );
        },
        child: Text('Logout'),
      ),
    );
  }

  Widget _buildAccountsDrawerHeader(BuildContext context) {
    return UserAccountsDrawerHeader(
      currentAccountPicture: CircleAvatar(
        child: Text(
          currentSignedInUser.name[0],
          style: TextStyle( fontSize: 40.0 ),
        ),
      ),
      accountName: Text(
        currentSignedInUser.name,
        style: TextStyle( fontSize: 20.0, fontWeight: FontWeight.w700),
      ),
      accountEmail: Text(
        currentSignedInUser.email,
        style: TextStyle( fontSize: 15.0 ) 
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
    );
  }
}

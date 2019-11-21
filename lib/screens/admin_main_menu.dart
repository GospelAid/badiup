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
    return Container(
      color: Color(0xFF151515),
      child: ListView(
        children: <Widget>[
          _buildDrawerHeader(context),
          Container(
            padding: EdgeInsets.only( left: 12.0 ),
            child: _buildDrawerProductTile(context),
          ),
          Container(
            padding: EdgeInsets.only( left: 12.0 ),
            child: _buildDrawerSettingsTile(context),
          ),
          Container(
            padding: EdgeInsets.only( left: 12.0 ),
            child: _buildDrawerLogoutTile(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerProductTile(BuildContext context) {
    return ListTile(
      leading: Icon( Icons.image, color: Color(0xFFFFFFFF) ),
      title: Text(
        '商品',
        textAlign: TextAlign.justify,
        style: TextStyle( fontSize: 14, color: Color(0xFFFFFFFF), fontWeight: FontWeight.bold ),
      ),
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

  Widget _buildDrawerSettingsTile(BuildContext context) {
    return ListTile(
      leading: Icon( Icons.settings, color: Color(0xFFFFFFFF) ),
      title: Text(
        '設定',
        textAlign: TextAlign.justify,
        style: TextStyle( fontSize: 14, color: Color(0xFFFFFFFF), fontWeight: FontWeight.bold ),
      ),
      onTap: () {
      },
    );
  }

  Widget _buildDrawerLogoutTile(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.exit_to_app, color: Color(0xFF151515) ),
      title: Text(
        'ログアウト',
        textAlign: TextAlign.justify,
        style: TextStyle( fontSize: 14, color: Color(0xFFFFFFFF), fontWeight: FontWeight.bold ),
      ),
      onTap: () {
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
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Container(
      height: 104,
      child: DrawerHeader(
        decoration: _buildDrawerHeaderDecoration(context),
        child: Container(
          padding: EdgeInsets.only( top: 16.0, bottom: 16.0 ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only( left: 16.0, right: 16.0 ),
                child: _buildDrawerHeaderAvatar(context),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildDrawerHeaderAccountInfo(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDrawerHeaderAccountInfo(BuildContext context) {
    return <Widget>[
      Text(
        currentSignedInUser.name,
        style: TextStyle(
          color: Color(0xFFFFFFFF),
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      Text(
        currentSignedInUser.email,
        style: TextStyle(
          color: Color(0xFFFFFFFF),
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    ];
  }

  BoxDecoration _buildDrawerHeaderDecoration(BuildContext context) {
    return BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/drawer_header_background.jpg'),
        fit: BoxFit.fitWidth,
      ),
    );
  }

  Widget _buildDrawerHeaderAvatar(BuildContext context) {
    return CircleAvatar(
      child: Icon(Icons.person),
      foregroundColor: Color(0xFFFFFFFF),
      backgroundColor: Color(0xFF151515),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:badiup/screens/login_page.dart';
import 'package:badiup/sign_in.dart';

class CustomerMainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
        children: <Widget>[
          _buildAccountsDrawerHeader(context),
          FlatButton(
            onPressed: () {},
            child: Text('My Orders'),
          ),
          FlatButton(
            onPressed: () {},
            child: Text('Settings'),
          ),
          Divider(),
          _buildLogoutButton(context),
        ],
      );
  }

  Widget _buildLogoutButton(BuildContext context) {
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

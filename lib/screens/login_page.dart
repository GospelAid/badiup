import 'package:flutter/material.dart';

import 'package:badiup/sign_in.dart';
import 'package:badiup/screens/admin_home_page.dart';
import 'package:badiup/screens/customer_home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: _buildBackgroundDecoration(context),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 150),
              _buildLoginButton(),
            ],
          ),
        ],
      ),
    );
  }

  BoxDecoration _buildBackgroundDecoration(BuildContext context) {
    return BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/login_background.jpg'),
        fit: BoxFit.fill,
      ),
    );
  }

  Widget _buildLoginButton() {
    return RaisedButton(
      onPressed: () {
        signInWithGoogle().whenComplete(() {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return currentSignedInUser.isAdmin() ?
                  AdminHomePage(title: 'BADI UP') : CustomerHomePage(title: 'BADI UP');
              },
            ),
          );
        });
      },
      color: Color(0xFF151515),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      highlightElevation: 100,
      child: Container(
        padding: EdgeInsets.symmetric( horizontal: 20, vertical: 10 ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image(
              image: AssetImage("assets/google_logo.png"),
              height: 20,
            ),
            Container(
              padding: EdgeInsets.only( left: 15 ),
              child: Text(
                'Login with Google',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD2D1D1),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

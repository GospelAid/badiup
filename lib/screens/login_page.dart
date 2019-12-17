import 'package:badiup/colors.dart';
import 'package:badiup/screens/admin_home_page.dart';
import 'package:badiup/screens/customer_home_page.dart';
import 'package:badiup/sign_in.dart';
import 'package:badiup/test_keys.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _loginInProgress = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loginInProgress
          ? LinearProgressIndicator()
          : Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Container(
                  decoration: _buildBackgroundDecoration(context),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 150),
                    _buildLoginButton(context),
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

  Widget _buildLoginButton(BuildContext context) {
    return RaisedButton(
      key: Key(makeTestKeyString(TKUsers.user, TKScreens.login, "loginButton")),
      onPressed: () => _doLogin(context),
      color: paletteBlackColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      highlightElevation: 100,
      child: _buildLoginButtonInternal(),
    );
  }

  void _doLogin(BuildContext context) {
    setState(() {
      _loginInProgress = true;
    });
    
    signInWithGoogle().whenComplete(() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return currentSignedInUser.isAdmin()
                ? AdminHomePage(title: 'BADI UP')
                : CustomerHomePage(title: 'BADI UP');
          },
        ),
      );
    
      setState(() {
        _loginInProgress = false;
      });
    });
  }

  Widget _buildLoginButtonInternal() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Image(
            image: AssetImage("assets/google_logo.png"),
            height: 20,
          ),
          Container(
            padding: EdgeInsets.only(left: 15),
            child: Text(
              'Login with Google',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: paletteLightGreyColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

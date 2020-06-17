import 'dart:io';

import 'package:apple_sign_in/apple_sign_in_button.dart';
import 'package:badiup/colors.dart';
import 'package:badiup/screens/admin_home_page.dart';
import 'package:badiup/screens/customer_home_page.dart';
import 'package:badiup/sign_in.dart';
import 'package:badiup/test_keys.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _loginInProgress = false;
  bool _appleSignInSupported = false;

  @override
  void initState() {
    if (Platform.isIOS) {
      DeviceInfoPlugin().iosInfo.then((iosInfo) {
        if (iosInfo.systemVersion.contains('13')) {
          setState(() {
            _appleSignInSupported = true;
          });
        }
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var widgetList = <Widget>[
      SizedBox(height: 85),
      _buildBadiUpLogo(),
      SizedBox(height: 32),
    ];

    if (_appleSignInSupported) {
      widgetList.addAll(<Widget>[
        _buildLoginWithAppleButton(context),
        SizedBox(height: 16),
      ]);
    }

    widgetList.add(_buildLoginWithGoogleButton(context));

    return Scaffold(
      body: _loginInProgress
          ? LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(paletteForegroundColor),
              backgroundColor: paletteLightGreyColor,
            )
          : Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Container(decoration: _buildBackgroundDecoration(context)),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: widgetList,
                ),
              ],
            ),
    );
  }

  Widget _buildLoginWithAppleButton(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.065,
      width: MediaQuery.of(context).size.width * 0.7,
      child: AppleSignInButton(
        style: ButtonStyle.black,
        type: ButtonType.continueButton,
        cornerRadius: 20,
        onPressed: () => _tryLoginWithApple(context),
      ),
    );
  }

  Widget _buildBadiUpLogo() {
    return Container(
      height: 77,
      width: 249,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/badiup_logo.png'),
          fit: BoxFit.fill,
        ),
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

  Widget _buildLoginWithGoogleButton(BuildContext context) {
    return RaisedButton(
      key: Key(makeTestKeyString(TKUsers.user, TKScreens.login, "loginButton")),
      onPressed: () => _tryLoginWithGoogle(context),
      color: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      highlightElevation: 100,
      child: _buildLoginWithGoogleButtonInternal(),
    );
  }

  void _tryLoginWithGoogle(BuildContext context) async {
    setState(() {
      _loginInProgress = true;
    });

    var signInSuccessful = await signInWithGoogle();

    if (signInSuccessful) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return currentSignedInUser.isAdmin()
                ? AdminHomePage(title: 'BADI UP')
                : CustomerHomePage(title: 'BADI UP');
          },
        ),
      );
    }

    setState(() {
      _loginInProgress = false;
    });
  }

  void _tryLoginWithApple(BuildContext context) async {
    setState(() {
      _loginInProgress = true;
    });

    var signInSuccessful = await signInWithApple();

    if (signInSuccessful) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return currentSignedInUser.isAdmin()
                ? AdminHomePage(title: 'BADI UP')
                : CustomerHomePage(title: 'BADI UP');
          },
        ),
      );
    }

    setState(() {
      _loginInProgress = false;
    });
  }

  Widget _buildLoginWithGoogleButtonInternal() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.065,
      width: MediaQuery.of(context).size.width * 0.62,
      alignment: AlignmentDirectional.center,
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
              'Google でログイン',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: kPaletteWhite,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

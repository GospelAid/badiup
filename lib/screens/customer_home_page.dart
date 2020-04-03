import 'dart:async';
import 'dart:io';

import 'package:badiup/sign_in.dart';
import 'package:badiup/widgets/cart_button.dart';
import 'package:badiup/widgets/main_menu.dart';
import 'package:badiup/widgets/product_listing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class CustomerHomePage extends StatefulWidget {
  CustomerHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _CustomerHomePageState createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  final FirebaseMessaging _fcm = FirebaseMessaging();
  StreamSubscription iosSubscription;

  _saveDeviceToken() async {
    String fcmDeviceToken = await _fcm.getToken();

    if (fcmDeviceToken != null) {
      var tokens = Firestore.instance
          .collection('users')
          .document(currentSignedInUser.email)
          .collection('tokens')
          .document(fcmDeviceToken);

      await tokens.setData({
        'token': fcmDeviceToken,
        'createdAt': FieldValue.serverTimestamp(),
        'platform': Platform.operatingSystem
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
        _saveDeviceToken();
      });

      _fcm.requestNotificationPermissions(IosNotificationSettings());

      _fcm.configure(
        onMessage: (Map<String, dynamic> message) async {
          print("onMessage: $message");
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: ListTile(
                title: Text(message['notification']['title']),
                subtitle: Text(message['notification']['body']),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          );
        },
        onLaunch: (Map<String, dynamic> message) async {
          // TODO: Navigate to Order detail page
        },
        onResume: (Map<String, dynamic> message) async {
          // TODO: Navigate to Order detail page
        },
      );
    }
  }

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
      actions: <Widget>[
        CartButton(),
      ],
    );
  }
}

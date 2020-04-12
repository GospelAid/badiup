import 'dart:async';
import 'dart:io';

import 'package:badiup/colors.dart';
import 'package:badiup/screens/customer_product_detail_page.dart';
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
          var dataMessage = message['data'] ?? message;
          if (message != null &&
              message['aps'] != null &&
              message['aps']['alert'] != null &&
              dataMessage['productDocumentId'] != null) {
            _getOnMessageDialog(message);
          }
        },
        onLaunch: (Map<String, dynamic> message) async {
          print("onLaunch: $message");
          var dataMessage = message['data'] ?? message;
          if (message != null && dataMessage['productDocumentId'] != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomerProductDetailPage(
                  productDocumentId: dataMessage['productDocumentId'],
                ),
              ),
            );
          }
        },
        onResume: (Map<String, dynamic> message) async {
          print("onResume: $message");
          var dataMessage = message['data'] ?? message;
          if (message != null && dataMessage['productDocumentId'] != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomerProductDetailPage(
                  productDocumentId: dataMessage['productDocumentId'],
                ),
              ),
            );
          }
        },
      );
    }
  }

  void _getOnMessageDialog(Map<String, dynamic> message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: ListTile(
          title: Text(
            message['aps']['alert']['title'],
            style: getAlertStyle(),
          ),
          subtitle: Text(
            message['aps']['alert']['body'],
            style: TextStyle(color: paletteBlackColor),
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('商品を見る'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CustomerProductDetailPage(
                    productDocumentId: message['productDocumentId'],
                  ),
                ),
              );
            },
          ),
          FlatButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
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

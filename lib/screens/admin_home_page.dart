import 'dart:async';
import 'dart:io';

import 'package:badiup/colors.dart';
import 'package:badiup/models/order_model.dart';
import 'package:badiup/sign_in.dart';
import 'package:badiup/test_keys.dart';
import 'package:badiup/widgets/main_menu.dart';
import 'package:badiup/widgets/order_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

enum OrderFilterButtons {
  all,
  pending,
  dispatched,
}

class AdminHomePage extends StatefulWidget {
  AdminHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final Firestore _db = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  StreamSubscription iosSubscription;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  OrderFilterButtons selectedOrderButton = OrderFilterButtons.all;

  bool allOrdersButtonSelected = true;
  bool pendingOrdersButtonSelected = false;
  OrderStatus orderStatusToFilter = OrderStatus.all;

  _saveDeviceToken() async {
    String fcmDeviceToken = await _fcm.getToken();

    if (fcmDeviceToken != null) {
      var tokens = _db
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
      key: _scaffoldKey,
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      drawer: _buildDrawer(context),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return SizedBox(
      width: width * 0.7,
      child: Drawer(
        child: MainMenu(),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('ホーム',
          style: TextStyle(
            color: paletteBlackColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          )),
      centerTitle: true,
      backgroundColor: paletteLightGreyColor,
      elevation: 0.0,
      iconTheme: IconThemeData(color: paletteBlackColor),
      leading: IconButton(
        key: Key(makeTestKeyString(
          TKUsers.admin,
          TKScreens.home,
          "openDrawerButton",
        )),
        icon: Icon(Icons.menu),
        onPressed: () => _scaffoldKey.currentState.openDrawer(),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      color: paletteLightGreyColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              _buildOrdersTitle(),
              SizedBox(width: 64),
              _buildOrderFilterButton(context, OrderFilterButtons.all),
              _buildOrderFilterButton(context, OrderFilterButtons.pending),
              _buildOrderFilterButton(context, OrderFilterButtons.dispatched),
            ],
          ),
          SizedBox(height: 8),
          _buildOrderList(),
        ],
      ),
    );
  }

  Widget _buildOrderList() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(top: 16.0),
        child: OrderList(orderStatusToFilter: orderStatusToFilter),
      ),
    );
  }

  Widget _buildOrderFilterButton(
    BuildContext context,
    OrderFilterButtons buttonIdentity,
  ) {
    return Expanded(
      child: Container(
        height: 40.0,
        padding: EdgeInsets.only(left: 8.0),
        child: RaisedButton(
          elevation: 0.0,
          color: buttonIdentity == selectedOrderButton
              ? paletteDarkRedColor
              : kPaletteWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          child: _buildOrderFilterButtonText(buttonIdentity),
          onPressed: () {
            setState(() {
              selectedOrderButton = buttonIdentity;
              orderStatusToFilter = _getOrderStatusFilterValue(buttonIdentity);
            });
          },
        ),
      ),
    );
  }

  Widget _buildOrderFilterButtonText(OrderFilterButtons buttonIdentity) {
    return Container(
      child: Text(
        _getOrderFilterButtonText(buttonIdentity),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: buttonIdentity == selectedOrderButton
              ? kPaletteWhite
              : paletteBlackColor,
        ),
      ),
    );
  }

  OrderStatus _getOrderStatusFilterValue(OrderFilterButtons button) {
    switch (button) {
      case OrderFilterButtons.all:
        return OrderStatus.all;
      case OrderFilterButtons.pending:
        return OrderStatus.pending;
      case OrderFilterButtons.dispatched:
        return OrderStatus.dispatched;
      default:
        return OrderStatus.all;
    }
  }

  String _getOrderFilterButtonText(OrderFilterButtons button) {
    switch (button) {
      case OrderFilterButtons.all:
        return '全て';
      case OrderFilterButtons.pending:
        return '未発送';
      case OrderFilterButtons.dispatched:
        return '発送済';
      default:
        return '';
    }
  }

  Widget _buildOrdersTitle() {
    return Text(
      '注文',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: paletteBlackColor,
      ),
    );
  }
}

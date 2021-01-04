import 'package:badiup/colors.dart';
import 'package:badiup/sign_in.dart';
import 'package:badiup/utilities.dart';
import 'package:badiup/widgets/order_list.dart';
import 'package:flutter/material.dart';

class CustomerOrderListingPage extends StatefulWidget {
  @override
  _CustomerOrderListingPageState createState() =>
      _CustomerOrderListingPageState();
}

class _CustomerOrderListingPageState extends State<CustomerOrderListingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "注文履歴",
          style: TextStyle(
            color: kPaletteWhite,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        elevation: 0.0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: currentSignedInUser.isGuest
            ? buildLoginRequiredDisplay(context)
            : OrderList(placedByFilter: currentSignedInUser.email),
      ),
    );
  }
}

import 'package:badiup/colors.dart';
import 'package:badiup/sign_in.dart';
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
            color: paletteBlackColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        elevation: 0.0,
        backgroundColor: paletteLightGreyColor,
        iconTheme: IconThemeData(color: paletteBlackColor),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: OrderList(placedByFilter: currentSignedInUser.email),
      ),
    );
  }
}

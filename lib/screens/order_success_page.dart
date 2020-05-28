import 'package:badiup/colors.dart';
import 'package:badiup/models/order_model.dart';
import 'package:badiup/screens/customer_home_page.dart';
import 'package:badiup/screens/order_detail_page.dart';
import 'package:flutter/material.dart';

class OrderSuccessPage extends StatefulWidget {
  OrderSuccessPage({Key key, this.order})
      : assert(order != null),
        super(key: key);

  final Order order;

  @override
  _OrderSuccessPageState createState() => _OrderSuccessPageState();
}

class _OrderSuccessPageState extends State<OrderSuccessPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _buildSuccessDialog(context),
          _buildProductListingButton(),
        ],
      ),
    );
  }

  Widget _buildSuccessDialog(BuildContext context) {
    return Expanded(
      child: Center(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.60,
          width: MediaQuery.of(context).size.width * 0.75,
          decoration: BoxDecoration(
            color: kPaletteWhite,
            borderRadius: BorderRadius.all(Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: paletteDialogShadowColor.withOpacity(0.10),
                blurRadius: 30.0,
                spreadRadius: 0.0,
                offset: Offset(0.0, 30.0),
              ),
            ],
          ),
          child: _buildSuccessDialogInternal(),
        ),
      ),
    );
  }

  Widget _buildSuccessDialogInternal() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          "Thank you!",
          style: TextStyle(
            fontFamily: "GreatVibes",
            fontSize: 40,
            color: paletteForegroundColor,
          ),
        ),
        Text(
          "お買上げありがとうございました",
          style: TextStyle(color: paletteBlackColor),
        ),
        _buildIcon(),
        Text(
          "注文は完了しました。",
          style: TextStyle(color: paletteBlackColor),
        ),
        SizedBox(height: 16),
        RaisedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailPage(
                  orderDocumentId: widget.order.documentId,
                ),
              ),
            );
          },
          child: Text(
            "注文番号：${widget.order.orderId}",
          ),
        ),
      ],
    );
  }

  Widget _buildIcon() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 28),
      child: Icon(
        Icons.favorite,
        size: 100,
        color: paletteForegroundColor,
      ),
    );
  }

  Widget _buildProductListingButton() {
    return Row(
      children: <Widget>[
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CustomerHomePage()),
              );
            },
            child: Container(
              height: 50,
              color: paletteForegroundColor,
              child: Center(
                child: Text(
                  "商品リストへ",
                  style: TextStyle(color: kPaletteWhite),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

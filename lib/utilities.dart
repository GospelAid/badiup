import 'package:badiup/colors.dart';
import 'package:badiup/constants.dart' as constants;
import 'package:badiup/models/stock_model.dart';
import 'package:badiup/screens/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum PaymentOption {
  card,
  furikomi,
}

Widget buildIconWithShadow(IconData iconData, {double iconSize = 24.0}) {
  return Stack(
    children: <Widget>[
      Positioned(
        left: 1.0,
        top: 2.0,
        child: Icon(
          iconData,
          size: iconSize,
          color: Colors.black54,
        ),
      ),
      Icon(
        iconData,
        size: iconSize,
        color: Colors.white,
      ),
    ],
  );
}

Widget buildFormSubmitInProgressIndicator() {
  return Stack(
    children: [
      Opacity(
        opacity: 0.5,
        child: const ModalBarrier(
          dismissible: false,
          color: Colors.black,
        ),
      ),
      Center(
        child: CircularProgressIndicator(),
      ),
    ],
  );
}

Widget buildTextFieldFromDocument({String textDocumentId}) {
  return StreamBuilder<DocumentSnapshot>(
    stream: Firestore.instance
        .collection(constants.DBCollections.texts)
        .document(textDocumentId)
        .snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return LinearProgressIndicator();
      }
      String _introText =
          snapshot.data['content'].toString().replaceAll(RegExp(r'\s'), '\n');

      return Container(
        child: Text(
          _introText,
          style: TextStyle(
            color: paletteBlackColor,
            fontSize: 16.0,
            fontWeight: FontWeight.w300,
          ),
        ),
      );
    },
  );
}

Widget buildSnackBar(String text) {
  return SnackBar(
    behavior: SnackBarBehavior.fixed,
    content: Container(
      alignment: AlignmentDirectional.centerStart,
      height: 40,
      child: Text(text),
    ),
    action: SnackBarAction(
      textColor: paletteGreyColor3,
      label: "OK",
      onPressed: () {},
    ),
  );
}

Widget buildStockItemText(StockItem stockItem, StockType stockType) {
  Color _color = stockType == StockType.sizeOnly
      ? paletteGreyColor2
      : getDisplayTextColorForItemColor(stockItem.color);

  return Container(
    width: 90,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          stockType == StockType.colorOnly
              ? Container()
              : _buildStockItemSizeDisplayText(stockItem, _color),
          stockType == StockType.sizeOnly
              ? Container()
              : _buildStockItemColorDisplayText(stockItem, _color),
        ],
      ),
    ),
  );
}

Widget _buildStockItemSizeDisplayText(StockItem stockItem, Color _color) {
  return Text(
    getDisplayTextForItemSize(stockItem.size),
    textAlign: TextAlign.center,
    style: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: _color,
    ),
  );
}

Widget _buildStockItemColorDisplayText(StockItem stockItem, Color _color) {
  return Text(
    getDisplayTextForItemColor(stockItem.color),
    textAlign: TextAlign.center,
    style: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: _color,
    ),
  );
}

Widget buildLoginRequiredDisplay(BuildContext context) {
  return Center(
    child: Container(
      height: 200,
      width: 300,
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: kPaletteWhite,
        borderRadius: BorderRadius.all(Radius.circular(6)),
        boxShadow: [
          BoxShadow(
            color: paletteDialogShadowColor.withOpacity(0.10),
            blurRadius: 30.0,
            spreadRadius: 0.0,
            offset: Offset(0.0, 30.0),
          ),
        ],
      ),
      child: buildLoginRequiredDisplayInternal(context),
    ),
  );
}

Widget buildLoginRequiredDisplayInternal(BuildContext context) {
  return Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          "ログインしてください",
          style: TextStyle(
            color: paletteForegroundColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16),
        Text(
          "お手数ですが先にログインしてください",
          style: TextStyle(color: paletteBlackColor),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        _buildLoginButton(context),
      ],
    ),
  );
}

Widget _buildLoginButton(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      FlatButton(
        child: Text(
          'ログイン',
          style: TextStyle(color: paletteForegroundColor),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
          );
        },
      ),
    ],
  );
}

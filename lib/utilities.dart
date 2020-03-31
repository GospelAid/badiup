import 'package:badiup/colors.dart';
import 'package:badiup/constants.dart' as constants;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

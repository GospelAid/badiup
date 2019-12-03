import 'package:flutter/material.dart';

Widget buildIconWithShadow(IconData iconData) {
  return Stack(
    children: <Widget>[
      Positioned(
        left: 1.0,
        top: 2.0,
        child: Icon(
          iconData,
          size: 32,
          color: Colors.black54,
        ),
      ),
      Icon(
        iconData,
        size: 32,
        color: Colors.white,
      ),
    ],
  );
}

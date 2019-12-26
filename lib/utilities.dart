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

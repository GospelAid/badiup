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

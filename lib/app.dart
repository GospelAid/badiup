import 'package:badiup/constants.dart' as constants;
import 'package:badiup/screens/admin_home_page.dart';
import 'package:badiup/screens/customer_home_page.dart';
import 'package:badiup/sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'screens/login_page.dart';
import 'package:badiup/colors.dart';

class BadiUpApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Badi Up',
      theme: _kAppTheme,
      home: FutureBuilder<FirebaseUser>(
          future: FirebaseAuth.instance.currentUser(),
          builder: (
            BuildContext context,
            AsyncSnapshot<FirebaseUser> snapshot,
          ) {
            if (snapshot.hasData) {
              return _buildHomePage(snapshot);
            }

            return LoginPage();
          }),
    );
  }

  Widget _buildHomePage(
    AsyncSnapshot<FirebaseUser> snapshot,
  ) {
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance
          .collection(constants.DBCollections.users)
          .document(snapshot.data.email)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        }

        updateCurrentSignedInUser(snapshot.data);

        return currentSignedInUser.isAdmin()
            ? AdminHomePage(title: 'BADI UP')
            : CustomerHomePage(title: 'BADI UP');
      },
    );
  }
}

final ThemeData _kAppTheme = _buildAppTheme();

ThemeData _buildAppTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    accentColor: kPaletteWhite,
    primaryColor: paletteBlackColor,
    scaffoldBackgroundColor: const Color(0xFFD2D0D1),
    cardColor: kPaletteWhite,
    textSelectionColor: kPalettePurple100,
    errorColor: kPaletteRed,
    buttonTheme: base.buttonTheme.copyWith(
      buttonColor: paletteForegroundColor,
      textTheme: ButtonTextTheme.primary,
      height: 48.0,
    ),
    primaryIconTheme: base.iconTheme.copyWith(color: kPaletteWhite),
    textTheme: _buildAppTextTheme(base.textTheme),
    primaryTextTheme: _buildAppTextTheme(base.primaryTextTheme),
    accentTextTheme: _buildAppTextTheme(base.accentTextTheme),
  );
}

TextTheme _buildAppTextTheme(TextTheme base) {
  return base
      .copyWith(
        headline: base.headline.copyWith(
          fontWeight: FontWeight.w500,
          color: kPaletteWhite,
        ),
        title: base.title.copyWith(
          fontSize: 18.0,
          color: kPaletteWhite,
        ),
        caption: base.caption.copyWith(
          fontWeight: FontWeight.w400,
          fontSize: 14.0,
          color: kPaletteWhite,
        ),
        body1: base.body1.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 16.0,
          color: kPalettePurple,
        ),
        body2: base.body2.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 16.0,
          color: kPalettePurple,
        ),
        button: base.button.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16.0,
          color: paletteBlackColor,
        ),
      )
      .apply(fontFamily: 'Rubik');
}

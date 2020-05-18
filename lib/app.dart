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
      theme: _getAppTheme(),
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

        if (snapshot.data.exists) {
          updateCurrentSignedInUser(snapshot.data);

          return currentSignedInUser.isAdmin()
              ? AdminHomePage()
              : CustomerHomePage();
        } else {
          return LoginPage();
        }
      },
    );
  }
}

ThemeData _getAppTheme() {
  final ThemeData base = ThemeData.light();

  return base.copyWith(
    accentColor: kPaletteWhite,
    accentTextTheme: _buildAppTextTheme(base.accentTextTheme),
    backgroundColor: paletteBlackColor,
    buttonTheme: base.buttonTheme.copyWith(
      buttonColor: paletteForegroundColor,
      textTheme: ButtonTextTheme.primary,
      height: 48.0,
    ),
    cardColor: kPaletteWhite,
    errorColor: kPaletteRed,
    primaryColor: paletteBlackColor,
    primaryIconTheme: base.iconTheme.copyWith(color: kPaletteWhite),
    primaryTextTheme: _buildAppTextTheme(base.primaryTextTheme),
    scaffoldBackgroundColor: paletteGreyColor3,
    textSelectionColor: kPalettePurple100,
    textTheme: _buildAppTextTheme(base.textTheme),
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
      .apply(fontFamily: 'Hiragino Sans');
}

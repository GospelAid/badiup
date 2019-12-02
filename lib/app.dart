import 'package:flutter/material.dart';

import 'screens/login_page.dart';
import 'package:badiup/colors.dart';

class BadiUpApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Badi Up',
      theme: _kAppTheme,
      home: LoginPage(),
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

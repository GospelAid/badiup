import 'package:flutter/material.dart';

import 'colors.dart';
import 'screens/home_page.dart';

class BadiUpApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Badi Up',
      theme: _kAppTheme,
      home: HomePage(title: 'Badi Up'),
    );
  }
}

final ThemeData _kAppTheme = _buildAppTheme();

ThemeData _buildAppTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    accentColor: kPaletteWhite,
    primaryColor: kPaletteDeepPurple,
    buttonColor: kPalettePurple,
    scaffoldBackgroundColor: kPaletteWhite,
    cardColor: kPaletteWhite,
    textSelectionColor: kPalettePurple100,
    errorColor: kPaletteRed,
    buttonTheme: base.buttonTheme.copyWith(
      buttonColor: kPalettePurple,
      textTheme: ButtonTextTheme.primary,
    ),
    primaryIconTheme: base.iconTheme.copyWith(
        color: kPaletteWhite
    ),
    textTheme: _buildAppTextTheme(base.textTheme),
    primaryTextTheme: _buildAppTextTheme(base.primaryTextTheme),
    accentTextTheme: _buildAppTextTheme(base.accentTextTheme),
  );
}

TextTheme _buildAppTextTheme(TextTheme base) {
  return base.copyWith(
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
  ).apply(
    fontFamily: 'Rubik',
  );
}
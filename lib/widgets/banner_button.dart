import 'package:badiup/colors.dart';
import 'package:badiup/screens/admin_product_listing_page.dart';
import 'package:badiup/screens/customer_home_page.dart';
import 'package:badiup/sign_in.dart';
import 'package:flutter/material.dart';

class BannerButton extends StatelessWidget {
  const BannerButton({
    Key key,
    @required this.onTap,
    @required this.text,
  }) : super(key: key);

  final Function onTap;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              height: 50,
              color: paletteForegroundColor,
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    color: kPaletteWhite,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class BackToProductListBannerButton extends BannerButton {
  BackToProductListBannerButton({
    Key key,
    BuildContext context,
  }) : super(
          key: key,
          text: '商品リスト',
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => currentSignedInUser.isAdmin()
                    ? AdminProductListingPage()
                    : CustomerHomePage(),
              ),
            );
          },
        );
}

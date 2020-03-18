import 'package:badiup/screens/admin_product_listing_page.dart';
import 'package:badiup/screens/customer_home_page.dart';
import 'package:badiup/sign_in.dart';
import 'package:badiup/widgets/banner_button.dart';
import 'package:flutter/material.dart';

class BackToProductListBannerButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BannerButton(
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
      text: "商品リスト",
    );
  }
}
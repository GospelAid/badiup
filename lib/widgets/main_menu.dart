import 'package:badiup/colors.dart';
import 'package:badiup/screens/about_badi_page.dart';
import 'package:badiup/screens/contact_us_page.dart';
import 'package:badiup/sign_in.dart';
import 'package:badiup/screens/admin_product_listing_page.dart';
import 'package:badiup/screens/settings_page.dart';
import 'package:badiup/screens/cart_page.dart';
import 'package:badiup/screens/customer_home_page.dart';
import 'package:badiup/screens/login_page.dart';
import 'package:badiup/test_keys.dart';
import 'package:flutter/material.dart';

class MainMenu extends StatefulWidget {
  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: paletteBlackColor,
      child: ListView(
        // children: _buildMenuElements(context),
        children: <Widget>[
          _buildDrawerHeader(context),
          _buildDrawerProductListingTile(context),
          currentSignedInUser.isAdmin()
              ? Container()
              : _buildDrawerCartTile(context),
          _buildDrawerSettingsTile(context),
          _buildDrawerContactUsTile(context),
          _buildDrawerAboutBadiTile(context),
          _buildDrawerLogoutTile(context),
        ],
      ),
    );
  }

  Widget _buildDrawerProductListingTile(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 12.0),
      child: ListTile(
        key: Key(makeTestKeyString(
          TKUsers.admin,
          TKScreens.drawer,
          "productListing",
        )),
        leading: Icon(Icons.image, color: kPaletteWhite),
        title: Text(
          '商品',
          textAlign: TextAlign.justify,
          style: TextStyle(
            fontSize: 14,
            color: kPaletteWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
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
      ),
    );
  }

  Widget _buildDrawerCartTile(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 12.0),
      child: ListTile(
        leading: Icon(Icons.shopping_cart, color: kPaletteWhite),
        title: Text(
          '買い物かごを見る',
          textAlign: TextAlign.justify,
          style: TextStyle(
            fontSize: 14,
            color: kPaletteWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return CartPage();
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawerSettingsTile(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 12.0),
      child: ListTile(
        leading: Icon(Icons.settings, color: kPaletteWhite),
        title: Text(
          '設定',
          textAlign: TextAlign.justify,
          style: TextStyle(
            fontSize: 14,
            color: kPaletteWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SettingsPage(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawerContactUsTile(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 12.0),
      child: ListTile(
        leading: Icon(Icons.store, color: kPaletteWhite),
        title: Text(
          '店舗情報',
          textAlign: TextAlign.justify,
          style: TextStyle(
            fontSize: 14,
            color: kPaletteWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ContactUsPage(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawerAboutBadiTile(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 12.0),
      child: ListTile(
        leading: Icon(Icons.face, color: kPaletteWhite),
        title: Text(
          'バディについて',
          textAlign: TextAlign.justify,
          style: TextStyle(
            fontSize: 14,
            color: kPaletteWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AboutBadiPage(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawerLogoutTile(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 12.0),
      child: ListTile(
        leading: Icon(Icons.exit_to_app, color: kPaletteWhite),
        title: Text(
          'ログアウト',
          textAlign: TextAlign.justify,
          style: TextStyle(
            fontSize: 14,
            color: kPaletteWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {
          signOutGoogle();
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) {
            return LoginPage();
          }), ModalRoute.withName('/'));
        },
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Container(
      height: 120,
      child: DrawerHeader(
        decoration: _buildDrawerHeaderDecoration(context),
        child: Container(
          padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(left: 16.0, right: 16.0),
                child: _buildDrawerHeaderAvatar(context),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildDrawerHeaderAccountInfo(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDrawerHeaderAccountInfo(BuildContext context) {
    return <Widget>[
      Text(
        currentSignedInUser.name,
        style: TextStyle(
          color: kPaletteWhite,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      Text(
        currentSignedInUser.email,
        style: TextStyle(
          color: kPaletteWhite,
          fontSize: 12,
        ),
      ),
    ];
  }

  BoxDecoration _buildDrawerHeaderDecoration(BuildContext context) {
    return BoxDecoration(
      image: DecorationImage(
        colorFilter: ColorFilter.mode(
          paletteBlackColor.withOpacity(.65),
          BlendMode.dstATop,
        ),
        image: AssetImage('assets/drawer_header_background.jpg'),
        fit: BoxFit.fitWidth,
      ),
    );
  }

  Widget _buildDrawerHeaderAvatar(BuildContext context) {
    return CircleAvatar(
      child: Icon(Icons.person),
      foregroundColor: kPaletteWhite,
      backgroundColor: paletteBlackColor,
    );
  }
}

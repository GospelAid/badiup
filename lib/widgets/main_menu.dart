import 'package:badiup/colors.dart';
import 'package:badiup/screens/about_badi_page.dart';
import 'package:badiup/screens/admin_product_listing_page.dart';
import 'package:badiup/screens/cart_page.dart';
import 'package:badiup/screens/contact_us_page.dart';
import 'package:badiup/screens/customer_home_page.dart';
import 'package:badiup/screens/customer_order_listing_page.dart';
import 'package:badiup/screens/login_page.dart';
import 'package:badiup/screens/privacy_policy_page.dart';
import 'package:badiup/screens/settings_page.dart';
import 'package:badiup/sign_in.dart';
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
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              children: _buildMenuElements(context),
            ),
          ),
          _buildPrivacyPolicyLink(context),
        ],
      ),
    );
  }

  List<Widget> _buildMenuElements(BuildContext context) {
    var widgetList = <Widget>[
      _buildDrawerHeader(context),
      Container(
        padding: EdgeInsets.only(left: 12.0),
        child: _buildDrawerProductListingTile(context),
      ),
    ];

    if (!currentSignedInUser.isAdmin()) {
      widgetList.add(Container(
        padding: EdgeInsets.only(left: 12.0),
        child: _buildDrawerCartTile(context),
      ));
      widgetList.add(Container(
        padding: EdgeInsets.only(left: 12.0),
        child: _buildDrawerMyOrdersTile(context),
      ));
    }

    widgetList.addAll(<Widget>[
      Container(
        padding: EdgeInsets.only(left: 12.0),
        child: _buildDrawerContactUsTile(context),
      ),
      Container(
        padding: EdgeInsets.only(left: 12.0),
        child: _buildDrawerAboutBadiTile(context),
      ),
      Container(
        padding: EdgeInsets.only(left: 12.0),
        child: _buildDrawerLogoutTile(context),
      ),
    ]);

    return widgetList;
  }

  Widget _buildDrawerProductListingTile(BuildContext context) {
    return ListTile(
      key: Key(makeTestKeyString(
        TKUsers.admin,
        TKScreens.drawer,
        "productListing",
      )),
      leading: Icon(Icons.list, color: kPaletteWhite),
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
        Navigator.push(
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

  Widget _buildDrawerCartTile(BuildContext context) {
    return ListTile(
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
    );
  }

  Widget _buildDrawerMyOrdersTile(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.history, color: kPaletteWhite),
      title: Text(
        '注文履歴を見る',
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
              return CustomerOrderListingPage();
            },
          ),
        );
      },
    );
  }

  Widget _buildDrawerSettingsTile(BuildContext context) {
    return ListTile(
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
    );
  }

  Widget _buildDrawerContactUsTile(BuildContext context) {
    return ListTile(
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
    );
  }

  Widget _buildDrawerAboutBadiTile(BuildContext context) {
    return ListTile(
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
    );
  }

  Widget _buildDrawerLogoutTile(BuildContext context) {
    return ListTile(
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
        showDialog<void>(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'ログアウト',
                style: getAlertStyle(),
              ),
              content: Text('ログアウトします。よろしいですか？'),
              actions: _getLogoutDialogActions(context),
            );
          },
        );
      },
    );
  }

  List<Widget> _getLogoutDialogActions(BuildContext context) {
    return <Widget>[
      FlatButton(
        child: Text(
          'いいえ',
          style: TextStyle(color: paletteBlackColor),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      FlatButton(
        child: Text(
          'はい',
          style: TextStyle(color: paletteForegroundColor),
        ),
        onPressed: () async {
          signOutGoogle();
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) {
            return LoginPage();
          }), ModalRoute.withName('/'));
        },
      ),
    ];
  }

  Widget _buildPrivacyPolicyLink(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PrivacyPolicyPage(),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.only(right: 16.0, bottom: 16.0),
        alignment: Alignment.centerRight,
        child: Text(
          'プライバシーポリシー',
          style: TextStyle(
            fontSize: 12.0,
            color: kPaletteWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
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

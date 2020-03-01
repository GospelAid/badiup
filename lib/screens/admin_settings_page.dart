import 'package:badiup/widgets/settings_listing.dart';
import 'package:flutter/material.dart';

import '../colors.dart';
import '../widgets/banner_button.dart';
import 'admin_home_page.dart';

class AdminSettngsPage extends StatefulWidget {
  @override
  _AdminSettingsPageState createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettngsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("設定",
            style: TextStyle(
              color: paletteBlackColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            )),
        elevation: 0.0,
        backgroundColor: paletteLightGreyColor,
        iconTheme: IconThemeData(color: paletteBlackColor),
        centerTitle: true,
      ),
      body: _buildSettingsListing(),
      bottomNavigationBar: BannerButton(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdminHomePage()),
          );
        },
        text: "商品リストへ",
      ),
    );
  }

  Widget _buildSettingsListing() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SettingsListing(),
        ],
      ),
    );    
  }
}

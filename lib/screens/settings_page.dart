import 'package:badiup/colors.dart';
import 'package:badiup/sign_in.dart';
import 'package:badiup/widgets/banner_button.dart';
import 'package:badiup/widgets/admin_settings_listing.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: currentSignedInUser.isAdmin()
          ? _buildAdminSettingsListing()
          : _buildCustomerSettingsListing(),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
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
    );
  }

  Widget _buildAdminSettingsListing() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          AdminSettingsListing(),
        ],
      ),
    );
  }

  Widget _buildCustomerSettingsListing() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          // TODO customer settings listing
          Container(),
        ],
      ),
    );
  }
}

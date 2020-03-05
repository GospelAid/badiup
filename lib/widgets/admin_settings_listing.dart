import 'package:flutter/material.dart';
import 'package:badiup/colors.dart';
import 'package:badiup/sign_in.dart';

bool taxInclusiveBoolValue;

class AdminSettingsListing extends StatefulWidget {
  @override
  _AdminSettingsListingState createState() => _AdminSettingsListingState();
}

class _AdminSettingsListingState extends State<AdminSettingsListing> {
  void initState() {
    super.initState();
    taxInclusiveBoolValue = currentSignedInUser.setting.taxInclusive;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: ListView(
          children: <Widget>[
            currentSignedInUser.isAdmin() ? _buildShowTaxSetting() : Container(),
          ],
        ),
      ),
    );
  }

  Widget _buildShowTaxSetting() {
    return Container(
      padding: const EdgeInsets.only( left: 16.0, right: 8.0 ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6.0),
      ),
      height: 50.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            '消費税込みの価格に設定する',
            style: TextStyle(
              fontSize: 16.0, fontWeight: FontWeight.w300, color: paletteBlackColor,
            ),
          ),
          Switch(
            activeColor: Colors.white,
            activeTrackColor: paletteForegroundColor,
            value: taxInclusiveBoolValue,
            onChanged: (bool value) {
              setState(() {
                taxInclusiveBoolValue = value;
              });
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:badiup/colors.dart';
import 'package:badiup/constants.dart' as constants;
import 'package:badiup/sign_in.dart';

class AdminSettingsListing extends StatefulWidget {
  @override
  _AdminSettingsListingState createState() => _AdminSettingsListingState();
}

class _AdminSettingsListingState extends State<AdminSettingsListing> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: ListView(
          children: <Widget>[
            _buildShowTaxSetting(),
          ],
        ),
      ),
    );
  }

  Widget _buildShowTaxSetting() {
    return Container(
      padding: const EdgeInsets.only(left: 16.0, right: 8.0),
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
              fontSize: 16.0,
              fontWeight: FontWeight.w300,
              color: paletteBlackColor,
            ),
          ),
          Switch(
            activeColor: Colors.white,
            activeTrackColor: paletteForegroundColor,
            value: currentSignedInUser.setting.taxInclusive,
            onChanged: (bool value) async {
              setState(() {
                currentSignedInUser.setting.taxInclusive = value;
              });
              await _saveCurrentSignedInUserData();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _saveCurrentSignedInUserData() async {
    await db
        .collection(constants.DBCollections.users)
        .document(currentSignedInUser.email)
        .updateData(
            {'setting.taxInclusive': currentSignedInUser.setting.taxInclusive});
  }
}

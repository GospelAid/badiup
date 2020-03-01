import 'package:flutter/material.dart';
import 'package:badiup/constants.dart' as constants;
import 'package:badiup/colors.dart';
import 'package:badiup/sign_in.dart';

class SettingsListing extends StatefulWidget {
  @override
  _SettingsListingState createState() => _SettingsListingState();
}

class _SettingsListingState extends State<SettingsListing> {
  bool _value = currentSignedInUser.setting.taxInclusive;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: ListView(
          children: <Widget>[
            _buildFirebaseNotification(),
          ],
        ),
      ),
    );
  }

  Widget _buildFirebaseNotification() {
    return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
        ),
        height: 50.0,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
          ),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('消費税込みの価格に設定する'),
                Switch(
                  activeColor: Colors.white,
                  activeTrackColor: paletteForegroundColor,
                  value: _value,
                  onChanged: (bool value) {
                    updatePushNotification(value);
                  },
                ),
              ]),
        ));
  }

  Future<void> updatePushNotification(bool value) async {
    currentSignedInUser.setting.taxInclusive = value;
    await db
        .collection(constants.DBCollections.users)
        .document(currentSignedInUser.email)
        .updateData(currentSignedInUser.toMap());
    setState(() {
      _value = value;    
    });

  }
}

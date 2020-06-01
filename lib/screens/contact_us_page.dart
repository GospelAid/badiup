import 'package:badiup/colors.dart';
import 'package:badiup/screens/privacy_policy_page.dart';
import 'package:badiup/sign_in.dart';
import 'package:badiup/widgets/banner_button.dart';
import 'package:badiup/widgets/cart_button.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as urlLauncher;

class ContactUsPage extends StatelessWidget {
  final TextStyle _tableTextStyle = TextStyle(
    color: paletteBlackColor,
    fontWeight: FontWeight.w300,
    fontSize: 16.0,
  );

  final BoxDecoration _tableBoxDecoration = BoxDecoration(
    color: paletteGreyColor5,
    border: Border(
      right: BorderSide(color: kPaletteBorderColor),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      bottomNavigationBar: BackToProductListBannerButton(context: context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0.0,
      backgroundColor: paletteLightGreyColor,
      iconTheme: IconThemeData(color: paletteBlackColor),
      actions: <Widget>[
        currentSignedInUser.isAdmin() ? Container() : CartButton(),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: ListView(
        children: <Widget>[
          _buildStoreInfoTitle(),
          SizedBox(height: 20.0),
          _buildStoreInfoTable(),
          SizedBox(height: 20.0),
          _buildPrivacyPolicyLink(context)
        ],
      ),
    );
  }

  Widget _buildStoreInfoTitle() {
    return Container(
      height: 50.0,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: kPaletteBorderColor),
        ),
      ),
      child: Text(
        '店舗情報',
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          color: paletteBlackColor,
        ),
      ),
    );
  }

  Widget _buildStoreInfoTable() {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: kPaletteBorderColor)),
      child: Column(
        children: <Widget>[
          _buildStoreNameRow(),
          _buildStoreAddressRow(),
          _buildStoreContactRow(),
        ],
      ),
    );
  }

  Widget _buildStoreNameRow() {
    return Container(
      height: 55.0,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: kPaletteBorderColor),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 100.0,
            padding: EdgeInsets.only(left: 10.0),
            alignment: Alignment.centerLeft,
            decoration: _tableBoxDecoration,
            child: Text('ショップ名', style: _tableTextStyle),
          ),
          Container(
            padding: EdgeInsets.only(left: 10.0),
            alignment: Alignment.centerLeft,
            child: SelectableText('バディカフェ', style: _tableTextStyle),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreAddressRow() {
    return Container(
      height: 95.0,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: kPaletteBorderColor),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 100.0,
            padding: EdgeInsets.only(left: 10.0),
            alignment: Alignment.centerLeft,
            decoration: _tableBoxDecoration,
            child: Text('住所', style: _tableTextStyle),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 10.0, top: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SelectableText('〒444-2149', style: _tableTextStyle),
                  SelectableText('愛知県岡崎市細川町字窪地77-207', style: _tableTextStyle),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreContactRow() {
    return Container(
      height: 190.0,
      child: Row(
        children: <Widget>[
          Container(
            width: 100.0,
            padding: EdgeInsets.only(left: 10.0),
            alignment: Alignment.centerLeft,
            decoration: _tableBoxDecoration,
            child: Text('連絡先', style: _tableTextStyle),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 10.0, top: 15.0, bottom: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _buildStorePhoneNumber(),
                  Text('【受付時間】', style: _tableTextStyle),
                  Text('月〜金（祝日除く）', style: _tableTextStyle),
                  Text('9:00-16:00', style: _tableTextStyle),
                  SelectableText('admin@badicafe.com', style: _tableTextStyle),
                  _buildLinkToWebsite(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkToWebsite() {
    String _websiteUrl = 'www.badicafe.com';
    return GestureDetector(
      onTap: () => urlLauncher.launch("https://$_websiteUrl"),
      child: Text(
        _websiteUrl,
        style: TextStyle(
          color: paletteDarkRedColor,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildStorePhoneNumber() {
    String _badiCafePhoneNumber = '0564-73-0889';
    return GestureDetector(
      onTap: () => urlLauncher.launch("tel://$_badiCafePhoneNumber"),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.phone,
            color: paletteDarkRedColor,
            size: 20.0,
          ),
          Text(
            _badiCafePhoneNumber,
            style: TextStyle(
              color: paletteDarkRedColor,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
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
      child: Row(
        children: <Widget>[
          Text(
            '・',
            style: TextStyle(
              color: paletteBlackColor,
              fontWeight: FontWeight.w300,
            ),
          ),
          Text(
            'プライバシーポリシー',
            style: TextStyle(
              decoration: TextDecoration.underline,
              color: paletteBlackColor,
              fontWeight: FontWeight.w300,
            ),
          ),
          Icon(Icons.call_made, color: kPaletteBorderColor, size: 20.0),
        ],
      ),
    );
  }
}

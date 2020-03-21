import 'package:badiup/colors.dart';
import 'package:badiup/sign_in.dart';
import 'package:badiup/utilities.dart';
import 'package:badiup/widgets/banner_button.dart';
import 'package:badiup/widgets/cart_button.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
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
          _buildPolicyTitle(),
          SizedBox(height: 15.0),
          _buildPolicyIntroText(),
          SizedBox(height: 20.0),
          _buildPersonalInfoManagementText(),
          SizedBox(height: 20.0),
          _buildPersonalInfoUseText(),
          SizedBox(height: 20.0),
          _buildPersonalInfoSecurityMeasuresText()
        ],
      ),
    );
  }

  Widget _buildPolicyTitle() {
    return Container(
      height: 50.0,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: kPaletteBorderColor),
        ),
      ),
      child: Text(
        'プライバシーポリシー',
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          color: paletteBlackColor,
        ),
      ),
    );
  }

  Widget _buildPolicyIntroText() {
    return buildTextFieldFromDocument(
      textDocumentId: 'privacyPolicyIntroText',
    );
  }

  Widget _buildPersonalInfoManagementText() {
    return Column(
      children: <Widget>[
        Container(
          alignment: Alignment.centerLeft,
          child: Text(
            '個人情報の管理',
            style: TextStyle(
              color: paletteBlackColor,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        buildTextFieldFromDocument(
          textDocumentId: 'personalInfoManagementText',
        ),
      ],
    );
  }

  Widget _buildPersonalInfoUseText() {
    return Column(
      children: <Widget>[
        Container(
          alignment: Alignment.centerLeft,
          child: Text(
            '個人情報の利用目的',
            style: TextStyle(
              color: paletteBlackColor,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        buildTextFieldFromDocument(
          textDocumentId: 'personalInfoUseText',
        ),
      ],
    );
  }

  Widget _buildPersonalInfoSecurityMeasuresText() {
    return Column(
      children: <Widget>[
        Container(
          alignment: Alignment.centerLeft,
          child: Text(
            '個人情報の安全対策',
            style: TextStyle(
              color: paletteBlackColor,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        buildTextFieldFromDocument(
          textDocumentId: 'personalInfoSecurityMeasuresText',
        ),
      ],
    );
  }
}

import 'package:badiup/colors.dart';
import 'package:badiup/sign_in.dart';
import 'package:badiup/utilities.dart';
import 'package:badiup/widgets/banner_button.dart';
import 'package:badiup/widgets/cart_button.dart';
import 'package:flutter/material.dart';

class AboutBadiPage extends StatelessWidget {
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
    return ListView(
      children: <Widget>[
        _buildAboutBadiBanner(),
        _buildCasteSystemIntro(),
        _buildBadiUpIntro(),
        SizedBox(height: 40.0),
        _buildAboutBadiModel(),
      ],
    );
  }

  Widget _buildAboutBadiBanner() {
    return Container(
      height: 211.0,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/about_badi_banner.png'),
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }

  Widget _buildCasteSystemIntro() {
    return Column(
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 32.0),
          child: Text(
            'カースト制度とは',
            style: TextStyle(
              color: paletteBlackColor,
              fontSize: 16.0,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric( horizontal: 16.0 ),
          child: buildIntroTextField(
            textDocumentId: 'casteSystemIntroText',
          ),
        ),
      ],
    );
  }

  Widget _buildBadiUpIntro() {
    return Column(
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 32.0),
          child: Text(
            'バディアップとは',
            style: TextStyle(
              color: paletteBlackColor,
              fontSize: 16.0,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric( horizontal: 16.0 ),
          child: buildIntroTextField(
            textDocumentId: 'badiUpIntroText',
          ),
        ),
      ],
    );
  }

  Widget _buildAboutBadiModel() {
    return Container(
      height: 361.0,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/about_badi_model.png'),
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }
}

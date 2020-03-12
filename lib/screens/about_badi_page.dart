import 'package:badiup/colors.dart';
import 'package:badiup/constants.dart' as constants;
import 'package:badiup/sign_in.dart';
import 'package:badiup/widgets/banner_button.dart';
import 'package:badiup/widgets/cart_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AboutBadiPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(),
      bottomNavigationBar: BannerButton(
        onTap: () {
          Navigator.pop(context);
        },
        text: "商品リストへ",
      ),
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

  Widget _buildBody() {
    return ListView(
      children: <Widget>[
        _buildAboutBadiBanner(),
        _buildCastSystemIntro(),
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

  Widget _buildCastSystemIntro() {
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
        StreamBuilder<DocumentSnapshot>(
          stream: Firestore.instance
              .collection(constants.DBCollections.texts)
              .document('castSystemIntroText')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return LinearProgressIndicator();
            }
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                snapshot.data['content'],
                style: TextStyle(
                  color: paletteBlackColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w300,
                ),
              ),
            );
          },
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
        StreamBuilder<DocumentSnapshot>(
          stream: Firestore.instance
              .collection(constants.DBCollections.texts)
              .document('badiUpIntroText')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return LinearProgressIndicator();
            }
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                snapshot.data['content'],
                style: TextStyle(
                  color: paletteBlackColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w300,
                ),
              ),
            );
          },
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

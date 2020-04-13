import 'package:badiup/colors.dart';
import 'package:badiup/sign_in.dart';
import 'package:badiup/utilities.dart';
import 'package:badiup/widgets/banner_button.dart';
import 'package:badiup/widgets/cart_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TermsOfServicePage extends StatelessWidget {
  final TextStyle headingStyle = TextStyle(
    fontSize: 16,
    color: paletteBlackColor,
    fontWeight: FontWeight.w600,
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
    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: ListView(children: <Widget>[
            SizedBox(height: 7),
            _buildDeliveryTermsOfServiceTitle(),
            SizedBox(height: 7),
            Divider(thickness: 1.0, color: kPaletteBorderColor),
            SizedBox(height: 7),
            _buildDeliveryTermsOfServiceContent(),
            SizedBox(height: 27),
          ]),
        ),
      ],
    );
  }

  Widget _buildDeliveryTermsOfServiceTitle() {
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
      Text(
        '利用規約',
        style: headingStyle,
      ),
    ]);
  }

  Widget _buildDeliveryTermsOfServiceContent() {
    return Column(
      children: <Widget>[
        Row(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 17.0),
              child: Text(
                '第1条 (会員)',
                style: headingStyle,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: buildTextFieldFromDocument(
                textDocumentId: 'termsOfServiceText01',
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 27.0, bottom: 17.0),
              child: Text(
                "第2条 (登録)",
                style: headingStyle,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: buildTextFieldFromDocument(
                textDocumentId: 'termsOfServiceText02',
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 27.0, bottom: 17.0),
              child: Text(
                "第3条 (変更)",
                style: headingStyle,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: buildTextFieldFromDocument(
                textDocumentId: 'termsOfServiceText03',
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 27.0, bottom: 17.0),
              child: Text(
                "第4条 (退会)",
                style: headingStyle,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: buildTextFieldFromDocument(
                textDocumentId: 'termsOfServiceText04',
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 27.0, bottom: 17.0),
              child: Text(
                "第5条 (会員資格の喪失及び賠償義務)",
                style: headingStyle,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: buildTextFieldFromDocument(
                textDocumentId: 'termsOfServiceText05',
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 27.0, bottom: 17.0),
              child: Text(
                "第6条 (会員情報の取扱い)",
                style: headingStyle,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: buildTextFieldFromDocument(
                textDocumentId: 'termsOfServiceText06',
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 27.0, bottom: 17.0),
              child: Text(
                "第7条 (禁止事項)",
                style: headingStyle,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: buildTextFieldFromDocument(
                textDocumentId: 'termsOfServiceText07',
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 27.0, bottom: 17.0),
              child: Text(
                "第8条 (サービスの中断・停止等)",
                style: headingStyle,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: buildTextFieldFromDocument(
                textDocumentId: 'termsOfServiceText08',
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 27.0, bottom: 17.0),
              child: Text(
                "第9条 (サービスの変更・廃止)",
                style: headingStyle,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: buildTextFieldFromDocument(
                textDocumentId: 'termsOfServiceText09',
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 27.0, bottom: 17.0),
              child: Text(
                "第10条 (免責)",
                style: headingStyle,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: buildTextFieldFromDocument(
                textDocumentId: 'termsOfServiceText10',
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 27.0, bottom: 17.0),
              child: Text(
                "第11条 (本規約の改定)",
                style: headingStyle,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: buildTextFieldFromDocument(
                textDocumentId: 'termsOfServiceText11',
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 27.0, bottom: 17.0),
              child: Text(
                "第12条 (準拠法、管轄裁判所)",
                style: headingStyle,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: buildTextFieldFromDocument(
                textDocumentId: 'termsOfServiceText12',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:badiup/widgets/banner_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../colors.dart';
import '../sign_in.dart';
import '../widgets/cart_button.dart';

class DeliveryPrivacyPolicy extends StatelessWidget {
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView(children: <Widget>[
            SizedBox(height: 17),
            _buildDeliveryPrivacyPolicyTitle(),
            SizedBox(height: 17),
            Divider(thickness: 1.0, color: kPaletteBorderColor),
            SizedBox(height: 7),
            _buildDeliveryPrivacyPolicyContent(),
            SizedBox(height: 37),
          ]),
        ),
      ],
    );
  }

  Widget _buildDeliveryPrivacyPolicyTitle() {
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
      Text(
        "プライバシーポリシー",
        style: TextStyle(
          fontSize: 16,
          color: paletteBlackColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    ]);
  }

  Widget _buildDeliveryPrivacyPolicyContent() {
    return Column(
      children: <Widget>[
        Row(children: [
          Expanded(
            child: Text(
              "特定非営利活動法人ゴスペルエイド（以下「当団体」）は、以下のとおり個人情報保護方針を定め、個人情報保護の仕組みを構築し、全社員に個人情報保護の重要性の認識と取組みを徹底させることにより、個人情報の保護を推進致します。",
              style: TextStyle(
                fontSize: 16,
                color: paletteBlackColor,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ]),
        Row(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 27.0, bottom: 7.0),
              child: Text(
                "個人情報の管理",
                style: TextStyle(
                  fontSize: 16,
                  color: paletteBlackColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            //Expanded(child: null)
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                "当団体は、お客さまの個人情報を正確かつ最新の状態に保ち、個人情報への不正アクセス・紛失・破損・改ざん・漏洩などを防止するため、セキュリティシステムの維持・管理体制の整備・社員教育の徹底等の必要な措置を講じ、安全対策を実施し個人情報の厳重な管理を行ないます。",
                style: TextStyle(
                  fontSize: 16,
                  color: paletteBlackColor,
                  fontWeight: FontWeight.w300,
                ),
              ),
            )
          ],
        ),
        Row(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 27.0, bottom: 7.0),
              child: Text(
                "個人情報の利用目的",
                style: TextStyle(
                  fontSize: 16,
                  color: paletteBlackColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            //Expanded(child: null)
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                "お客さまからお預かりした個人情報は、当団体からのご連絡や業務のご案内やご質問に対する回答として、電子メールや資料のご送付に利用いたします。\n個人情報の第三者への開示・提供の禁止 当団体は、お客さまよりお預かりした個人情報を適切に管理し、次のいずれかに該当する場合を除き、個人情報を第三者に開示いたしません。\nお客さまの同意がある場合\nお客さまが希望されるサービスを行なうために当団体が業務を委託する業者に対して開示する場合\n法令に基づき開示することが必要である場合",
                style: TextStyle(
                  fontSize: 16,
                  color: paletteBlackColor,
                  fontWeight: FontWeight.w300,
                ),
              ),
            )
          ],
        ),
        Row(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 27.0, bottom: 7.0),
              child: Text(
                "個人情報の安全対策",
                style: TextStyle(
                  fontSize: 16,
                  color: paletteBlackColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            //Expanded(child: null)
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                "当団体は、個人情報の正確性及び安全性確保のために、セキュリティに万全の対策を講じています。 ご本人の照会 お客さまがご本人の個人情報の照会・修正・削除などをご希望される場合には、ご本人であることを確認の上、対応させていただきます。 法令、規範の遵守と見直し 当団体は、保有する個人情報に関して適用される日本の法令、その他規範を遵守するとともに、本ポリシーの内容を適宜見直し、その改善に努めます。 お問い合せ 当団体の個人情報の取扱に関するお問い合せは下記までご連絡ください。",
                style: TextStyle(
                  fontSize: 16,
                  color: paletteBlackColor,
                  fontWeight: FontWeight.w300,
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}

import 'package:badiup/colors.dart';
import 'package:badiup/sign_in.dart';
import 'package:badiup/widgets/banner_button.dart';
import 'package:badiup/widgets/cart_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DeliveryTermsOfService extends StatelessWidget {
  final TextStyle headingStyle = TextStyle(
    fontSize: 16,
    color: paletteBlackColor,
    fontWeight: FontWeight.w600,
  );
  final TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    color: paletteBlackColor,
    fontWeight: FontWeight.w300,
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
            SizedBox(height: 17),
            _buildDeliveryTermsOfServiceTitle(),
            SizedBox(height: 17),
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
        "利用規約",
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
                "第1条 (会員)",
                style: headingStyle,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                "1. 「会員」とは、当団体が定める手続に従い本規約に同意の上、入会の申し込みを行う個人をいいます。\n2. 「会員情報」とは、会員が当団体に開示した会員の属性に関する情報および会員の取引に関する履歴等の情報をいいます。\n3. 本規約は、全ての会員に適用され、登録手続時および登録後にお守りいただく規約です。",
                style: bodyStyle,
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
              child: Text(
                "1. 会員資格\n本規約に同意の上、所定の入会申込みをされたお客様は、所定の登録手続完了後に会員としての資格を有します。会員登録手続は、会員となるご本人が行ってください。代理による登録は一切認められません。なお、過去に会員資格が取り消された方やその他当団体が相応しくないと判断した方からの会員申込はお断りする場合があります。\n\n2. 会員情報の入力\n会員登録手続の際には、入力上の注意をよく読み、所定の入力フォームに必要事項を正確に入力してください。会員情報の登録において、特殊記号・旧漢字・ローマ数字などはご使用になれません。これらの文字が登録された場合は当社にて変更致します。\n\n3. パスワードの管理\n(1)パスワードは会員本人のみが利用できるものとし、第三者に譲渡・貸与できないものとします。\n(2)パスワードは、他人に知られることがないよう定期的に変更する等、会員本人が責任をもって管理してください。\n(3)パスワードを用いて当団体に対して行われた意思表示は、会員本人の意思表示とみなし、そのために生じる支払等は全て会員の責任となります。",
                style: bodyStyle,
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
              child: Text(
                "1. 会員は、氏名、住所など当団体に届け出た事項に変更があった場合には、速やかに当団体に連絡するものとします。\n2. 変更登録がなされなかったことにより生じた損害について、当団体は一切責任を負いません。また、変更登録がなされた場合でも、変更登録前にすでに手続がなされた取引は、変更登録前の情報に基づいて行われますのでご注意ください。",
                style: bodyStyle,
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
              child: Text(
                "会員が退会を希望する場合には、会員本人が退会手続きを行ってください。所定の退会手続の終了後に、退会となります。",
                style: bodyStyle,
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
              child: Text(
                "1. 会員が、会員資格取得申込の際に虚偽の申告をしたとき、通信販売による代金支払債務を怠ったとき、その他当団体が会員として不適当と認める事由があるときは、当団体は、会員資格を取り消すことができることとします。\n\n2. 会員が、以下の各号に定める行為をしたときは、これにより当団体が被った損害を賠償する責任を負います。\n(1)会員番号、パスワードを不正に使用すること\n(2)当ホームページにアクセスして情報を改ざんしたり、当ホームページに有害なコンピュータープログラムを送信するなどして、当団体の営業を妨害すること\n(3)当団体が扱う商品の知的所有権を侵害する行為をすること\n(4)その他、この利用規約に反する行為をすること",
                style: bodyStyle,
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
              child: Text(
                "1. 当団体は、原則として会員情報を会員の事前の同意なく第三者に対して開示することはありません。ただし、次の各号の場合には、会員の事前の同意なく、当団体は会員情報その他のお客様情報を開示できるものとします。\n(1)法令に基づき開示を求められた場合\n(2)当団体の権利、利益、名誉等を保護するために必要であると当団体が判断した場合\n\n2. 会員情報につきましては、当団体の「個人情報保護への取組み」に従い、当団体が管理します。当団体は、会員情報を、会員へのサービス提供、サービス内容の向上、サービスの利用促進、およびサービスの健全かつ円滑な運営の確保を図る目的のために、当団体において利用することができるものとします。\n\n3. 当団体は、会員に対して、メールマガジンその他の方法による情報提供(広告を含みます)を行うことができるものとします。会員が情報提供を希望しない場合は、当団体所定の方法に従い、その旨を通知して頂ければ、情報提供を停止します。ただし、本サービス運営に必要な情報提供につきましては、会員の希望により停止をすることはできません。",
                style: bodyStyle,
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
              child: Text(
                "本サービスの利用に際して、会員に対し次の各号の行為を行うことを禁止します。\n\n1. 法令または本規約、本サービスご利用上のご注意、本サービスでのお買い物上のご注意その他の本規約等に違反すること\n2. 当団体、およびその他の第三者の権利、利益、名誉等を損ねること\n3. 青少年の心身に悪影響を及ぼす恐れがある行為、その他公序良俗に反する行為を行うこと\n4. 他の利用者その他の第三者に迷惑となる行為や不快感を抱かせる行為を行うこと\n5. 虚偽の情報を入力すること\n6. 有害なコンピュータープログラム、メール等を送信または書き込むこと\n7. 当団体のサーバーその他のコンピューターに不正にアクセスすること\n8. パスワードを第三者に貸与・譲渡すること、または第三者と共用すること\n9. その他当団体が不適切と判断すること",
                style: bodyStyle,
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
              child: Text(
                "1. 当団体は、原則として会員情報を会員の事前の同意なく第三者に対して開示することはありません。ただし、次の各号の場合には、会員の事前の同意なく、当団体は会員情報その他のお客様情報を開示できるものとします。\n(1)法令に基づき開示を求められた場合\n(2)当団体の権利、利益、名誉等を保護するために必要であると当団体が判断した場合\n(3)火災、停電、第三者による妨害行為などによりシステムの運用が困難になった場合\n(4)その他、止むを得ずシステムの停止が必要と当団体が判断した場合",
                style: bodyStyle,
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
              child: Text(
                "当団体は、その判断によりサービスの全部または一部を事前の通知なく、適宜変更・廃止できるものとします。",
                style: bodyStyle,
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
              child: Text(
                "1. 通信回線やコンピューターなどの障害によるシステムの中断・遅滞・中止・データの消失、データへの不正アクセスにより生じた損害、その他当団体のサービスに関して会員に生じた損害について、当団体は一切責任を負わないものとします。\n2. 当団体は、当団体のウェブページ・サーバー・ドメインなどから送られるメール・コンテンツに、コンピューター・ウィルスなどの有害なものが含まれていないことを保証いたしません。\n3. 会員が本規約等に違反したことによって生じた損害については、当団体は一切責任を負いません。",
                style: bodyStyle,
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
              child: Text(
                "当団体は、本規約を任意に改定できるものとし、また、当団体において本規約を補充する規約(以下「補充規約」といいます)を定めることができます。本規約の改定または補充は、改定後の本規約または補充規約を当団体所定のサイトに掲示したときにその効力を生じるものとします。この場合、会員は、改定後の規約および補充規約に従うものと致します。",
                style: bodyStyle,
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
              child: Text(
                "本規約に関して紛争が生じた場合、当団体本店所在地を管轄する地方裁判所を第一審の専属的合意管轄裁判所とします。",
                style: bodyStyle,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

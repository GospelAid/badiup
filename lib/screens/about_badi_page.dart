import 'package:badiup/colors.dart';
import 'package:badiup/widgets/banner_button.dart';
import 'package:badiup/widgets/cart_button.dart';
import 'package:flutter/material.dart';

final String _castSystemIntroText = """
紀元5世紀頃、ネパールに隣国インドからインドアーリア系の王朝が入ってきました。このときカースト制度（ジャート）が持ち込まれ、宗教、政治と結びついたと考えられます。ネパールには100以上の異なる民族が暮らしています。それぞれの民族がどのカーストに属するか決まり、それによって職業が決まっています。祭司のカースト、教師のカースト、洗濯のカーストなどなど。1962年にカースト制度は廃止されましたが、今でもほとんどの人が自分のカーストを意識して暮らしています。名字がカーストを表わすため差別につながっています。
バディ族はカースト最下位に置かれました。職業は売春のみの売春のカーストとされたのです。水を共有すること、体に触れることもできない不浄の民（アンタッチャブル）とさげすまれてきました。現在も、農村部ではその差別がひどく、都市部でもバディが就職することはほとんどできません。また、上位カーストを除くカーストに属する人々は、奴隷化可能と考えられています。ですから貧しい人々は人身売買の対象とされます。このような人の尊厳を認めない社会では少女のレイプ被害や人身売買被害が後を絶ちません。
親や親類よって売春宿に売られてしまうこともあるのです。""";

final String _badiUpIntroText = """
バディアップとは、◯◯◯の雇用を生み出し、人身売買の根絶を目的として立ち上げられた◯◯◯です。""";

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
        CartButton(),
      ],
    );
  }

  Widget _buildBody() {
    return ListView(
      children: <Widget>[
        _buildAboutBadiBanner(),
        _buildCastSystemIntro(),
        _buildBadiUpIntro(),
        SizedBox( height: 40.0 ),
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
          padding: EdgeInsets.symmetric( vertical: 32.0 ),
          child: Text(
            'カースト制度とは',
            style: TextStyle(
              color: paletteBlackColor, fontSize: 16.0, fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric( horizontal: 16.0),
          child: Text(
            _castSystemIntroText,
            style: TextStyle(
              color: paletteBlackColor, fontSize: 16.0, fontWeight: FontWeight.w300,
            ),
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
          padding: EdgeInsets.symmetric( vertical: 32.0 ),
          child: Text(
            'バディアップとは',
            style: TextStyle(
              color: paletteBlackColor, fontSize: 16.0, fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric( horizontal: 16.0),
          child: Text(
            _badiUpIntroText,
            style: TextStyle(
              color: paletteBlackColor, fontSize: 16.0, fontWeight: FontWeight.w300,
            ),
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

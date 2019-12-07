import 'dart:math';

import 'package:badiup/test_keys.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('Badi Up App', () {
    FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('admin product management test', () async {
      await driver.tap(find.byValueKey(makeTestKeyString(
        TKUsers.user,
        TKScreens.login,
        "loginButton",
      )));
      print('Tapped login');

      await driver.tap(find.byValueKey(makeTestKeyString(
        TKUsers.admin,
        TKScreens.home,
        "openDrawerButton",
      )));
      print('Opened drawer');

      await driver.tap(find.byValueKey(makeTestKeyString(
        TKUsers.admin,
        TKScreens.drawer,
        "productListing",
      )));
      print('Opened product list');

      await driver.runUnsynchronized(() async {
        await driver.tap(find.byValueKey(makeTestKeyString(
          TKUsers.admin,
          TKScreens.productListing,
          "addNew",
        )));
      });
      print('Tapped add new product');

      var productName = _getPrefixedString("テスト賞品");

      await driver.tap(find.byValueKey(makeTestKeyString(
        TKUsers.admin,
        TKScreens.addProduct,
        "title",
      )));
      await driver.enterText(productName);
      print('Entered title');

      var formFinder = find.byValueKey(makeTestKeyString(
        TKUsers.admin,
        TKScreens.addProduct,
        "form",
      ));
      var saveDraftFinder = find.byValueKey(makeTestKeyString(
        TKUsers.admin,
        TKScreens.addProduct,
        "saveDraft",
      ));
      await driver.scrollUntilVisible(
        formFinder,
        saveDraftFinder,
        dyScroll: -300.0,
      );
      await driver.tap(saveDraftFinder);
      print('Tapped save draft');

      await driver.runUnsynchronized(() async {
        var productListFinder = find.byValueKey(makeTestKeyString(
          TKUsers.admin,
          TKScreens.productListing,
          "list",
        ));
        var newProductFinder = find.byValueKey(makeTestKeyString(
          TKUsers.admin,
          TKScreens.productListing,
          "title_" + productName,
        ));
        await driver.scrollUntilVisible(
          productListFinder,
          newProductFinder,
          dyScroll: -300.0,
        );
        expect(
          await driver.getText(newProductFinder),
          productName,
        );
        print('Found product in product listing');

        await driver.tap(find.byValueKey(makeTestKeyString(
          TKUsers.admin,
          TKScreens.productListing,
          "infoPane_" + productName,
        )));
        print('Tapped product info pane');
      });

      expect(
        await driver.getText(find.byValueKey(makeTestKeyString(
          TKUsers.admin,
          TKScreens.productDetail,
          "title",
        ))),
        productName,
      );
      print('Found product in product detail');

      await driver.tap(find.byValueKey(makeTestKeyString(
        TKUsers.admin,
        TKScreens.productDetail,
        "edit",
      )));
      print('Tapped edit in product detail');

      var productDescription =
          "北セソユ権災かへづ了混れげ車最げ変回やクが携春ウヒチ会体鹿ク応9丸ロウ服意ニ最解ク止阪レをひ部実トニエ寄82表鉄からえ際指左囚廉やぱゃ。場づごえ険写所シノサ捕消し既奪イれひつ図6活ね報企さ需判ルぽぴ条希いざッ俊質トイ獰金ろぴい打得節む。位はき帳法ウシ刊類求カシ通京示ソキムメ表予ふく光構警カアユ外必横ワタメ北94館ヱ脱問おぱ選行状ゆどした徴34芸製べなば。待ネ写京江1要ラマ景土タヌチケ厳新ユミル障額やむぼ報金済ぎ部府ル必理うごんク度演ヱ面無も昼36概骨今よだねん。4異最日げ感録巡レづら写心と経界かぱざそ並亡コリヒム設限ろ聴市サ再著ご窃面冠揺浴ぜち。線づ愛53心ーに野面き自年ノテ間豊ムエレ学転どほ内戦探セラ権破ネ済鹿ッ自話キマセノ状改カ応数ぜぞづ搬文あな議画ち線小39正テ速図傘トぜこ。";
      productDescription += "-" + Uuid().v4();

      await driver.tap(find.byValueKey(makeTestKeyString(
        TKUsers.admin,
        TKScreens.addProduct,
        "description",
      )));
      await driver.enterText(productDescription);
      print('Entered description');

      var productPrice = Random().nextInt(10000).toString();

      formFinder = find.byValueKey(makeTestKeyString(
        TKUsers.admin,
        TKScreens.addProduct,
        "form",
      ));
      var priceFinder = find.byValueKey(makeTestKeyString(
        TKUsers.admin,
        TKScreens.addProduct,
        "price",
      ));
      await driver.scrollUntilVisible(
        formFinder,
        priceFinder,
        dyScroll: -300.0,
      );
      await driver.tap(priceFinder);
      await driver.enterText(productPrice);
      print('Entered price');

      await driver.tap(find.byValueKey(makeTestKeyString(
        TKUsers.admin,
        TKScreens.editProduct,
        "saveChanges",
      )));
      print('Tapped save changes');

      expect(
        await driver.getText(find.byValueKey(makeTestKeyString(
          TKUsers.admin,
          TKScreens.productDetail,
          "description",
        ))),
        productDescription,
      );
    });
  });
}

String _getPrefixedString(String suffix) {
  return (suffix + "-" + Uuid().v4()).substring(0, 10).toLowerCase();
}

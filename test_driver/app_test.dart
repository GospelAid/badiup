import 'dart:math';

import 'package:badiup/constants.dart' as constants;

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

void main() {
  // TODO: This test doesn't work because uploading image is now
  //       mandatory and this flow can't be tested by integration
  //       testing.
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

    test('new product appears in listing', () async {
      // Tap on NEW_PRODUCT_BUTTON.
      // This should open the New Product Form.
      await driver.tap(find.byValueKey(
        constants.TestKeys.newProductButton,
      ));
      print('Tapped ' + constants.TestKeys.newProductButton);

      final _product_name = _getPrefixedString("test-pn");
      final _product_price = Random().nextInt(10000);
      final _product_caption = _getPrefixedString("test-pc");
      final _product_description = _getPrefixedString("test-pd");

      await driver.tap(find.byValueKey(
        constants.TestKeys.newProductFormName,
      ));
      await driver.enterText(_product_name);
      print('Entered ' +
          _product_name +
          ' in ' +
          constants.TestKeys.newProductFormName);

      await driver.tap(find.byValueKey(
        constants.TestKeys.newProductFormPrice,
      ));
      await driver.enterText(_product_price.toString());
      print('Entered ' +
          _product_price.toString() +
          ' in ' +
          constants.TestKeys.newProductFormPrice);

      await driver.tap(find.byValueKey(
        constants.TestKeys.newProductFormCaption,
      ));
      await driver.enterText(_product_caption);
      print('Entered ' +
          _product_caption +
          ' in ' +
          constants.TestKeys.newProductFormCaption);

      await driver.tap(find.byValueKey(
        constants.TestKeys.newProductFormDescription,
      ));
      await driver.enterText(_product_description);
      print('Entered ' +
          _product_description +
          ' in ' +
          constants.TestKeys.newProductFormDescription);

      await driver.tap(find.byValueKey(
        constants.TestKeys.newProductFormSubmitButton,
      ));
      print(
        'Tapped ' + constants.TestKeys.newProductFormSubmitButton,
      );

      var testText = await driver.getText(find.byValueKey(
        constants.TestKeys.productListingFirstName,
      ));
      expect(testText, _product_name);
      print('Found ' + _product_name + ' at the top of the product listing');
    });
  });
}

String _getPrefixedString(String suffix) {
  return suffix + Uuid().v4().substring(0, 6).toLowerCase();
}

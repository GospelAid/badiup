import 'dart:math';

import 'package:badiup/constants.dart' as Constants;

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

    test('new product appears in listing', () async {
      // Tap on NEW_PRODUCT_BUTTON. 
      // This should open the New Product Form.
      await driver.tap(find.byValueKey(
        Constants.TestKeys.newProductButton));
      print('Tapped ' + Constants.TestKeys.newProductButton);

      final _product_name = _getPrefixedString("test-pn");
      final _product_price = Random().nextInt(10000);
      final _product_caption = _getPrefixedString("test-pc");
      final _product_description = _getPrefixedString("test-pd");
      
      await driver.tap(find.byValueKey(
        Constants.TestKeys.newProductFormName));
      await driver.enterText(_product_name);
      print('Entered ' + _product_name + ' in ' + 
        Constants.TestKeys.newProductFormName);

      await driver.tap(find.byValueKey(
        Constants.TestKeys.newProductFormPrice));
      await driver.enterText(_product_price.toString());
      print('Entered ' + _product_price.toString() + ' in ' + 
        Constants.TestKeys.newProductFormPrice);

      await driver.tap(find.byValueKey(
        Constants.TestKeys.newProductFormCaption));
      await driver.enterText(_product_caption);
      print('Entered ' + _product_caption + ' in ' + 
        Constants.TestKeys.newProductFormCaption);

      await driver.tap(find.byValueKey(
        Constants.TestKeys.newProductFormDescription));
      await driver.enterText(_product_description);
      print('Entered ' + _product_description + ' in ' + 
        Constants.TestKeys.newProductFormDescription);

      await driver.tap(find.byValueKey(
        Constants.TestKeys.newProductFormSubmitButton));
      print('Tapped ' + 
        Constants.TestKeys.newProductFormSubmitButton);
      
      var testText = await driver.getText(find.byValueKey(
        Constants.TestKeys.productListingFirstName));
      expect(testText, _product_name);
      print('Found ' + _product_name + 
        ' at the top of the product listing');
    });
  });
}

String _getPrefixedString(String suffix) {
  return suffix + Uuid().v4().substring(0, 6).toLowerCase();    
}
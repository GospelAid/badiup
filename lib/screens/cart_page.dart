import 'dart:collection';
import 'dart:convert';

import 'package:badiup/colors.dart';
import 'package:badiup/constants.dart' as constants;
import 'package:badiup/models/address_model.dart';
import 'package:badiup/models/cart_model.dart';
import 'package:badiup/models/customer_model.dart';
import 'package:badiup/models/order_model.dart';
import 'package:badiup/models/product_model.dart';
import 'package:badiup/models/stock_model.dart';
import 'package:badiup/screens/customer_home_page.dart';
import 'package:badiup/screens/order_success_page.dart';
import 'package:badiup/screens/privacy_policy_page.dart';
import 'package:badiup/screens/terms_service_page.dart';
import 'package:badiup/sign_in.dart';
import 'package:badiup/utilities.dart';
import 'package:badiup/widgets/address_input_form.dart';
import 'package:badiup/widgets/banner_button.dart';
import 'package:badiup/widgets/quantity_selector.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:transparent_image/transparent_image.dart';

class CartPage extends StatefulWidget {
  CartPage({Key key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  TextEditingController shippingRecipientNameController;
  TextEditingController shippingPostcodeTextController;
  TextEditingController shippingPrefectureTextController;
  TextEditingController shippingMunicipalityTextController;
  TextEditingController shippingBuildingNameTextController;
  TextEditingController shippingPhoneNumberTextController;
  StatusController shippingAddressSearchStatusController;

  TextEditingController billingRecipientNameController;
  TextEditingController billingPostcodeTextController;
  TextEditingController billingPrefectureTextController;
  TextEditingController billingMunicipalityTextController;
  TextEditingController billingBuildingNameTextController;
  TextEditingController billingPhoneNumberTextController;
  StatusController billingAddressSearchStatusController;

  TextEditingController orderNotesController;

  final currencyFormat = NumberFormat("#,##0");
  bool paymentMethodAdded = false;
  bool _formSubmitInProgress = false;
  bool _billingAddressSameAsShipping = true;
  PaymentMethod _cardPaymentMethod;
  double _totalPrice;
  double _shippingCost;
  String _formSubmitFailedMessage;
  PaymentOption _paymentOption = PaymentOption.card;

  @override
  void initState() {
    super.initState();

    shippingRecipientNameController = TextEditingController();
    shippingPostcodeTextController = TextEditingController();
    shippingPrefectureTextController = TextEditingController();
    shippingMunicipalityTextController = TextEditingController();
    shippingBuildingNameTextController = TextEditingController();
    shippingPhoneNumberTextController = TextEditingController();
    shippingAddressSearchStatusController = StatusController();

    billingRecipientNameController = TextEditingController();
    billingPostcodeTextController = TextEditingController();
    billingPrefectureTextController = TextEditingController();
    billingMunicipalityTextController = TextEditingController();
    billingBuildingNameTextController = TextEditingController();
    billingPhoneNumberTextController = TextEditingController();
    billingAddressSearchStatusController = StatusController();

    orderNotesController = TextEditingController();

    shippingAddressSearchStatusController.addListener(() {
      setState(() {
        _formSubmitInProgress =
            shippingAddressSearchStatusController.inProgress;
      });
    });

    billingAddressSearchStatusController.addListener(() {
      setState(() {
        _formSubmitInProgress = billingAddressSearchStatusController.inProgress;
      });
    });

    _shippingCost = 0;

    StripePayment.setOptions(
      StripeOptions(
        publishableKey: "pk_live_8hFKszCmdTGw3sQ2iRVeg7XZ00bjfErdtK",
        merchantId: "BADIUP",
        androidPayMode: 'test',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("買い物かご"),
      ),
      body: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          _buildCartItemListing(),
          _formSubmitInProgress
              ? buildFormSubmitInProgressIndicator()
              : Container(),
        ],
      ),
    );
  }

  Widget _buildCartItemListing() {
    return currentSignedInUser.isGuest
        ? buildLoginRequiredDisplay(context)
        : StreamBuilder<DocumentSnapshot>(
            stream: Firestore.instance
                .collection(constants.DBCollections.users)
                .document(currentSignedInUser.email)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return LinearProgressIndicator();
              }

              var customer = Customer.fromSnapshot(snapshot.data);

              if (customer.cart == null ||
                  customer.cart.items == null ||
                  customer.cart.items.isEmpty) {
                return _buildEmptyCart();
              }

              return _buildCartItemListingInternal(customer.cart);
            },
          );
  }

  Widget _buildEmptyCart() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _buildCartIsEmptyDialog(),
        BannerButton(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomerHomePage(),
              ),
            );
          },
          text: "商品リストへ",
        ),
      ],
    );
  }

  bool _isFormValid() {
    return shippingPostcodeTextController != null &&
        shippingRecipientNameController.text.isNotEmpty &&
        shippingPostcodeTextController.text.isNotEmpty &&
        shippingMunicipalityTextController.text.isNotEmpty &&
        shippingPrefectureTextController.text.isNotEmpty &&
        shippingBuildingNameTextController.text.isNotEmpty &&
        shippingPhoneNumberTextController.text.isNotEmpty &&
        (_billingAddressSameAsShipping ||
            (billingPostcodeTextController != null &&
                billingRecipientNameController.text.isNotEmpty &&
                billingPostcodeTextController.text.isNotEmpty &&
                billingMunicipalityTextController.text.isNotEmpty &&
                billingPrefectureTextController.text.isNotEmpty &&
                billingBuildingNameTextController.text.isNotEmpty &&
                billingPhoneNumberTextController.text.isNotEmpty)) &&
        (_paymentOption == PaymentOption.card && _cardPaymentMethod != null ||
            _paymentOption == PaymentOption.furikomi);
  }

  Widget _buildProcessOrderButton(BuildContext context, Cart cart) {
    return ButtonTheme(
      buttonColor:
          _isFormValid() ? paletteForegroundColor : paletteDarkGreyColor,
      child: BannerButton(
        text: "注文を確定する",
        onTap: () async {
          await _processOrder(cart, context);
        },
      ),
    );
  }

  Future<bool> _ensureStockAvailable(Cart cart) async {
    HashMap<String, List<StockItem>> _hashMap =
        HashMap<String, List<StockItem>>();

    for (var i = 0; i < cart.items.length; i++) {
      var _cartItem = cart.items[i];
      if (_hashMap.containsKey(_cartItem.productDocumentId)) {
        _hashMap[_cartItem.productDocumentId].add(_cartItem.stockRequest);
      } else {
        _hashMap[_cartItem.productDocumentId] = [_cartItem.stockRequest];
      }
    }

    for (var productIndex = 0;
        productIndex < _hashMap.keys.length;
        productIndex++) {
      var _productDocumentId = _hashMap.keys.elementAt(productIndex);

      if (!(await _ensureStockAvailableForProductDocumentId(
        _hashMap[_productDocumentId],
        _productDocumentId,
      ))) {
        return false;
      }
    }

    return true;
  }

  Future<bool> _ensureStockAvailableForProductDocumentId(
      List<StockItem> stockRequestList, String productDocumentId) async {
    var _product = Product.fromSnapshot(await db
        .collection(constants.DBCollections.products)
        .document(productDocumentId)
        .get());

    for (var stockIndex = 0;
        stockIndex < stockRequestList.length;
        stockIndex++) {
      var _productStockRequest = stockRequestList[stockIndex];

      int _productStockItemIndex = 0;

      if (_product.stock.stockType == StockType.sizeAndColor) {
        _productStockItemIndex = _product.stock.items.indexWhere(
          (stockItem) =>
              stockItem.size == _productStockRequest.size &&
              stockItem.color == _productStockRequest.color,
        );
      } else if (_product.stock.stockType == StockType.sizeOnly) {
        _productStockItemIndex = _product.stock.items.indexWhere(
          (stockItem) => stockItem.size == _productStockRequest.size,
        );
      } else if (_product.stock.stockType == StockType.colorOnly) {
        _productStockItemIndex = _product.stock.items.indexWhere(
          (stockItem) => stockItem.color == _productStockRequest.color,
        );
      }

      if (_productStockItemIndex != -1) {
        if (_product.stock.items[_productStockItemIndex].quantity <
            _productStockRequest.quantity) {
          setState(() {
            _formSubmitInProgress = false;
            _formSubmitFailedMessage = _product.name +
                (_productStockRequest.size != null
                    ? "【サイズ：" +
                        getDisplayTextForItemSize(_productStockRequest.size) +
                        "】"
                    : "") +
                (_productStockRequest.color != null
                    ? "【色：" +
                        getDisplayTextForItemColor(_productStockRequest.color) +
                        "】"
                    : "") +
                "の在庫が足りません。注文数を減らしてください。";
          });

          return false;
        }
      }
    }

    return true;
  }

  Future _processOrder(Cart cart, BuildContext context) async {
    if (_isFormValid()) {
      setState(() {
        _formSubmitInProgress = true;
      });

      if (await _ensureStockAvailable(cart)) {
        if (await _makePayment()) {
          await _updateProductStock(cart);
          Order order = await _placeOrder();

          setState(() {
            // Payment successful and order placed
            _formSubmitInProgress = false;
          });

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderSuccessPage(order: order),
            ),
          );
        } else {
          setState(() {
            _formSubmitInProgress = false;
            _formSubmitFailedMessage = "支払いに失敗しました。入力内容をもう一度ご確認ください。";
          });
        }
      }
    } else {
      setState(() {
        _formSubmitInProgress = false;
        _formSubmitFailedMessage = "お届け先と支払い方法が入力されていません。";
      });
    }
  }

  Future<bool> _makePayment() async {
    bool _paymentSuccessful = true;

    if (_paymentOption == PaymentOption.card) {
      final http.Response response = await http.post(
        'https://us-central1-badiup2.cloudfunctions.net/api/create-payment-intent',
        body: json.encode({
          'userId': currentSignedInUser.email,
          'paymentMethodId': _cardPaymentMethod.id,
        }),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        StripePayment.authenticatePaymentIntent(
          clientSecret: json.decode(response.body)['clientSecret'],
        ).then((paymentIntent) async {
          if (paymentIntent.status != 'succeeded') {
            _paymentSuccessful = false;
          }
        });
      } else {
        _paymentSuccessful = false;
      }
    }

    return _paymentSuccessful;
  }

  Widget _buildCartIsEmptyDialog() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: kPaletteWhite,
              borderRadius: BorderRadius.all(Radius.circular(6)),
              boxShadow: [
                BoxShadow(
                  color: paletteDialogShadowColor.withOpacity(0.10),
                  blurRadius: 30.0,
                  spreadRadius: 0.0,
                  offset: Offset(0.0, 30.0),
                ),
              ],
            ),
            child: _buildCartIsEmptyDialogInternal(),
          ),
        ],
      ),
    );
  }

  Widget _buildCartIsEmptyDialogInternal() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            "買い物かごに商品が入っていません",
            style: TextStyle(
              color: paletteForegroundColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          Text(
            "ぜひお買い物をお楽しみください。\nご利用をお待ちしております。",
            style: TextStyle(color: paletteBlackColor),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  Future<Order> _placeOrder() async {
    var customer = Customer.fromSnapshot(await db
        .collection(constants.DBCollections.users)
        .document(currentSignedInUser.email)
        .get());

    Order orderRequest = await _getOrderRequest(customer);

    DocumentReference orderDocRef = await db
        .collection(constants.DBCollections.orders)
        .add(orderRequest.toMap());

    customer.cart.items.clear();

    await db
        .collection(constants.DBCollections.users)
        .document(currentSignedInUser.email)
        .updateData(customer.toMap());

    return Order.fromSnapshot(await orderDocRef.snapshots().first);
  }

  Future _updateProductStock(Cart cart) async {
    HashMap<String, List<StockItem>> _hashMap =
        HashMap<String, List<StockItem>>();

    for (var i = 0; i < cart.items.length; i++) {
      var _cartItem = cart.items[i];
      if (_hashMap.containsKey(_cartItem.productDocumentId)) {
        _hashMap[_cartItem.productDocumentId].add(_cartItem.stockRequest);
      } else {
        _hashMap[_cartItem.productDocumentId] = [_cartItem.stockRequest];
      }
    }

    for (var productIndex = 0;
        productIndex < _hashMap.keys.length;
        productIndex++) {
      var _productDocumentId = _hashMap.keys.elementAt(productIndex);
      await _updateProductStockForDocumentId(
        _hashMap[_productDocumentId],
        _productDocumentId,
      );
    }
  }

  Future _updateProductStockForDocumentId(
    List<StockItem> _productStockRequestList,
    String _productDocumentId,
  ) async {
    var _product = Product.fromSnapshot(await db
        .collection(constants.DBCollections.products)
        .document(_productDocumentId)
        .get());

    for (var stockIndex = 0;
        stockIndex < _productStockRequestList.length;
        stockIndex++) {
      var _productStockRequest = _productStockRequestList[stockIndex];

      int _productStockItemIndex = 0;

      if (_product.stock.stockType == StockType.sizeAndColor) {
        _productStockItemIndex = _product.stock.items.indexWhere(
          (stockItem) =>
              stockItem.size == _productStockRequest.size &&
              stockItem.color == _productStockRequest.color,
        );
      } else if (_product.stock.stockType == StockType.sizeOnly) {
        _productStockItemIndex = _product.stock.items.indexWhere(
          (stockItem) => stockItem.size == _productStockRequest.size,
        );
      } else if (_product.stock.stockType == StockType.colorOnly) {
        _productStockItemIndex = _product.stock.items.indexWhere(
          (stockItem) => stockItem.color == _productStockRequest.color,
        );
      }

      if (_productStockItemIndex != -1) {
        _product.stock.items[_productStockItemIndex].quantity -=
            _productStockRequest.quantity;
      }
    }

    await Firestore.instance
        .collection(constants.DBCollections.products)
        .document(_productDocumentId)
        .updateData(_product.toMap());
  }

  Address _getShippingAddress() {
    return Address(
      recipientName: shippingRecipientNameController.text,
      postcode: shippingPostcodeTextController.text,
      prefecture: shippingPrefectureTextController.text,
      phoneNumber: shippingPhoneNumberTextController.text,
      city: shippingMunicipalityTextController.text,
      line1: shippingPrefectureTextController.text +
          shippingMunicipalityTextController.text,
      line2: shippingBuildingNameTextController.text,
    );
  }

  Address _getBillingAddress() {
    return Address(
      recipientName: billingRecipientNameController.text,
      postcode: billingPostcodeTextController.text,
      prefecture: billingPrefectureTextController.text,
      phoneNumber: billingPhoneNumberTextController.text,
      city: billingMunicipalityTextController.text,
      line1: billingPrefectureTextController.text +
          billingMunicipalityTextController.text,
      line2: billingBuildingNameTextController.text,
    );
  }

  Future<Order> _getOrderRequest(Customer customer) async {
    String _pushNotificationMessage = customer.name ?? customer.email + " 様より";

    Order orderRequest = Order(
      orderId: Order.generateOrderId(),
      customerId: customer.email,
      status: OrderStatus.pending,
      placedDate: DateTime.now().toUtc(),
      shippingAddress: _getShippingAddress(),
      billingAddress: _billingAddressSameAsShipping
          ? _getShippingAddress()
          : _getBillingAddress(),
      notes: orderNotesController.text,
      totalPrice: _totalPrice,
      paymentMethod: _paymentOption,
      items: [],
    );

    for (var i = 0; i < customer.cart.items.length; i++) {
      var cartItem = customer.cart.items[i];
      var product = Product.fromSnapshot(await db
          .collection(constants.DBCollections.products)
          .document(cartItem.productDocumentId)
          .get());

      orderRequest.items.add(OrderItem(
        productId: cartItem.productDocumentId,
        stockRequest: cartItem.stockRequest,
        price: product.priceInYen * cartItem.stockRequest.quantity,
      ));

      if (i == 0) {
        _pushNotificationMessage += product.name;
      }
    }

    if (customer.cart.items.length > 1) {
      _pushNotificationMessage +=
          "他" + (customer.cart.items.length - 1).toString() + "品";
    }

    _pushNotificationMessage += "の注文が入りました";
    orderRequest.pushNotificationMessage = _pushNotificationMessage;

    return orderRequest;
  }

  Widget _buildCartItemListingInternal(Cart cart) {
    List<Widget> widgetList = [];

    cart.items.forEach((item) => widgetList.add(_buildCartItem(item)));

    widgetList.add(SizedBox(height: 50));
    widgetList.add(_buildSummary());
    widgetList.add(_buildProcessOrderButton(context, cart));

    return ListView(
      children: widgetList,
    );
  }

  Widget _buildSummary() {
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance
          .collection(constants.DBCollections.users)
          .document(currentSignedInUser.email)
          .snapshots(),
      builder: (context, snapshot1) {
        if (!snapshot1.hasData) {
          return Container();
        }
        var customer = Customer.fromSnapshot(snapshot1.data);

        return StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection(constants.DBCollections.products)
              .orderBy('created', descending: true)
              .snapshots(),
          builder: (context, snapshot2) {
            if (!snapshot2.hasData) {
              return Container();
            }

            return _buildSummaryContents(
              _calculateSubTotalPrice(snapshot2, customer),
            );
          },
        );
      },
    );
  }

  Widget _buildSummaryContents(double subTotalPrice) {
    _shippingCost = subTotalPrice < 5000 ? 500 : 0;
    _totalPrice = subTotalPrice + _shippingCost;

    return Container(
      decoration: BoxDecoration(
        color: kPaletteWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: <Widget>[
            SizedBox(height: 50),
            _buildSubTotal(subTotalPrice),
            SizedBox(height: 8),
            _buildPostage(),
            SizedBox(height: 12),
            _buildTotal(),
            SizedBox(height: 16),
            _formSubmitFailedMessage != null
                ? _buildFormSubmitFailedMessage()
                : Container(),
            SizedBox(height: 16),
            _buildShippingAddressInputForm(),
            SizedBox(height: 8),
            _buildBillingAddressInputForm(),
            SizedBox(height: 32),
            _buildNotesInputForm(),
            SizedBox(height: 32),
            _buildPaymentInfoTitle(),
            SizedBox(height: 12),
            _buildPaymentOptionSelector(),
            SizedBox(height: 12),
            _buildPaymentInfoOrButton(),
            SizedBox(height: 48),
            _buildAboutDeliveryMethodInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesInputForm() {
    return Row(
      children: <Widget>[
        Text(
          "備考欄",
          style: TextStyle(
            fontSize: 16.0,
            color: paletteBlackColor,
            fontWeight: FontWeight.w300,
          ),
        ),
        SizedBox(width: 16.0),
        _buildNotesTextFormField(),
      ],
    );
  }

  Widget _buildNotesTextFormField() {
    return Container(
      padding: EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: paletteGreyColor4),
        ),
      ),
      child: Container(
        width: 245.0,
        child: TextFormField(
          maxLines: 4,
          controller: orderNotesController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.only(left: 14.0, top: 0.0, bottom: 0.0),
            hintText: '到着日時の指定などがあればご記入ください。',
          ),
        ),
      ),
    );
  }

  Widget _buildBillingAddressInputForm() {
    return Column(
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          child: Text(
            "注文者情報",
            style: TextStyle(
              fontSize: 20,
              color: paletteBlackColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 24.0),
        CheckboxListTile(
          title: Text('お届け先住所と同じ'),
          value: _billingAddressSameAsShipping,
          onChanged: (bool value) {
            setState(() {
              _billingAddressSameAsShipping = value;
            });
          },
        ),
        _billingAddressSameAsShipping
            ? Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: kPaletteBorderColor),
                  ),
                ),
              )
            : AddressInputForm(
                recipientNameController: billingRecipientNameController,
                phoneNumberTextController: billingPhoneNumberTextController,
                buildingNameTextController: billingBuildingNameTextController,
                municipalityTextController: billingMunicipalityTextController,
                postcodeTextController: billingPostcodeTextController,
                prefectureTextController: billingPrefectureTextController,
                addressSearchStatusController:
                    billingAddressSearchStatusController,
              ),
      ],
    );
  }

  Widget _buildPaymentOptionSelector() {
    return Column(
      children: <Widget>[
        RadioListTile<PaymentOption>(
          title: const Text('クレジットカードで払う'),
          value: PaymentOption.card,
          groupValue: _paymentOption,
          onChanged: (PaymentOption value) {
            setState(() {
              _paymentOption = value;
            });
          },
        ),
        RadioListTile<PaymentOption>(
          title: const Text('振り込みで払う'),
          value: PaymentOption.furikomi,
          groupValue: _paymentOption,
          onChanged: (PaymentOption value) {
            setState(() {
              _paymentOption = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPaymentInfoOrButton() {
    switch (_paymentOption) {
      case PaymentOption.card:
        return _cardPaymentMethod != null
            ? _buildPaymentInfo()
            : _buildCardButton();
      case PaymentOption.furikomi:
        return _buildFurikomiInfo();
      default:
        return Container();
    }
  }

  Widget _buildFurikomiInfo() {
    return Text(
      "商品と請求書を同梱いたします。\n記載の振込先に、商品到着後一週間を目処にお振込みください。\n（振込み手数料はご負担ください）",
      style: TextStyle(color: paletteBlackColor),
    );
  }

  Widget _buildShippingAddressInputForm() {
    return Column(
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          child: Text(
            "お届け先",
            style: TextStyle(
              fontSize: 20,
              color: paletteBlackColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 24.0),
        AddressInputForm(
          recipientNameController: shippingRecipientNameController,
          phoneNumberTextController: shippingPhoneNumberTextController,
          buildingNameTextController: shippingBuildingNameTextController,
          municipalityTextController: shippingMunicipalityTextController,
          postcodeTextController: shippingPostcodeTextController,
          prefectureTextController: shippingPrefectureTextController,
          addressSearchStatusController: shippingAddressSearchStatusController,
        ),
      ],
    );
  }

  Widget _buildFormSubmitFailedMessage() {
    return Container(
      padding: EdgeInsets.all(8),
      alignment: AlignmentDirectional.center,
      color: paletteRoseColor,
      child: Text(
        _formSubmitFailedMessage,
        style: TextStyle(color: paletteDarkRedColor),
      ),
    );
  }

  Widget _buildCardButton() {
    return Container(
      height: 38,
      width: 120,
      child: FlatButton(
        color: paletteRoseColor,
        child: Text(
          "カード情報",
          style: TextStyle(
            color: paletteBlackColor,
            fontWeight: FontWeight.w300,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
        ),
        onPressed: () async {
          await _updatePaymentIntent();
        },
      ),
    );
  }

  Future _updatePaymentIntent() async {
    await StripePayment.paymentRequestWithCardForm(
      CardFormPaymentRequest(),
    ).then((PaymentMethod paymentMethod) async {
      setState(() {
        _cardPaymentMethod = paymentMethod;
      });
    }).catchError((e) => {});
  }

  Widget _buildPaymentInfo() {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(top: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _buildPaymentMethodInfo(),
            _buildChangePaymentMethodButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodInfo() {
    var textStyle = TextStyle(color: paletteBlackColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("クレジットカード", style: textStyle),
        Text(
          _cardPaymentMethod.card.brand.toUpperCase() +
              " ****" +
              _cardPaymentMethod.card.last4,
          style: textStyle,
        ),
        Row(
          children: <Widget>[
            Text("お支払い回数：", style: textStyle),
            Text(
              "一括払い",
              style: TextStyle(
                color: paletteBlackColor,
                fontWeight: FontWeight.w600,
              ),
            )
          ],
        )
      ],
    );
  }

  Widget _buildChangePaymentMethodButton() {
    return Container(
      height: 38,
      width: 74,
      child: FlatButton(
        color: paletteRoseColor,
        child: Text(
          "変更",
          style: TextStyle(
            color: paletteBlackColor,
            fontWeight: FontWeight.w300,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
        ),
        onPressed: () {
          _updatePaymentIntent();
        },
      ),
    );
  }

  Widget _buildPaymentInfoTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          "支払い方法",
          style: TextStyle(
            fontSize: 20,
            color: paletteBlackColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAboutDeliveryMethodInfo() {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: kPaletteBorderColor)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 37),
        child: Column(
          children: <Widget>[
            _buildAboutDeliveryMethod(),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutDeliveryMethod() {
    return Column(
      children: <Widget>[
        Text(
          '配送方法について',
          style: TextStyle(
            fontSize: 18,
            color: paletteBlackColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 37),
        _buildAboutDeliveryMethodIntroText(),
        SizedBox(height: 27),
        RichText(
          textAlign: TextAlign.justify,
          text: TextSpan(
            text: '個人情報保護方針',
            style: TextStyle(
                color: paletteDarkRedColor,
                fontSize: 15.0,
                fontWeight: FontWeight.w300),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PrivacyPolicyPage(),
                  ),
                );
              },
            children: <TextSpan>[
              TextSpan(
                text: 'と',
                style: TextStyle(
                  color: paletteBlackColor,
                ),
              ),
              TextSpan(
                text: '利用規約',
                style: TextStyle(
                  color: paletteDarkRedColor,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TermsOfServicePage(),
                      ),
                    );
                  },
              ),
              TextSpan(
                text: 'に同意して注文',
                style: TextStyle(
                  color: paletteBlackColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutDeliveryMethodIntroText() {
    return buildTextFieldFromDocument(
      textDocumentId: 'aboutDeliveryMethodIntroText',
    );
  }

  double _calculateSubTotalPrice(
    AsyncSnapshot<QuerySnapshot> snapshot2,
    Customer customer,
  ) {
    List<Product> productList = [];
    snapshot2.data.documents.forEach((productDoc) {
      productList.add(Product.fromSnapshot(productDoc));
    });
    var productPriceMap = Map.fromIterable(productList,
        key: (e) => e.documentId, value: (e) => e.priceInYen);

    double _subTotalPrice = 0.0;
    customer.cart.items.forEach((cartItem) {
      _subTotalPrice += productPriceMap[cartItem.productDocumentId] *
          cartItem.stockRequest.quantity;
    });
    return _subTotalPrice;
  }

  Widget _buildTotal() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: paletteGreyColor4,
        border: Border(top: BorderSide(color: kPaletteBorderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            "総合計",
            style: TextStyle(
              color: paletteBlackColor,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            "¥${currencyFormat.format(_totalPrice)}",
            style: TextStyle(
              color: paletteForegroundColor,
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostage() {
    String shippingText = _shippingCost == 0
        ? "送料無料"
        : "¥${currencyFormat.format(_shippingCost)}";
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          "送料",
          style: TextStyle(
            color: paletteBlackColor,
            fontSize: 16.0,
            fontWeight: FontWeight.w300,
          ),
        ),
        Text(
          shippingText,
          style: TextStyle(
            color: paletteBlackColor,
            fontSize: 16.0,
            fontWeight: FontWeight.w300,
          ),
        )
      ],
    );
  }

  Widget _buildSubTotal(double subTotalPrice) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          "小計",
          style: TextStyle(
            color: paletteBlackColor,
            fontSize: 16.0,
            fontWeight: FontWeight.w300,
          ),
        ),
        Text(
          "¥${currencyFormat.format(subTotalPrice)}",
          style: TextStyle(
            color: paletteBlackColor,
            fontSize: 18.0,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Container(
      padding: EdgeInsets.only(top: 12, left: 12, right: 12),
      child: StreamBuilder<DocumentSnapshot>(
        stream: Firestore.instance
            .collection(constants.DBCollections.products)
            .document(item.productDocumentId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return LinearProgressIndicator();
          }
          var product = Product.fromSnapshot(snapshot.data);

          return _buildCartItemRow(product, item.stockRequest);
        },
      ),
    );
  }

  Widget _buildCartItemRow(Product product, StockItem stockRequest) {
    return Container(
      padding: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: kPaletteBorderColor),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _buildProductImage(product),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildDeleteButton(product.documentId, product.name),
                _buildProductTitle(product),
                _buildCartItemCaptionText(product, stockRequest),
                _buildPriceAndQuantitySelectorRow(
                  product,
                  stockRequest,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemCaptionText(Product product, StockItem stockRequest) {
    String _captionText = "";

    if (product.stock.stockType == StockType.sizeAndColor ||
        product.stock.stockType == StockType.sizeOnly) {
      _captionText += getDisplayTextForItemSize(stockRequest.size) + "サイズ";
    }

    if (product.stock.stockType == StockType.sizeAndColor) {
      _captionText += "/";
    }

    if (product.stock.stockType == StockType.sizeAndColor ||
        product.stock.stockType == StockType.colorOnly) {
      _captionText += getDisplayTextForItemColor(stockRequest.color);
    }

    return Text(
      _captionText,
      style: TextStyle(color: paletteBlackColor, fontWeight: FontWeight.w300),
    );
  }

  Widget _buildPriceAndQuantitySelectorRow(
    Product product,
    StockItem stockRequest,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _buildProductPrice(product),
        _buildQuantitySelector(product, stockRequest),
      ],
    );
  }

  Widget _buildDeleteButton(String productDocumentId, String productName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 4),
          child: GestureDetector(
            onTap: () => _showConfirmDeleteDialog(
              productName,
              productDocumentId,
            ),
            child: Row(
              children: <Widget>[
                Text(
                  "削除",
                  style: TextStyle(color: kPaletteWhite),
                ),
                Icon(Icons.close, color: kPaletteWhite),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showConfirmDeleteDialog(String productName, String productDocumentId) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '買い物カゴから削除します',
            style: getAlertStyle(),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('この商品を買い物カゴから削除してもよろしいですか？'),
              Text(
                '・$productName',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          actions: _buildDeleteDialogActions(context, productDocumentId),
        );
      },
    );
  }

  List<Widget> _buildDeleteDialogActions(
    BuildContext context,
    String productDocumentId,
  ) {
    return <Widget>[
      FlatButton(
        child: Text(
          'キャンセル',
          style: TextStyle(color: paletteBlackColor),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      FlatButton(
        child: Text(
          '削除する',
          style: TextStyle(color: paletteForegroundColor),
        ),
        onPressed: () async {
          Navigator.pop(context);
          await _deleteItemFromCart(productDocumentId);
        },
      ),
    ];
  }

  Future<void> _deleteItemFromCart(String productDocumentId) async {
    var customer = Customer.fromSnapshot(await db
        .collection(constants.DBCollections.users)
        .document(currentSignedInUser.email)
        .get());

    int productIndex = customer.cart.items.indexWhere(
      (item) => item.productDocumentId == productDocumentId,
    );
    customer.cart.items.removeAt(productIndex);

    await db
        .collection(constants.DBCollections.users)
        .document(currentSignedInUser.email)
        .updateData(customer.toMap());
  }

  Widget _buildProductTitle(Product product) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: 40),
            child: Text(
              product.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: paletteBlackColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantitySelector(
    Product product,
    StockItem stockRequest,
  ) {
    var maxCounterValue = 10;
    Iterable<StockItem> requestedProductStockItem = [];
    if (product.stock.stockType == StockType.sizeAndColor) {
      requestedProductStockItem = product.stock.items.where((stockElement) =>
          stockElement.quantity > 0 &&
          stockElement.size == stockRequest.size &&
          stockElement.color == stockRequest.color);
    } else if (product.stock.stockType == StockType.colorOnly) {
      requestedProductStockItem = product.stock.items.where((stockElement) =>
          stockElement.quantity > 0 &&
          stockElement.color == stockRequest.color);
    } else if (product.stock.stockType == StockType.quantityOnly) {
      requestedProductStockItem = product.stock.items
          .where((stockElement) => stockElement.quantity > 0);
    } else if (product.stock.stockType == StockType.sizeOnly) {
      requestedProductStockItem = product.stock.items.where((stockElement) =>
          stockElement.quantity > 0 && stockElement.size == stockRequest.size);
    }

    maxCounterValue = requestedProductStockItem.first.quantity < 10
        ? requestedProductStockItem.first.quantity
        : 10;

    var controller = QuantityController(
      value: stockRequest.quantity,
      maxCounterValue: maxCounterValue,
    );
    controller.addListener(() async {
      var customer = Customer.fromSnapshot(await db
          .collection(constants.DBCollections.users)
          .document(currentSignedInUser.email)
          .get());

      int productIndex = customer.cart.items.indexWhere((item) =>
          item.productDocumentId == product.documentId &&
          item.stockRequest.color == stockRequest.color &&
          item.stockRequest.size == stockRequest.size);
      customer.cart.items[productIndex].stockRequest.quantity =
          controller.quantity;

      await db
          .collection(constants.DBCollections.users)
          .document(currentSignedInUser.email)
          .updateData(customer.toMap());
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        QuantitySelector(
          controller: controller,
          orientation: Orientation.landscape,
        ),
      ],
    );
  }

  Text _buildProductPrice(Product product) {
    return Text(
      "¥${currencyFormat.format(product.priceInYen)}",
      style: TextStyle(
        color: paletteBlackColor,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
    );
  }

  Widget _buildProductImage(Product product) {
    Widget productImage;
    if (product.imageUrls?.isEmpty ?? true) {
      productImage = Image.memory(
        kTransparentImage,
        height: 100,
        width: 100,
      );
    } else {
      productImage = FadeInImage.memoryNetwork(
        fit: BoxFit.cover,
        height: 100,
        width: 100,
        placeholder: kTransparentImage,
        image: product.imageUrls.first,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(5.0),
      child: productImage,
    );
  }
}

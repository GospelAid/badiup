import 'package:badiup/colors.dart';
import 'package:badiup/constants.dart' as constants;
import 'package:badiup/models/cart.dart';
import 'package:badiup/models/customer_model.dart';
import 'package:badiup/models/order_model.dart';
import 'package:badiup/models/product_model.dart';
import 'package:badiup/screens/customer_home_page.dart';
import 'package:badiup/screens/order_success_page.dart';
import 'package:badiup/sign_in.dart';
import 'package:badiup/widgets/banner_button.dart';
import 'package:badiup/widgets/quantity_selector.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:transparent_image/transparent_image.dart';

class CartPage extends StatefulWidget {
  CartPage({Key key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final currencyFormat = NumberFormat("#,##0");
  bool paymentCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("買い物かご"),
      ),
      body: _buildCartItemListing(),
    );
  }

  Widget _buildCartItemListing() {
    return StreamBuilder<DocumentSnapshot>(
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

        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _buildCartItemListingInternal(customer.cart.items),
            _buildProcessOrderButton(context),
          ],
        );
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
              MaterialPageRoute(builder: (context) => CustomerHomePage()),
            );
          },
          text: "商品リストへ",
        ),
      ],
    );
  }

  Widget _buildProcessOrderButton(BuildContext context) {
    return BannerButton(
      text: paymentCompleted ? "注文を確定する" : "ご購入手続きへ",
      onTap: () async {
        if (paymentCompleted) {
          String orderId = await _placeOrder();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderSuccessPage(orderId: orderId),
            ),
          );
        } else {
          setState(() {
            paymentCompleted = true;
          });
        }
      },
    );
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
                  color: Color(0xFF5C5C5C).withOpacity(0.10),
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

  Future<String> _placeOrder() async {
    var customer = Customer.fromSnapshot(await db
        .collection(constants.DBCollections.users)
        .document(currentSignedInUser.email)
        .get());

    Order orderRequest = await _getOrderRequest(customer);

    await db
        .collection(constants.DBCollections.orders)
        .add(orderRequest.toMap());

    customer.cart.items.clear();

    await db
        .collection(constants.DBCollections.users)
        .document(currentSignedInUser.email)
        .updateData(customer.toMap());

    return orderRequest.orderId;
  }

  Future<Order> _getOrderRequest(Customer customer) async {
    Order orderRequest = Order(
      orderId: Order.generateOrderId(),
      customerId: customer.email,
      status: OrderStatus.pending,
      placedDate: DateTime.now().toUtc(),
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
        quantity: cartItem.quantity,
        price: product.priceInYen * cartItem.quantity,
      ));
    }
    return orderRequest;
  }

  Widget _buildCartItemListingInternal(List<CartItem> items) {
    List<Widget> widgetList = [];
    items.forEach((item) => widgetList.add(_buildCartItem(item)));

    widgetList.add(SizedBox(height: 50));
    widgetList.add(_buildSummary(items));

    return Expanded(
      child: ListView(
        children: widgetList,
      ),
    );
  }

  Widget _buildSummary(List<CartItem> items) {
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
                _calculateSubTotalPrice(snapshot2, customer));
          },
        );
      },
    );
  }

  Widget _buildSummaryContents(double subTotalPrice) {
    double shippingCost = 0;
    double totalPrice = subTotalPrice + shippingCost;

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
            _buildTotal(totalPrice),
            SizedBox(height: 32),
            paymentCompleted ? _buildPaymentInfo() : Container(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfo() {
    var borderSide = BorderSide(color: Color(0xFFA2A2A2));
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(top: borderSide, bottom: borderSide),
      ),
      child: Column(
        children: <Widget>[
          _buildPaymentInfoTitle(),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _buildPaymentMethodInfo(),
                _buildChangePaymentMethodButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodInfo() {
    var textStyle = TextStyle(color: paletteBlackColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("クレジットカード", style: textStyle),
        Text("楽天カード　JCB****1000", style: textStyle),
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
        color: Color(0xFFF5D8D6),
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
        onPressed: () {},
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

  double _calculateSubTotalPrice(
      AsyncSnapshot<QuerySnapshot> snapshot2, Customer customer) {
    List<Product> productList = [];
    snapshot2.data.documents.forEach((productDoc) {
      productList.add(Product.fromSnapshot(productDoc));
    });
    var productPriceMap = Map.fromIterable(productList,
        key: (e) => e.documentId, value: (e) => e.priceInYen);

    double _subTotalPrice = 0.0;
    customer.cart.items.forEach((cartItem) {
      _subTotalPrice +=
          productPriceMap[cartItem.productDocumentId] * cartItem.quantity;
    });
    return _subTotalPrice;
  }

  Widget _buildTotal(double totalPrice) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFFEFEFEF),
        border: Border(top: BorderSide(color: Color(0xFFA2A2A2))),
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
            "¥${currencyFormat.format(totalPrice)}",
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
          "送料無料",
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
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      height: 150,
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

          return _buildCartItemRow(product, item.quantity);
        },
      ),
    );
  }

  Widget _buildCartItemRow(Product product, int quantity) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: const Color(0xFFA2A2A2)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _buildProductImage(product),
          _buildProductInfo(product),
          _buildQuantitySelector(product.documentId, quantity),
          _buildDeleteButton(product.documentId),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(String productDocumentId) {
    return Padding(
      padding: EdgeInsets.only(left: 4),
      child: GestureDetector(
        onTap: () async {
          var customer = Customer.fromSnapshot(await db
              .collection(constants.DBCollections.users)
              .document(currentSignedInUser.email)
              .get());

          int productIndex = customer.cart.items.indexWhere(
              (item) => item.productDocumentId == productDocumentId);
          customer.cart.items.removeAt(productIndex);

          await db
              .collection(constants.DBCollections.users)
              .document(currentSignedInUser.email)
              .updateData(customer.toMap());
        },
        child: Icon(Icons.delete),
      ),
    );
  }

  Widget _buildProductInfo(Product product) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildProductTitle(product),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                // TODO: Size / Color goes here
                Text(""),
                _buildProductPrice(product),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySelector(String productDocumentId, int quantity) {
    var controller = QuantityController(value: quantity);
    controller.addListener(() async {
      var customer = Customer.fromSnapshot(await db
          .collection(constants.DBCollections.users)
          .document(currentSignedInUser.email)
          .get());

      int productIndex = customer.cart.items
          .indexWhere((item) => item.productDocumentId == productDocumentId);
      customer.cart.items[productIndex].quantity = controller.quantity;

      await db
          .collection(constants.DBCollections.users)
          .document(currentSignedInUser.email)
          .updateData(customer.toMap());
    });
    return QuantitySelector(
      controller: controller,
      orientation: Orientation.portrait,
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

  Widget _buildProductTitle(Product product) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        product.name,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: paletteBlackColor,
          fontWeight: FontWeight.w600,
        ),
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

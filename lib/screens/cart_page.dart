import 'package:badiup/colors.dart';
import 'package:badiup/constants.dart' as constants;
import 'package:badiup/models/cart.dart';
import 'package:badiup/models/customer_model.dart';
import 'package:badiup/models/product_model.dart';
import 'package:badiup/sign_in.dart';
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
          // TODO: Use Japanese text
          return Text("Cart is empty. Please add items");
        }

        return _buildCartItemListingInternal(customer.cart.items);
      },
    );
  }

  Widget _buildCartItemListingInternal(List<CartItem> items) {
    List<Widget> widgetList = [];
    items.forEach((item) => widgetList.add(_buildCartItem(item)));

    return Padding(
      padding: EdgeInsets.all(0),
      child: ListView(
        children: widgetList,
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
        children: <Widget>[
          _buildProductImage(product),
          _buildProductInfo(product),
          _buildQuantitySelector(product.documentId, quantity),
        ],
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
    final currencyFormat = NumberFormat("#,##0");

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

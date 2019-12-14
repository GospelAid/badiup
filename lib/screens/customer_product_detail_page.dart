import 'package:badiup/colors.dart';
import 'package:badiup/constants.dart' as constants;
import 'package:badiup/models/cart.dart';
import 'package:badiup/models/customer_model.dart';
import 'package:badiup/models/product_model.dart';
import 'package:badiup/screens/cart_page.dart';
import 'package:badiup/sign_in.dart';
import 'package:badiup/widgets/cart_button.dart';
import 'package:badiup/widgets/product_detail.dart';
import 'package:badiup/widgets/quantity_selector.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CustomerProductDetailPage extends StatefulWidget {
  CustomerProductDetailPage({
    Key key,
    this.productDocumentId,
  }) : super(key: key);

  final String productDocumentId;

  @override
  _CustomerProductDetailPageState createState() =>
      _CustomerProductDetailPageState();
}

class _CustomerProductDetailPageState extends State<CustomerProductDetailPage> {
  QuantityController quantityController = QuantityController(value: 1);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return ListView(
      children: <Widget>[
        ProductDetail(productDocumentId: widget.productDocumentId),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: QuantitySelector(
            controller: quantityController,
            orientation: Orientation.landscape,
            iconSize: 32,
          ),
        ),
        _buildCartActionsBar(),
      ],
    );
  }

  Widget _buildCartActionsBar() {
    return Row(
      children: <Widget>[
        _buildAddToCartButton(),
        Container(
          width: 2,
          color: kPaletteWhite,
        ),
        _buildGoToCartButton(),
      ],
    );
  }

  Widget _buildGoToCartButton() {
    return Expanded(
      child: GestureDetector(
        onTap: _navigateToCartPage,
        child: Container(
          height: 64,
          color: paletteForegroundColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.shopping_cart,
                color: kPaletteWhite,
              ),
              Text(
                " ご購入手続きへ",
                style: TextStyle(
                  color: kPaletteWhite,
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToCartPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return CartPage();
        },
      ),
    );
  }

  Widget _buildAddToCartButton() {
    return Expanded(
      child: GestureDetector(
        onTap: _addToCart,
        child: Container(
          height: 64,
          color: paletteForegroundColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.add_circle_outline,
                color: kPaletteWhite,
              ),
              Text(
                " 商品をかごに追加",
                style: TextStyle(
                  color: kPaletteWhite,
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _addToCart() async {
    var customer = Customer.fromSnapshot(await db
        .collection(constants.DBCollections.users)
        .document(currentSignedInUser.email)
        .get());

    _updateCartModel(customer);

    await db
        .collection(constants.DBCollections.users)
        .document(currentSignedInUser.email)
        .updateData(customer.toMap());
  }

  void _updateCartModel(Customer customer) {
    if (customer.cart == null) {
      customer.cart = Cart(
        items: [
          CartItem(
            productDocumentId: widget.productDocumentId,
            quantity: quantityController.quantity,
          ),
        ],
      );
    } else {
      int productIndex = customer.cart.items.indexWhere(
          (item) => item.productDocumentId == widget.productDocumentId);

      if (productIndex != -1) {
        customer.cart.items[productIndex].quantity +=
            quantityController.quantity;
      } else {
        customer.cart.items.add(CartItem(
          productDocumentId: widget.productDocumentId,
          quantity: quantityController.quantity,
        ));
      }
    }
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      title: StreamBuilder<DocumentSnapshot>(
        stream: Firestore.instance
            .collection(constants.DBCollections.products)
            .document(widget.productDocumentId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Text("");
          }
          var product = Product.fromSnapshot(snapshot.data);

          return Text(product.name);
        },
      ),
      actions: <Widget>[
        CartButton(),
      ],
    );
  }
}

import 'package:badiup/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:badiup/constants.dart' as Constants;
import 'package:badiup/models/product_model.dart';
import 'package:badiup/screens/new_product_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context), 
      body: _buildProductListing(context),
    );
  }

  Widget _buildProductListing(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
          .collection(Constants.DBCollections.PRODUCTS)
          .orderBy('created', descending: true)
          .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return LinearProgressIndicator();
          }

          return _buildProductListingItems(
            context, 
            snapshot.data.documents);
        },
      ),
    );
  }

  Widget _buildProductListingItems(
    BuildContext context,
    List<DocumentSnapshot> snapshots) {
    List<Widget> widgets = List<Widget>();
    snapshots.asMap().forEach((index, data) => {
      widgets.add(_buildProductListingItem(context, index, data))
    });

    return ListView(
      children: widgets,
    );
  }

  Widget _buildProductListingItem(
    BuildContext context, 
    int index,
    DocumentSnapshot data) {
    final product = Product.fromSnapshot(data);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(color: kPaletteDeepPurple),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildProductListingItemElements(product, index),
        ),
      ),
    );
  }

  List<Widget> _buildProductListingItemElements(
    Product product, 
    int index) {
    return <Widget>[
        Text(
          product.name,
          key: index == 0 ? Key(
            Constants.TestKeys.PRODUCT_LISTING_FIRST_NAME) : null,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.0),
        Text(
          product.caption,
          style: TextStyle(color: Colors.black),
        )
      ];
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text("Badi Up"),
      centerTitle: true,
      leading: _buildMenuButton(context),
      actions: <Widget>[
        _buildNewProductButton(context),
        _buildCartButton(context),
      ],
    );
  }

  Widget _buildMenuButton(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.menu,
        semanticLabel: 'menu',
      ),
      onPressed: () => {},
    );
  }

  Widget _buildNewProductButton(BuildContext context) {
    return IconButton(
      key: Key(Constants.TestKeys.NEW_PRODUCT_BUTTON),
      icon: Icon(
        Icons.add,
        semanticLabel: 'new_product',
      ),
      onPressed: () => {
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => NewProductPage()
          ),
        )
      },
    );
  }

  Widget _buildCartButton(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.shopping_cart,
        semanticLabel: 'cart',
      ),
      onPressed: () => {},
    );
  }
}
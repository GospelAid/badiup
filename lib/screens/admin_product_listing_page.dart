import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

import 'package:badiup/colors.dart';
import 'package:badiup/config.dart' as config;
import 'package:badiup/constants.dart' as constants;
import 'package:badiup/models/product_model.dart';
import 'package:badiup/screens/admin_new_product_page.dart';
import 'package:badiup/screens/admin_product_detail_page.dart';

class AdminProductListingPage extends StatefulWidget {
  AdminProductListingPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AdminProductListingPageState createState() =>
      _AdminProductListingPageState();
}

class _AdminProductListingPageState extends State<AdminProductListingPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildProductListing(context),
    );
  }

  Widget _buildProductListing(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection(constants.DBCollections.products)
          .orderBy('created', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        }

        return _buildProductListingItems(
          context,
          snapshot.data.documents,
        );
      },
    );
  }

  Widget _buildProductListingItems(
    BuildContext context,
    List<DocumentSnapshot> snapshots,
  ) {
    List<Widget> widgets = List<Widget>();
    snapshots.asMap().forEach((index, data) {
      widgets.add(_buildProductListingItem(context, index, data));
    });

    return ListView(
      children: widgets,
    );
  }

  Widget _buildProductListingItem(
    BuildContext context,
    int index,
    DocumentSnapshot data,
  ) {
    final product = Product.fromSnapshot(data);

    return Container(
      padding: const EdgeInsets.all(0.0),
      child: _buildProductListingItemTile(
        context,
        product,
        index,
      ),
    );
  }

  Widget _buildProductListingItemTile(
    BuildContext context,
    Product product,
    int index,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildProductListingItemTileImage(product),
        SizedBox(height: 8.0),
        _buildProductListingItemTileInfoPane(
          context,
          product,
          index,
        ),
        Container(
          height: 12.0,
          color: kPaletteSpacerColor,
        ),
      ],
    );
  }

  Widget _buildProductListingItemTileInfoPane(
    BuildContext context,
    Product product,
    int index,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildProductListItemTileInfoPaneName(product, index),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _buildProductListingItemTileInfoPaneDeleteButton(
                context,
                product,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductListingItemTileInfoPaneDeleteButton(
    BuildContext context,
    Product product,
  ) {
    return IconButton(
      icon: Icon(
        Icons.delete,
        color: kPaletteDeleteIconColor,
      ),
      onPressed: () => _buildConfirmDeleteDialog(context, product),
    );
  }

  Future<void> _buildConfirmDeleteDialog(
    BuildContext context,
    Product product,
  ) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirm Delete',
            style: getAlertStyle(),
          ),
          content: Text(
              'Once deleted, the data cannot be recovered. Are you sure you want to delete?'),
          actions: _buildConfirmDeleteDialogActions(
            context,
            product,
          ),
        );
      },
    );
  }

  List<Widget> _buildConfirmDeleteDialogActions(
    BuildContext context,
    Product product,
  ) {
    return <Widget>[
      FlatButton(
        child: Text('Cancel'),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      FlatButton(
        child: Text('Delete'),
        onPressed: () {
          _deleteProduct(product);
          Navigator.pop(context);
        },
      ),
    ];
  }

  Future<void> _deleteProduct(Product product) async {
    if (!(product.imageUrls?.isEmpty ?? true)) {
      final FirebaseStorage _storage = FirebaseStorage(
        storageBucket: config.firebaseStorageUri,
      );
      var ref = await _storage.getReferenceFromUrl(
        product.imageUrls.first,
      );
      await ref.delete();
    }

    await Firestore.instance
        .collection(constants.DBCollections.products)
        .document(product.documentId)
        .delete();
  }

  Widget _buildProductListingItemTileImage(Product product) {
    Widget productImage;
    if (product.imageUrls?.isEmpty ?? true) {
      productImage = Image.memory(
        kTransparentImage,
        height: constants.imageHeight,
      );
    }

    productImage = FadeInImage.memoryNetwork(
      placeholder: kTransparentImage,
      height: constants.imageHeight,
      image: product.imageUrls.first,
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminProductDetailPage(
              product: product,
            ),
          ),
        );
      },
      child: productImage,
    );
  }

  Widget _buildProductListItemTileInfoPaneName(
    Product product,
    int index,
  ) {
    return Text(
      product.name,
      key: index == 0
          ? Key(
              constants.TestKeys.productListingFirstName,
            )
          : null,
      style: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.w700,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text("商品リスト"),
      centerTitle: true,
      //leading: _buildMenuButton(context),
      actions: <Widget>[
        _buildNewProductButton(context),
      ],
    );
  }

  Widget _buildNewProductButton(BuildContext context) {
    return IconButton(
      key: Key(constants.TestKeys.newProductButton),
      icon: Icon(
        Icons.add,
        semanticLabel: 'new_product',
      ),
      onPressed: () => {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminNewProductPage(),
          ),
        ),
      },
    );
  }
}
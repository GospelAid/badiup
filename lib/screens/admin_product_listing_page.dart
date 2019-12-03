import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

import 'package:badiup/colors.dart';
import 'package:badiup/config.dart' as config;
import 'package:badiup/constants.dart' as constants;
import 'package:badiup/utilities.dart';
import 'package:badiup/models/product_model.dart';
import 'package:badiup/screens/admin_new_product_page.dart';
import 'package:badiup/screens/admin_product_detail_page.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';

class AdminProductListingPage extends StatefulWidget {
  AdminProductListingPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AdminProductListingPageState createState() =>
      _AdminProductListingPageState();
}

class _AdminProductListingPageState extends State<AdminProductListingPage> {
  // product.documentId -> index of image to display
  HashMap activeImageMap = HashMap<String, int>();

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

    activeImageMap.putIfAbsent(product.documentId, () => 0);

    return Container(
      padding: const EdgeInsets.only(
        left: 16.0,
        top: 16.0,
        right: 16.0,
      ),
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
    var widgetList = <Widget>[
      _buildProductListingItemTileImage(product),
    ];

    if ((product.imageUrls?.length ?? 0) > 1) {
      widgetList.add(
        _buildProductListingImageSliderButtons(product),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Stack(
          alignment: AlignmentDirectional.center,
          children: widgetList,
        ),
        _buildProductListingItemTileInfoPane(product),
      ],
    );
  }

  Widget _buildProductListingImageSliderButtons(Product product) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _buildProductListingImageLeftButton(product),
        _buildProductListingImageRightButton(product),
      ],
    );
  }

  Widget _buildProductListingImageRightButton(Product product) {
    return IconButton(
      icon: buildIconWithShadow(Icons.chevron_right),
      onPressed: () {
        setState(() {
          activeImageMap[product.documentId] =
              (activeImageMap[product.documentId] + 1) %
                  product.imageUrls.length;
        });
      },
    );
  }

  Widget _buildProductListingImageLeftButton(Product product) {
    return IconButton(
      icon: buildIconWithShadow(Icons.chevron_left),
      onPressed: () {
        setState(() {
          activeImageMap[product.documentId] =
              (activeImageMap[product.documentId] - 1) %
                  product.imageUrls.length;
        });
      },
    );
  }

  Widget _buildProductListingItemTileInfoPane(Product product) {
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
      child: _buildProductInfoPaneContents(product),
    );
  }

  Widget _buildProductInfoPaneContents(Product product) {
    return Container(
      padding: EdgeInsets.all(16.0),
      color: kPaletteWhite,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _buildProductInfoPaneTitle(product),
              _buildProductInfoPanePublishSwitch(product),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _buildProductInfoPaneDescription(product),
              _buildProductInfoPaneEditButton(product),
            ],
          ),
        ],
      ),
    );
  }

  IconButton _buildProductInfoPaneEditButton(Product product) {
    return IconButton(
      icon: Icon(
        Icons.edit,
        color: paletteForegroundColor,
      ),
      onPressed: () {
        // TODO: Navigate to product edit page
      },
    );
  }

  Expanded _buildProductInfoPaneDescription(Product product) {
    return Expanded(
      child: Text(
        product.description,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
        style: TextStyle(
          color: paletteBlackColor,
          fontSize: 16.0,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }

  Widget _buildProductInfoPanePublishSwitch(Product product) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text(
          "公開する",
          style: TextStyle(
            color: paletteBlackColor,
            fontSize: 14.0,
            fontWeight: FontWeight.w300,
          ),
        ),
        Switch(
          value: product.isPublished,
          onChanged: (value) async {
            await Firestore.instance
                .collection(constants.DBCollections.products)
                .document(product.documentId)
                .updateData({'isPublished': value});
          },
          activeTrackColor: paletteForegroundColor,
          activeColor: kPaletteWhite,
        ),
      ],
    );
  }

  Widget _buildProductInfoPaneTitle(Product product) {
    return Text(
      product.name,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: paletteBlackColor,
        fontWeight: FontWeight.w600,
        fontSize: 16.0,
      ),
    );
  }

  // TODO: Not used right now but keeping for future reference
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
    return Container(
      color: const Color(0xFF8D8D8D),
      height: constants.imageHeight,
      width: 500,
      child: _getProductListingImage(product),
    );
  }

  Widget _getProductListingImage(Product product) {
    var widgetList = <Widget>[];

    if (product.isPublished || (product.imageUrls?.length ?? 0) != 0) {
      widgetList.addAll([
        SpinKitThreeBounce(
          color: Colors.white,
          size: 16,
        ),
      ]);
    }

    widgetList.add(_getProductImage(product));

    return Stack(
      alignment: AlignmentDirectional.center,
      children: widgetList,
    );
  }

  Widget _getProductImage(Product product) {
    if (product.imageUrls?.isEmpty ?? true) {
      return Image.memory(
        kTransparentImage,
        height: constants.imageHeight,
      );
    } else {
      return FadeInImage.memoryNetwork(
        fit: BoxFit.fill,
        placeholder: kTransparentImage,
        image: product.imageUrls[activeImageMap[product.documentId]],
      );
    }
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

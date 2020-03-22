import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:transparent_image/transparent_image.dart';

import 'package:badiup/colors.dart';
import 'package:badiup/constants.dart' as constants;
import 'package:badiup/models/product_model.dart';
import 'package:badiup/test_keys.dart';
import 'package:badiup/models/stock_model.dart';
import 'package:badiup/utilities.dart';

class ProductDetail extends StatefulWidget {
  ProductDetail({
    Key key,
    this.productDocumentId,
    this.selectedItemColor,
    this.selectedItemSize,
  }) : super(key: key);

  final String productDocumentId;
  final ItemColor selectedItemColor;
  ItemSize selectedItemSize;

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  int _indexOfImageInDisplay = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance
          .collection(constants.DBCollections.products)
          .document(widget.productDocumentId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        }
        var product = Product.fromSnapshot(snapshot.data);

        return _buildProductDetailInternal(product);
      },
    );
  }

  Widget _buildProductDetailInternal(Product product) {
    return Column(
      children: <Widget>[
        _buildProductImageSlideshow(product),
        SizedBox(height: 8.0),
        _buildThumbnailBar(product),
        SizedBox(height: 24.0),
        _buildProductTitle(product),
        SizedBox(height: 8.0),
        Divider(thickness: 1.0, color: kPaletteBorderColor),
        _buildProductDescription(product),
        SizedBox(height: 8.0),
        _buildProductPrice(product),
        SizedBox(height: 8.0),
        _buildFewItemsInStockMessage(product),
        SizedBox(height: 8.0),
        _buildProductCategory(product.category),
      ],
    );
  }

  Widget _buildFewItemsInStockMessage(Product product) {
    int stockQuantityRemaining = 10;
    if (widget.selectedItemSize != null && widget.selectedItemColor != null) {
      product.stock.items.forEach((stockElement) {
        if (stockElement.size == widget.selectedItemSize &&
            stockElement.color == widget.selectedItemColor) {
          stockQuantityRemaining = stockElement.quantity;
        }
      });
    } else {
      stockQuantityRemaining = product.stock.items.where((element)=>element.quantity>0).first.quantity;
    }
    List<Widget> textStructureWidgetList = List<Widget>();
    if (stockQuantityRemaining < 10) {
      textStructureWidgetList.add(Text(
        "この商品の在庫は現在",
        style: TextStyle(
          color: paletteGreyColor,
          fontSize: 12.0,
          fontWeight: FontWeight.w600,
        ),
      ));
      textStructureWidgetList.add(Text(
        stockQuantityRemaining.toString() + "個",
        style: TextStyle(
          color: paletteForegroundColor,
          fontSize: 12.0,
          fontWeight: FontWeight.w600,
        ),
      ));
      textStructureWidgetList.add(Text(
        "です",
        style: TextStyle(
          color: paletteGreyColor,
          fontSize: 12.0,
          fontWeight: FontWeight.w600,
        ),
      ));
    }
    return stockQuantityRemaining < 10 ? Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: textStructureWidgetList,
    ) : Container();
  }

  Widget _buildProductCategory(Category category) => category != null
      ? Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(8),
              alignment: AlignmentDirectional.center,
              height: 40,
              color: paletteDarkGreyColor,
              child: Text(
                getDisplayText(category),
                style: TextStyle(color: kPaletteWhite),
              ),
            ),
          ],
        )
      : Container();

  Widget _buildProductPrice(Product product) {
    final currencyFormat = NumberFormat("#,##0");

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text(
          "¥${currencyFormat.format(product.priceInYen)}",
          style: TextStyle(
            color: paletteForegroundColor,
            fontSize: 24.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          "（税込）",
          style: TextStyle(
            color: Color(0xFF888888),
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildProductDescription(Product product) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Text(
            product.description,
            key: Key(makeTestKeyString(
              TKUsers.admin,
              TKScreens.productDetail,
              "description",
            )),
            style: TextStyle(
              color: paletteBlackColor,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductTitle(Product product) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Text(
            product.name,
            key: Key(makeTestKeyString(
              TKUsers.admin,
              TKScreens.productDetail,
              "title",
            )),
            style: TextStyle(
              color: paletteBlackColor,
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnailBar(Product product) {
    return Container(
      height: 40.0,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _buildImageThumbnails(product),
      ),
    );
  }

  List<Widget> _buildImageThumbnails(Product product) {
    List<Widget> thumbnails = [];

    if (product.imageUrls != null) {
      for (var i = 0; i < product.imageUrls.length; i++) {
        thumbnails.add(_buildImageThumbnail(product, i));
      }
    }

    return thumbnails;
  }

  Widget _buildImageThumbnail(Product product, int imageIndex) {
    String imageUrl = product.imageUrls[imageIndex];

    return GestureDetector(
      key: Key(imageUrl),
      onTap: () {
        setState(() {
          _indexOfImageInDisplay = imageIndex;
        });
      },
      child: Padding(
        padding: EdgeInsets.only(right: 8.0),
        child: Container(
          width: 40.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
            border: _buildThumbnailBorder(imageIndex),
          ),
        ),
      ),
    );
  }

  Border _buildThumbnailBorder(int imageIndex) {
    Border thumbnailBorder;
    if (_indexOfImageInDisplay == imageIndex) {
      thumbnailBorder = Border.all(
        color: paletteBlackColor,
        width: 2.0,
      );
    }
    return thumbnailBorder;
  }

  Widget _buildProductListingItemTileImage(Product product) {
    return Container(
      height: 232.5,
      color: paletteDarkGreyColor,
      child: _getProductListingImage(product),
    );
  }

  Widget _getProductListingImage(Product product) {
    var widgetList = <Widget>[];

    if (product.isPublished || (product.imageUrls?.length ?? 0) != 0) {
      widgetList.add(
        SpinKitThreeBounce(
          color: Colors.white,
          size: 16,
        ),
      );
    }

    widgetList.add(_getProductImage(product));

    return Stack(
      alignment: AlignmentDirectional.center,
      children: widgetList,
    );
  }

  Widget _getProductImage(Product product) {
    Widget productImage;
    if (product.imageUrls?.isEmpty ?? true) {
      productImage = Image.memory(
        kTransparentImage,
      );
    } else {
      productImage = FadeInImage.memoryNetwork(
        fit: BoxFit.contain,
        placeholder: kTransparentImage,
        image: product.imageUrls[_indexOfImageInDisplay],
      );
    }
    return productImage;
  }

  Widget _buildProductImageSlideshow(Product product) {
    var widgetList = <Widget>[
      _buildProductListingItemTileImage(product),
    ];

    if (product.imageUrls != null && product.imageUrls.length > 1) {
      widgetList.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _buildSlideshowLeftButton(product),
          _buildSlideshowRightButton(product),
        ],
      ));
    }

    return Stack(
      alignment: AlignmentDirectional.center,
      children: widgetList,
    );
  }

  Widget _buildSlideshowRightButton(Product product) {
    return IconButton(
      icon: buildIconWithShadow(Icons.chevron_right, iconSize: 32),
      onPressed: () {
        setState(() {
          _indexOfImageInDisplay =
              (_indexOfImageInDisplay + 1) % product.imageUrls.length;
        });
      },
    );
  }

  Widget _buildSlideshowLeftButton(Product product) {
    return IconButton(
      icon: buildIconWithShadow(Icons.chevron_left, iconSize: 32),
      onPressed: () {
        setState(() {
          _indexOfImageInDisplay =
              (_indexOfImageInDisplay - 1) % product.imageUrls.length;
        });
      },
    );
  }
}

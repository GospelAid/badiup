import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:transparent_image/transparent_image.dart';

import 'package:badiup/colors.dart';
import 'package:badiup/constants.dart' as constants;
import 'package:badiup/utilities.dart';
import 'package:badiup/models/product_model.dart';
import 'package:badiup/screens/admin_new_product_page.dart';

class AdminProductDetailPage extends StatefulWidget {
  AdminProductDetailPage({
    Key key,
    this.product,
  }) : super(key: key);

  final Product product;

  @override
  _AdminProductDetailPageState createState() => _AdminProductDetailPageState();
}

class _AdminProductDetailPageState extends State<AdminProductDetailPage> {
  int _indexOfImageInDisplay = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildProductDetail(context),
      floatingActionButton: _buildEditButton(),
    );
  }

  Widget _buildEditButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminNewProductPage(
              product: widget.product,
            ),
          ),
        );
      },
      child: _buildEditButtonIcon(),
    );
  }

  Stack _buildEditButtonIcon() {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
        Container(
          height: 70,
          width: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: paletteForegroundColor,
          ),
        ),
        Icon(
          Icons.edit,
          color: kPaletteWhite,
          size: 40,
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(widget.product.name),
    );
  }

  Widget _buildProductDetail(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: ListView(
        children: <Widget>[
          _buildProductImageSlideshow(),
          SizedBox(height: 8.0),
          _buildThumbnailBar(),
          SizedBox(height: 24.0),
          _buildProductTitle(),
          SizedBox(height: 8.0),
          Divider(thickness: 1.0, color: const Color(0XFFA2A2A2)),
          _buildProductDescription(),
          SizedBox(height: 8.0),
          _buildProductPrice(),
          SizedBox(height: 100.0),
        ],
      ),
    );
  }

  Widget _buildProductPrice() {
    final currencyFormat = NumberFormat("#,##0");

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text(
          "¥${currencyFormat.format(widget.product.priceInYen)}",
          style: TextStyle(
            color: paletteBlackColor,
            fontSize: 24.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildProductDescription() {
    return Text(
      widget.product.description,
      style: TextStyle(
        color: paletteBlackColor,
        fontWeight: FontWeight.w300,
      ),
    );
  }

  Widget _buildProductTitle() {
    return Text(
      widget.product.name,
      style: TextStyle(
        color: paletteBlackColor,
        fontSize: 20.0,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildThumbnailBar() {
    return Container(
      height: 40.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: _buildImageThumbnails(),
      ),
    );
  }

  List<Widget> _buildImageThumbnails() {
    List<Widget> thumbnails = [];

    if (widget.product.imageUrls != null) {
      for (var i = 0; i < widget.product.imageUrls.length; i++) {
        thumbnails.add(_buildImageThumbnail(i));
      }
    }

    return thumbnails;
  }

  Widget _buildImageThumbnail(int imageIndex) {
    String imageUrl = widget.product.imageUrls[imageIndex];

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
      color: const Color(0xFF8D8D8D),
      height: constants.imageHeight,
      width: 500,
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
    if (widget.product.imageUrls?.isEmpty ?? true) {
      productImage = Image.memory(
        kTransparentImage,
        height: constants.imageHeight,
      );
    } else {
      productImage = FadeInImage.memoryNetwork(
        fit: BoxFit.contain,
        placeholder: kTransparentImage,
        height: constants.imageHeight,
        image: widget.product.imageUrls[_indexOfImageInDisplay],
      );
    }
    return productImage;
  }

  Widget _buildProductImageSlideshow() {
    var widgetList = <Widget>[
      _buildProductListingItemTileImage(widget.product),
    ];

    if (widget.product.imageUrls != null &&
        widget.product.imageUrls.length > 1) {
      widgetList.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _buildSlideshowLeftButton(),
          _buildSlideshowRightButton(),
        ],
      ));
    }

    return Stack(
      alignment: AlignmentDirectional.center,
      children: widgetList,
    );
  }

  Widget _buildSlideshowRightButton() {
    return IconButton(
      icon: buildIconWithShadow(Icons.chevron_right),
      onPressed: () {
        setState(() {
          _indexOfImageInDisplay =
              (_indexOfImageInDisplay + 1) % widget.product.imageUrls.length;
        });
      },
    );
  }

  Widget _buildSlideshowLeftButton() {
    return IconButton(
      icon: buildIconWithShadow(Icons.chevron_left),
      onPressed: () {
        setState(() {
          _indexOfImageInDisplay =
              (_indexOfImageInDisplay - 1) % widget.product.imageUrls.length;
        });
      },
    );
  }
}

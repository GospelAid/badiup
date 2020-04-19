import 'dart:collection';

import 'package:badiup/colors.dart';
import 'package:badiup/constants.dart' as constants;
import 'package:badiup/models/product_model.dart';
import 'package:badiup/models/user_model.dart';
import 'package:badiup/screens/about_badi_page.dart';
import 'package:badiup/screens/admin_new_product_page.dart';
import 'package:badiup/screens/admin_product_detail_page.dart';
import 'package:badiup/screens/customer_product_detail_page.dart';
import 'package:badiup/sign_in.dart';
import 'package:badiup/test_keys.dart';
import 'package:badiup/utilities.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';

class ProductListing extends StatefulWidget {
  @override
  _ProductListingState createState() => _ProductListingState();
}

class _ProductListingState extends State<ProductListing> {
  // product.documentId -> index of image to display
  HashMap activeImageMap = HashMap<String, int>();
  List<String> _categoryFilters = [];
  bool _isFilterMenuOpen = false;
  final String _archivedText = "アーカイブ";

  @override
  Widget build(BuildContext context) {
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
      _addProductToWidgetListInDisplay(data, widgets, context, index);
    });

    widgets.add(_buildAboutBadiBanner());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      key: Key(makeTestKeyString(
        TKUsers.admin,
        TKScreens.productListing,
        "list",
      )),
      children: [
        _buildCategoryFilterMenu(),
        Expanded(
          child: ListView(
            children: widgets,
          ),
        ),
      ],
    );
  }

  void _addProductToWidgetListInDisplay(
    DocumentSnapshot data,
    List<Widget> widgets,
    BuildContext context,
    int index,
  ) {
    final product = Product.fromSnapshot(data);
    int _productQuantity = (product.stock == null)
        ? 0
        : product.stock.items.fold(0, (a, b) => a + (b?.quantity ?? 0));

    // Show only published products if current user is customer
    // Otherwise, show all products
    if (currentSignedInUser.role == RoleType.customer) {
      if (product.isPublished && _productQuantity > 0) {
        if (_categoryFilters.isEmpty ||
            _categoryFilters.contains(getDisplayText(product.category))) {
          widgets.add(_buildProductListingItem(context, index, product));
        }
      }
    } else if (currentSignedInUser.isAdmin()) {
      if (_categoryFilters.isEmpty ||
          _categoryFilters.contains(getDisplayText(product.category)) ||
          (!product.isPublished && _categoryFilters.contains(_archivedText))) {
        widgets.add(_buildProductListingItem(context, index, product));
      }
    }
  }

  Widget _buildCategoryFilterMenu() {
    List<Widget> _columnWidgetList = <Widget>[
      _buildCategoryFilterMenuButton(),
    ];

    if (_isFilterMenuOpen) {
      _columnWidgetList.add(_buildCategoryFilterMenuOptions());
    }

    return Padding(
      padding: EdgeInsets.all(16),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isFilterMenuOpen = !_isFilterMenuOpen;
          });
        },
        child: Column(
          children: _columnWidgetList,
        ),
      ),
    );
  }

  Widget _buildCategoryFilterMenuOptions() {
    List<Widget> _widgetList = [];

    List<String> _filters =
        Category.values.map((c) => getDisplayText(c)).toList();
    if (currentSignedInUser.isAdmin()) {
      _filters.add(_archivedText);
    }

    _filters.forEach((_categoryFilterText) {
      _widgetList.add(_buildCategoryFilterChip(_categoryFilterText));
    });

    return Wrap(
      spacing: 5,
      runSpacing: -10,
      children: _widgetList,
    );
  }

  Widget _buildCategoryFilterChip(String _categoryFilterText) {
    bool _isSelected = _categoryFilters.contains(_categoryFilterText);

    return RawChip(
      showCheckmark: false,
      padding: EdgeInsets.zero,
      backgroundColor: kPaletteWhite,
      selectedColor: paletteRoseColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      label: Text(
        _categoryFilterText,
        style: TextStyle(
          color: _isSelected ? paletteForegroundColor : paletteBlackColor,
        ),
      ),
      selected: _isSelected,
      onSelected: (value) {
        setState(() {
          if (value) {
            _categoryFilters.add(_categoryFilterText);
          } else {
            _categoryFilters.removeWhere((c) => c == _categoryFilterText);
          }
        });
      },
    );
  }

  Widget _buildCategoryFilterMenuButton() {
    return Row(
      children: <Widget>[
        Text(
          "カテゴリを選ぶ",
          style: TextStyle(
            color: paletteBlackColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: _isFilterMenuOpen
              ? Icon(Icons.keyboard_arrow_up)
              : Icon(Icons.keyboard_arrow_down),
        ),
      ],
    );
  }

  Widget _buildProductListingItem(
    BuildContext context,
    int index,
    Product product,
  ) {
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
    var pageController = PageController(viewportFraction: 1.0);

    var widgetList = <Widget>[
      _buildProductListingItemTileImage(product, pageController),
    ];

    if ((product.imageUrls?.length ?? 0) > 1) {
      widgetList.add(
        _buildProductListingImageSliderButtons(product, pageController),
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

  Widget _buildProductListingImageSliderButtons(
    Product product,
    PageController pageController,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        activeImageMap[product.documentId] == 0
            ? Container()
            : _buildProductListingImageLeftButton(product, pageController),
        activeImageMap[product.documentId] == product.imageUrls.length - 1
            ? Container()
            : _buildProductListingImageRightButton(product, pageController),
      ],
    );
  }

  Widget _buildProductListingImageRightButton(
    Product product,
    PageController pageController,
  ) {
    return IconButton(
      icon: buildIconWithShadow(Icons.chevron_right, iconSize: 32),
      onPressed: () {
        pageController.nextPage(
          duration: Duration(milliseconds: 500),
          curve: Curves.ease,
        );
      },
    );
  }

  Widget _buildProductListingImageLeftButton(
    Product product,
    PageController pageController,
  ) {
    return IconButton(
      icon: buildIconWithShadow(Icons.chevron_left, iconSize: 32),
      onPressed: () {
        pageController.previousPage(
          duration: Duration(milliseconds: 500),
          curve: Curves.ease,
        );
      },
    );
  }

  Widget _buildProductListingItemTileInfoPane(Product product) {
    return GestureDetector(
      key: Key(makeTestKeyString(
        TKUsers.admin,
        TKScreens.productListing,
        "infoPane_" + product.name,
      )),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              if (currentSignedInUser.isAdmin()) {
                return AdminProductDetailPage(
                  productDocumentId: product.documentId,
                );
              } else {
                return CustomerProductDetailPage(
                  productDocumentId: product.documentId,
                );
              }
            },
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              _buildProductInfoPaneTitle(product),
              currentSignedInUser.isAdmin()
                  ? product.getStatusDisplay()
                  : Container(),
            ],
          ),
          _buildProductInfoPaneDescriptionRow(product),
        ],
      ),
    );
  }

  Widget _buildProductInfoPaneDescriptionRow(Product product) {
    List<Widget> widgetList = <Widget>[
      _buildProductInfoPaneDescription(product),
    ];

    if (currentSignedInUser.isAdmin()) {
      widgetList.add(_buildProductInfoPaneEditButton(product));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: widgetList,
    );
  }

  Widget _buildProductInfoPaneEditButton(Product product) {
    return IconButton(
      icon: Icon(
        Icons.edit,
        color: paletteForegroundColor,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminNewProductPage(
              productDocumentId: product.documentId,
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductInfoPaneDescription(Product product) {
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

  Widget _buildProductInfoPaneTitle(Product product) {
    var _padding = currentSignedInUser.isAdmin() ? 0.0 : 8.0;

    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(bottom: _padding),
        child: Text(
          product.name,
          key: Key(makeTestKeyString(
            TKUsers.admin,
            TKScreens.productListing,
            "title_" + product.name,
          )),
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: paletteBlackColor,
            fontWeight: FontWeight.w600,
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }

  Widget _buildProductListingItemTileImage(
    Product product,
    PageController pageController,
  ) {
    List<Widget> _widgetList = [
      _getProductListingImage(product, pageController),
    ];
    if (currentSignedInUser.isAdmin()) {
      _widgetList.add(_getProductStockQuantityTag(product));
    }
    return Container(
      color: paletteDarkGreyColor,
      height: constants.imageHeight,
      width: 500,
      child: Stack(
        children: _widgetList,
      ),
    );
  }

  Widget _getProductListingImage(
    Product product,
    PageController pageController,
  ) {
    var widgetList = <Widget>[];

    if (product.isPublished || (product.imageUrls?.length ?? 0) != 0) {
      widgetList.add(
        SpinKitThreeBounce(
          color: Colors.white,
          size: 16,
        ),
      );
    }

    widgetList.add(
      _buildProductImagePageView(pageController, product),
    );

    return Stack(
      alignment: AlignmentDirectional.center,
      children: widgetList,
    );
  }

  Widget _buildProductImagePageView(
    PageController pageController,
    Product product,
  ) {
    return PageView.builder(
      controller: pageController,
      itemCount: product.imageUrls.length,
      itemBuilder: (BuildContext context, int itemIndex) {
        return _getProductImage(product, itemIndex);
      },
      onPageChanged: (index) {
        setState(() {
          activeImageMap[product.documentId] = index;
        });
      },
    );
  }

  Widget _getProductImage(Product product, int imageIndex) {
    if (product.imageUrls?.isEmpty ?? true) {
      return Image.memory(
        kTransparentImage,
        height: constants.imageHeight,
      );
    } else {
      return FadeInImage.memoryNetwork(
        width: MediaQuery.of(context).size.width,
        fit: BoxFit.cover,
        placeholder: kTransparentImage,
        image: product.imageUrls[imageIndex],
      );
    }
  }

  Widget _getProductStockQuantityTag(Product product) {
    int totalQuantity = 0;
    product.stock.items
        .forEach((stock) => totalQuantity = totalQuantity + stock.quantity);
    return Container(
      height: 30,
      width: 60,
      color: paletteForegroundColor,
      child: Center(
        child: Text(
          "残" + (totalQuantity <= 999 ? totalQuantity.toString() : "999+"),
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildAboutBadiBanner() {
    return FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              {
                bool _appOpenedFirstTime = snapshot.data.getBool(
                        constants.SharedPrefsKeys.appOpenedFirstTime) ??
                    true;
                if (!_appOpenedFirstTime) {
                  return Container();
                }
                snapshot.data.setBool(
                    constants.SharedPrefsKeys.appOpenedFirstTime, false);
                return Container(
                  padding: EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    top: 40.0,
                    bottom: 30.0,
                  ),
                  child: GestureDetector(
                    child: Container(
                      height: 191.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/about_badi_banner.png'),
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AboutBadiPage(),
                        ),
                      );
                    },
                  ),
                );
              }
            default:
              {
                return Container();
              }
          }
        });
  }
}

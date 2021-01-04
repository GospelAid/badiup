import 'package:badiup/colors.dart';
import 'package:badiup/constants.dart' as constants;
import 'package:badiup/models/cart_model.dart';
import 'package:badiup/models/customer_model.dart';
import 'package:badiup/models/product_model.dart';
import 'package:badiup/models/stock_model.dart';
import 'package:badiup/screens/login_page.dart';
import 'package:badiup/sign_in.dart';
import 'package:badiup/utilities.dart';
import 'package:badiup/widgets/cart_button.dart';
import 'package:badiup/widgets/product_detail.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  ItemSize _selectedItemSize;
  ItemColor _selectedItemColor;
  bool _showAddToCartFailedMessage = false;
  String _addToCartFailedMessage = "";

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
        return Scaffold(
          key: _scaffoldKey,
          appBar: _buildAppBar(context, product),
          body: _buildBody(context, product),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, Product product) {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: _buildBodyWidgets(product),
          ),
        ),
        Container(
          height: 64,
          child: Row(
            children: <Widget>[
              _buildAddToCartButton(context, product),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildBodyWidgets(Product product) {
    var bodyWidgets = List<Widget>();
    bodyWidgets.add(
      ProductDetail(
        selectedItemColor: _selectedItemColor,
        selectedItemSize: _selectedItemSize,
        productDocumentId: widget.productDocumentId,
      ),
    );
    bodyWidgets.add(SizedBox(height: 40));
    bodyWidgets.add(Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: kPaletteBorderColor)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: product.stock.stockType == StockType.quantityOnly
            ? Container()
            : Text(
                _getSelectStockDisplayText(product.stock.stockType),
                style: TextStyle(color: paletteBlackColor),
              ),
      ),
    ));
    bodyWidgets.add(SizedBox(height: 40));
    bodyWidgets.add(_buildStockSelector(product));
    bodyWidgets.add(SizedBox(height: 150));

    return bodyWidgets;
  }

  String _getSelectStockDisplayText(StockType productStockType) {
    if (productStockType == StockType.colorOnly)
      return "下記より色をお選びください";
    else if (productStockType == StockType.sizeAndColor)
      return "下記よりサイズと色をお選びください";
    else if (productStockType == StockType.sizeOnly)
      return "下記よりサイズをお選びください";
    else
      return null;
  }

  Widget _buildAddToCartFailedMessage(StockType productStockType) {
    return Container(
      alignment: AlignmentDirectional.center,
      color: paletteRoseColor,
      height: 75,
      child: Text(
        _addToCartFailedMessage,
        style: TextStyle(color: paletteDarkRedColor),
      ),
    );
  }

  Widget _buildStockSelector(Product product) {
    return _buildStockSelectorInternal(
      product,
      TextStyle(
        color: paletteBlackColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildStockSelectorInternal(Product _product, TextStyle _textStyle) {
    List<Widget> _widgetList = [];
    if (_showAddToCartFailedMessage) {
      _widgetList.add(_buildAddToCartFailedMessage(_product.stock.stockType));
      _widgetList.add(SizedBox(height: 12));
    }

    if (_product.stock.stockType == StockType.sizeAndColor ||
        _product.stock.stockType == StockType.sizeOnly) {
      _widgetList.add(_buildStockSizePicker(_product.stock, _textStyle));
    }

    if (_product.stock.stockType == StockType.sizeAndColor) {
      _widgetList.add(SizedBox(height: 12));
    }

    if (_product.stock.stockType == StockType.sizeAndColor ||
        _product.stock.stockType == StockType.colorOnly) {
      _widgetList.add(_buildStockColorPicker(_product.stock, _textStyle));
    }

    return Column(children: _widgetList);
  }

  Widget _buildStockColorPicker(Stock stock, TextStyle textStyle) {
    return Container(
      alignment: AlignmentDirectional.centerStart,
      height: 67,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: kPaletteWhite,
      ),
      child: _buildStockColorPickerButton(stock, textStyle),
    );
  }

  Widget _buildStockColorPickerButton(Stock stock, TextStyle textStyle) {
    var _availableStockColors = _getAvailableStockColors(stock);

    return DropdownButton<ItemColor>(
      value: _selectedItemColor,
      focusColor: paletteBlackColor,
      hint: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          '色',
          style: TextStyle(
            fontWeight: FontWeight.w300,
            color: paletteBlackColor,
          ),
        ),
      ),
      isExpanded: true,
      icon: _buildDropdownButtonIcon(),
      iconSize: 32,
      elevation: 2,
      style: textStyle,
      underline: Container(),
      onChanged: (ItemColor newValue) {
        setState(() {
          _selectedItemColor = newValue;
        });
      },
      items: _availableStockColors
          .map<DropdownMenuItem<ItemColor>>((ItemColor value) {
        return DropdownMenuItem<ItemColor>(
          value: value,
          child: _buildDropdownMenuItem(
            getDisplayTextForItemColor(value),
            textStyle,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDropdownMenuItem(
    String text,
    TextStyle textStyle,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: AlignmentDirectional.centerStart,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(text, style: textStyle),
        ],
      ),
    );
  }

  Widget _buildStockSizePickerButton(Stock stock, TextStyle textStyle) {
    var _availableStockSizes = _getAvailableStockSizes(stock);

    return DropdownButton<ItemSize>(
      value: _selectedItemSize,
      focusColor: paletteBlackColor,
      isExpanded: true,
      hint: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          'サイズ',
          style:
              TextStyle(fontWeight: FontWeight.w300, color: paletteBlackColor),
        ),
      ),
      icon: _buildDropdownButtonIcon(),
      iconSize: 32,
      elevation: 2,
      style: textStyle,
      underline: Container(),
      onChanged: (ItemSize newValue) {
        setState(() {
          _selectedItemSize = newValue;
        });
      },
      items: _availableStockSizes
          .map<DropdownMenuItem<ItemSize>>((ItemSize value) {
        return DropdownMenuItem<ItemSize>(
          value: value,
          child: _buildDropdownMenuItem(
            getDisplayTextForItemSize(value),
            textStyle,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDropdownButtonIcon() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Icon(Icons.keyboard_arrow_down, color: paletteDarkGreyColor),
    );
  }

  Widget _buildStockSizePicker(Stock stock, TextStyle textStyle) {
    return Container(
      alignment: AlignmentDirectional.centerStart,
      height: 67,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: kPaletteWhite,
      ),
      child: _buildStockSizePickerButton(stock, textStyle),
    );
  }

  List<ItemSize> _getAvailableStockSizes(Stock stock) {
    var _availableStockSizes = _selectedItemColor != null
        ? stock.items.where((stockItem) =>
            stockItem.quantity != 0 && stockItem.color == _selectedItemColor)
        : stock.items.where((stockItem) => stockItem.quantity != 0);
    return _availableStockSizes
        .map<ItemSize>((stockItem) => stockItem.size)
        .toSet()
        .toList();
  }

  List<ItemColor> _getAvailableStockColors(Stock stock) {
    var _availableStockColors = _selectedItemSize != null
        ? stock.items.where((stockItem) =>
            stockItem.quantity != 0 && stockItem.size == _selectedItemSize)
        : stock.items.where((stockItem) => stockItem.quantity != 0);
    return _availableStockColors
        .map<ItemColor>((stockItem) => stockItem.color)
        .toSet()
        .toList();
  }

  Widget _buildAddToCartButton(BuildContext context, Product product) {
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          if (currentSignedInUser.isGuest) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ),
            );
          } else {
            if (await _canAddToCart(product)) {
              _addToCart();
              _scaffoldKey.currentState.showSnackBar(
                buildSnackBar("商品をかごに追加しました。右上の買い物かごからご確認できます。"),
              );
            } else {
              setState(() {
                _showAddToCartFailedMessage = true;
              });
            }
          }
        },
        child: currentSignedInUser.isGuest
            ? _buildLoginRequiredButtonText()
            : _buildAddToCartButtonInternal(),
      ),
    );
  }

  Widget _buildLoginRequiredButtonText() {
    return Container(
      height: 64,
      color: paletteForegroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "購入ご希望の方はログインしてください",
            style: TextStyle(
              color: kPaletteWhite,
              fontWeight: FontWeight.w600,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAddToCartButtonInternal() {
    return Container(
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
    );
  }

  Future<bool> _canAddToCart(Product _product) async {
    bool canAddToCart = true;

    if (_product.stock.stockType == StockType.sizeAndColor) {
      _addToCartFailedMessage = "サイズと色を選択してください";
      canAddToCart = _selectedItemColor != null && _selectedItemSize != null;
    } else if (_product.stock.stockType == StockType.sizeOnly) {
      _addToCartFailedMessage = "サイズを選択してください";
      canAddToCart = _selectedItemSize != null;
    } else if (_product.stock.stockType == StockType.colorOnly) {
      _addToCartFailedMessage = "色を選択してください";
      canAddToCart = _selectedItemColor != null;
    }

    if (canAddToCart) {
      var customer = Customer.fromSnapshot(await db
          .collection(constants.DBCollections.users)
          .document(currentSignedInUser.email)
          .get());

      if (customer.cart == null) {
        customer.cart = Cart(items: []);
      }

      int productIndexInCart = customer.cart.items.indexWhere((cartItem) =>
          cartItem.productDocumentId == widget.productDocumentId &&
          cartItem.stockRequest?.color == _selectedItemColor &&
          cartItem.stockRequest?.size == _selectedItemSize);

      if (productIndexInCart != -1) {
        StockItem productStock = _product.getRequestedStockItem(StockItem(
          color: _selectedItemColor,
          size: _selectedItemSize,
        ));

        _addToCartFailedMessage = "在庫切れ";
        if (customer.cart.items[productIndexInCart].stockRequest.quantity >=
            productStock.quantity) {
          canAddToCart = false;
        }
      }
    }

    return canAddToCart;
  }

  Future<void> _addToCart() async {
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
    var _stockRequest = StockItem(
      color: _selectedItemColor,
      size: _selectedItemSize,
      quantity: 1,
    );

    if (customer.cart == null) {
      customer.cart = Cart(
        items: [
          CartItem(
            productDocumentId: widget.productDocumentId,
            stockRequest: _stockRequest,
          ),
        ],
      );
    } else {
      int productIndex = customer.cart.items.indexWhere((cartItem) =>
          cartItem.productDocumentId == widget.productDocumentId &&
          cartItem.stockRequest?.color == _selectedItemColor &&
          cartItem.stockRequest?.size == _selectedItemSize);

      if (productIndex != -1) {
        customer.cart.items[productIndex].stockRequest.quantity++;
      } else {
        customer.cart.items.add(CartItem(
          productDocumentId: widget.productDocumentId,
          stockRequest: _stockRequest,
        ));
      }
    }
  }

  Widget _buildAppBar(BuildContext context, Product product) {
    return AppBar(
      title: Text(product.name),
      actions: <Widget>[
        CartButton(),
      ],
    );
  }
}

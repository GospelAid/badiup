import 'package:badiup/colors.dart';
import 'package:badiup/constants.dart' as constants;
import 'package:badiup/models/cart_model.dart';
import 'package:badiup/models/customer_model.dart';
import 'package:badiup/models/product_model.dart';
import 'package:badiup/models/stock_model.dart';
import 'package:badiup/sign_in.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(context),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: <Widget>[
              ProductDetail(
                  selectedItemColor: _selectedItemColor,
                  selectedItemSize: _selectedItemSize,
                  productDocumentId: widget.productDocumentId),
              SizedBox(height: 40),
              _buildStockSelector(),
              SizedBox(height: 150),
            ],
          ),
        ),
        Container(
          height: 64,
          child: Row(
            children: <Widget>[
              _buildAddToCartButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStockSelector() {
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance
          .collection(constants.DBCollections.products)
          .document(widget.productDocumentId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        }

        return _buildStockSelectorInternal(
          Product.fromSnapshot(snapshot.data),
          TextStyle(
            color: paletteBlackColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        );
      },
    );
  }

  Widget _buildStockSelectorInternal(Product _product, TextStyle _textStyle) {
    List<Widget> _widgetList = [];

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

  Widget _buildAddToCartButton() {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _addToCart();

          _scaffoldKey.currentState.showSnackBar(
            _buildAddedToCartNotification(),
          );
        },
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

  SnackBar _buildAddedToCartNotification() {
    return SnackBar(
      behavior: SnackBarBehavior.fixed,
      content: Container(
        alignment: AlignmentDirectional.centerStart,
        height: 40,
        child: Text("商品をかごに追加しました。右上の買い物かごからご確認できます。"),
      ),
      action: SnackBarAction(
        textColor: paletteGreyColor3,
        label: "OK",
        onPressed: () {},
      ),
    );
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

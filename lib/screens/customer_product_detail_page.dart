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
  bool _showAddToCartFailedMessage = false;
  bool _failedMessageQuantityType = false;
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
          body: _buildBody(product),
        );
      },
    );
  }

  Widget _buildBody(Product product) {
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
              _buildAddToCartButton(product),
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
    String errorMessage;
    if (_failedMessageQuantityType) {
      errorMessage = "在庫切れ";
    } else {
      switch (productStockType) {
        case StockType.sizeAndColor:
          {
            errorMessage = "サイズと色を選択してください";
          }
          break;

        case StockType.sizeOnly:
          {
            errorMessage = "サイズを選択してください";
          }
          break;

        case StockType.colorOnly:
          {
            errorMessage = "色を選択してください";
          }
          break;
        default:
          {
            errorMessage = "";
          }
          break;
      }
    }

    return Container(
      alignment: AlignmentDirectional.center,
      color: paletteRoseColor,
      height: 75,
      child: Text(
        errorMessage,
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

  Widget _buildAddToCartButton(Product product) {
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          if (_canAddToCart(product)) {
            _addToCart(product);
          } else {
            setState(() {
              _showAddToCartFailedMessage = true;
            });
          }
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

  bool _canAddToCart(Product _product) {
    if (_product.stock.stockType == StockType.sizeAndColor) {
      return _selectedItemColor != null && _selectedItemSize != null;
    } else if (_product.stock.stockType == StockType.sizeOnly) {
      return _selectedItemSize != null;
    } else if (_product.stock.stockType == StockType.colorOnly) {
      return _selectedItemColor != null;
    }
    return true;
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

  Future<void> _addToCart(Product _product) async {
    var customer = Customer.fromSnapshot(await db
        .collection(constants.DBCollections.users)
        .document(currentSignedInUser.email)
        .get());

    _updateCartModel(customer, _product);

    await db
        .collection(constants.DBCollections.users)
        .document(currentSignedInUser.email)
        .updateData(customer.toMap());
  }

  void _updateCartModel(Customer customer, Product _product) {
    bool addToCartSuccess = true;
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
        StockItem productStock = StockItem();
        if (_stockRequest.color != null && _stockRequest.size != null) {
          productStock = _product.stock.items.firstWhere((stockItem) =>
              stockItem?.color == _selectedItemColor &&
              stockItem?.size == _selectedItemSize);
        }
        if (_stockRequest.color == null && _stockRequest.size != null) {
          productStock = _product.stock.items
              .firstWhere((stockItem) => stockItem?.size == _selectedItemSize);
        }
        if (_stockRequest.color != null && _stockRequest.size == null) {
          productStock = _product.stock.items.firstWhere(
              (stockItem) => stockItem?.color == _selectedItemColor);
        }
        if (customer.cart.items[productIndex].stockRequest.quantity <
            productStock.quantity) {
          customer.cart.items[productIndex].stockRequest.quantity++;
        } else {
          addToCartSuccess = false;
        }
      } else {
        customer.cart.items.add(CartItem(
          productDocumentId: widget.productDocumentId,
          stockRequest: _stockRequest,
        ));
      }
    }
    if (addToCartSuccess) {
      _scaffoldKey.currentState.showSnackBar(
        _buildAddedToCartNotification(),
      );
      setState(() {
        _showAddToCartFailedMessage = false;
        _failedMessageQuantityType = false;
      });
    }else{
      setState(() {
        _showAddToCartFailedMessage = true;
        _failedMessageQuantityType = true;
      });
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

import 'package:badiup/colors.dart';
import 'package:badiup/constants.dart' as constants;
import 'package:badiup/models/stock_model.dart';
import 'package:badiup/models/custom_color_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:badiup/screens/admin_new_color_page.dart';

class StockSelector extends StatefulWidget {
  StockSelector({Key key, this.productStockItem, this.productStockType})
      : super(key: key);

  final StockItem productStockItem;
  final StockType productStockType;

  @override
  _StockSelectorState createState() => _StockSelectorState();
}

class _StockSelectorState extends State<StockSelector> {
  ItemSize _stockSize = ItemSize.small;
  String _stockColor = "black";
  var _stockQuantityEditingController = TextEditingController();
  List<CustomColor> _colorIterableList;
  CustomColorList _customColorList;

  @override
  initState() {
    super.initState();
    if (widget.productStockItem != null) {
      _stockSize = widget.productStockItem.size;
      _stockColor = widget.productStockItem.color;
      _stockQuantityEditingController.text =
          widget.productStockItem.quantity.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection(constants.DBCollections.colors)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();

          _colorIterableList = snapshot.data.documents
              .map((snapshot) => CustomColor.fromSnapshot(snapshot))
              .toList();

          _customColorList =
              CustomColorList(customColorList: _colorIterableList);

          return Scaffold(
              appBar: AppBar(
                actions: <Widget>[
                  _buildNewColorButton(context),
                ],
              ),
              body: _buildAddStockScreen());
        });
  }

  Widget _buildNewColorButton(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.opacity,
        semanticLabel: 'new_color',
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminNewColorPage(),
          ),
        );
      },
    );
  }

  Widget _buildAddStockScreen() {
    var _textStyle = TextStyle(
      color: paletteBlackColor,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );

    var widgetList = List<Widget>();

    if (widget.productStockType == StockType.sizeAndColor ||
        widget.productStockType == StockType.sizeOnly) {
      widgetList.add(_buildStockSize(_textStyle));
    }

    if (widget.productStockType == StockType.sizeAndColor ||
        widget.productStockType == StockType.colorOnly) {
      widgetList.add(_buildStockColor(_textStyle));
    }

    widgetList.add(_buildStockQuantityPicker());
    widgetList.add(_buildStockFormActionButtons());

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: widgetList,
      ),
    );
  }

  Widget _buildStockColor(TextStyle _textStyle) {
    return widget.productStockItem == null
        ? _buildStockColorPicker(_textStyle)
        : _buildStockColorDisplay(_textStyle);
  }

  Widget _buildStockSize(TextStyle _textStyle) {
    return widget.productStockItem == null
        ? _buildStockSizePicker(_textStyle)
        : _buildStockSizeDisplay(_textStyle);
  }

  Widget _buildStockColorDisplay(TextStyle textStyle) {
    var controller = TextEditingController(
      text: _customColorList.getDisplayTextForItemColor(_stockColor),
    );

    return TextField(
      readOnly: true,
      controller: controller,
      style: textStyle,
    );
  }

  Widget _buildStockSizeDisplay(TextStyle textStyle) {
    var controller = TextEditingController(
      text: _getStockSizeDisplayText(_stockSize),
    );

    return TextField(
      readOnly: true,
      controller: controller,
      style: textStyle,
    );
  }

  String _getStockSizeDisplayText(ItemSize size) =>
      getDisplayTextForItemSize(size);

  String _getStockColorDisplayText(String color) =>
      _customColorList.getDisplayTextForItemColor(color);

  Widget _buildStockFormActionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          _buildStockFormCancelButton(),
          SizedBox(width: 12),
          _buildStockFormSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildStockFormSubmitButton() {
    return GestureDetector(
      child: Text(
        '完了',
        style: TextStyle(
          color: paletteForegroundColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: () {
        Navigator.pop(
          context,
          StockItem(
            color: _stockColor,
            size: _stockSize,
            quantity: int.tryParse(_stockQuantityEditingController.text) ?? 0,
          ),
        );
      },
    );
  }

  Widget _buildStockFormCancelButton() {
    return GestureDetector(
      child: Text(
        'キャンセル',
        style: TextStyle(color: paletteBlackColor),
      ),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }

  Widget _buildStockQuantityPicker() {
    return TextFormField(
      controller: _stockQuantityEditingController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: '在庫',
        alignLabelWithHint: true,
      ),
    );
  }

  Widget _buildStockColorPicker(TextStyle _textStyle) {
    List<String> _colorNameList =
        _colorIterableList.map((color) => color.name).toList();

    return _buildPicker<String>(
      pickerValue: _stockColor,
      textStyle: _textStyle,
      valueOnChanged: widget.productStockItem == null
          ? (String newValue) {
              setState(() {
                _stockColor = newValue;
              });
            }
          : null,
      items: _colorNameList.map<DropdownMenuItem<String>>(
        (String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              _getStockColorDisplayText(value),
              style: _textStyle,
            ),
          );
        },
      ).toList(),
    );
  }

  Widget _buildPicker<T>({
    T pickerValue,
    TextStyle textStyle,
    Function valueOnChanged,
    List<DropdownMenuItem<T>> items,
  }) {
    return DropdownButton<T>(
      isExpanded: true,
      value: pickerValue,
      icon: Icon(Icons.keyboard_arrow_down),
      iconSize: 32,
      elevation: 2,
      style: textStyle,
      underline: Container(height: 1, color: paletteDarkGreyColor),
      onChanged: valueOnChanged,
      items: items,
    );
  }

  Widget _buildStockSizePicker(TextStyle _textStyle) {
    return _buildPicker<ItemSize>(
      pickerValue: _stockSize,
      textStyle: _textStyle,
      valueOnChanged: widget.productStockItem == null
          ? (ItemSize newValue) {
              setState(() {
                _stockSize = newValue;
              });
            }
          : null,
      items: ItemSize.values.map<DropdownMenuItem<ItemSize>>(
        (ItemSize value) {
          return DropdownMenuItem<ItemSize>(
            value: value,
            child: Text(
              _getStockSizeDisplayText(value),
              style: _textStyle,
            ),
          );
        },
      ).toList(),
    );
  }
}
